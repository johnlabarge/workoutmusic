//
//  workoutmusicAppDelegate.m
//  WorkoutMusic
//
//  Created by John La Barge on 11/12/12.
//  Copyright (c) 2012 John La Barge. All rights reserved.
//

#import "WOMusicAppDelegate.h"
#import "MusicLibraryBPMs.h"
#import "WorkoutList.h"
#import "Splash.h"
#import "WorkoutMusicSettings.h"

@interface WOMusicAppDelegate ()
@property (nonatomic, strong) WorkoutList * workout;
@property (nonatomic, strong) Splash *splashScreen;
@end

@implementation WOMusicAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    WorkoutMusicSettings * settings = [WorkoutMusicSettings sharedInstance];
    self.musicBPMLibrary = [[MusicLibraryBPMs alloc] initWithManagedObjectContext:[self managedObjectContext]];

    __block WOMusicAppDelegate * me = self;
    dispatch_queue_t processqueue = dispatch_queue_create("music processor", NULL);
    dispatch_async(processqueue, ^{
        [self.musicBPMLibrary processItunesLibrary:^(MusicLibraryItem *item) {
            NSLog(@"%@ processing", [item.mediaItem valueForProperty:MPMediaItemPropertyTitle]);

        } afterUpdatingItem:^(MusicLibraryItem *item) {
            NSLog(@"%@ processed", [item.mediaItem valueForProperty:MPMediaItemPropertyTitle]);
        }];
        [WorkoutList instantiateForLibrary:self.musicBPMLibrary];
         
       
        NSLog(@"#####\n\n DONE PROCESSING WORKOUT SONGS \n\n######");
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@" killing splash screen...");
            [me.splashScreen afterSplash]; 
        });
    });
     [self splash];
    //dispatch_release(processqueue);
    self.workout = [WorkoutList sharedInstance];
    
    return YES;
   
}



-(BOOL) splash
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"workoutmusic" bundle:nil];
    self.splashScreen = (Splash *) [storyboard instantiateViewControllerWithIdentifier:@"Splash"];
    
    //self.transitionController = [[TransitionController alloc] initWithViewController:vc];
    self.window.rootViewController = self.splashScreen;
   // [self.window makeKeyAndVisible];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


//Explicitly write Core Data accessors
- (NSManagedObjectContext *) managedObjectContext {
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
                                               stringByAppendingPathComponent: @"workoutmusic.sqlite"]];
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                  initWithManagedObjectModel:[self managedObjectModel]];
    if(![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                 configuration:nil URL:storeUrl options:nil error:&error]) {
        /*Error for store creation should be handled in here*/
    }
    
    return persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}
@end
