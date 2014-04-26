//
//  Splash.m
//  roshambo
//
//  Created by La Barge, John on 2/7/13.
//  Copyright (c) 2013 La Barge, John. All rights reserved.
//

#import "Splash.h"
#import "MusicLibraryBPMs.h"

@interface Splash ()
@property (nonatomic, assign) BOOL wasLoaded; 
@end

@implementation Splash
@synthesize image;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    self.wasLoaded = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaProcessedNotificationHandler:) name:@"media_processed" object:nil];
       
  
}
-(void) mediaProcessedNotificationHandler:(NSNotification *)note
{
    NSUInteger total =  ((NSNumber *)note.userInfo[@"totalItems"]).integerValue;
    NSUInteger currentIndex =  ((NSNumber *)note.userInfo[@"currentIndexBeingProcessed"]).integerValue;
    double progress = (0.0+currentIndex)/total;
    
    NSLog(@"#####\n Processed : %lul out of Total items : %lul %.2f", (unsigned long)currentIndex, (unsigned long)total, progress);
    MusicLibraryItem * mi = note.userInfo[@"itemBeingProcessed"];
    __weak NSString * artist = (NSString *) mi.artist;
    __weak NSString * title = (NSString *) mi.title;
    __weak Splash * me = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (total > 0) {
            [me.progressView setProgress:progress];
        } else {
            [me.progressView setProgress:1.0];
        }
        me.currentlyProcessing.text = [NSString stringWithFormat:@"%@ - %@",artist,title];
    });
}
- (void)viewDidUnload
{
    [super viewDidUnload];
   }
-(void) afterSplash
{
  
    [self performSegueWithIdentifier:@"splashOut" sender:self];
    

    /*UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"workoutmusic" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
    WOMusicAppDelegate *  appDelegate = [UIApplication sharedApplication].delegate;
    NSLog(@" afterSplash...");
    [appDelegate.transitionController performSelectorOnMainThread:@selector(transitionToViewController:) withObject:vc waitUntilDone:NO];*/
}

-(void)dealloc
{
    if (self.wasLoaded) { 
   /* [self.musicBPMLibrary removeObserver:self forKeyPath:@"totalNumberOfItems"];
    [self.musicBPMLibrary removeObserver:self forKeyPath:@"currentIndexBeingProcessed"];
    [self.musicBPMLibrary removeObserver:self forKeyPath:@"itemBeingProcessed"];*/
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
