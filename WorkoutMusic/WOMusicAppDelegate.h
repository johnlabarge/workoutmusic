//
//  workoutmusicAppDelegate.h
//  WorkoutMusic
//
//  Created by John La Barge on 11/12/12.
//  Copyright (c) 2012 John La Barge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransitionController.h"
#import "MusicLibraryBPMS.h"
#import "WorkoutList.h"

@interface WOMusicAppDelegate : UIResponder <UIApplicationDelegate,UITabBarControllerDelegate> {
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;

}
- (NSManagedObjectContext *) managedObjectContext;

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong, readonly) WorkoutList * workout;
@property (nonatomic, strong) MusicLibraryBPMs * musicBPMLibrary; 
@property (nonatomic, strong) TransitionController * transitionController;
@property (nonatomic, weak) IBOutlet UINavigationController *workoutNavigator;

@property (nonatomic, strong) UITabBarController * tabs;

@end
