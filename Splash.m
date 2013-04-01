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
        [super viewDidLoad];
    [self.musicBPMLibrary addObserver:self forKeyPath:@"totalNumberOfItems" options:NSKeyValueObservingOptionNew context:nil];
    [self.musicBPMLibrary addObserver:self forKeyPath:@"currentIndexBeingProcessed" options:NSKeyValueObservingOptionNew context:nil];
    [self.musicBPMLibrary addObserver:self forKeyPath:@"itemBeingProcessed" options:NSKeyValueObservingOptionNew context:nil];
	
       
  
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"observing!!!!!");
    if (object == self.musicBPMLibrary) {
        if ([keyPath isEqualToString:@"totalNumberOfItems"]) {
            self.currentlyProcessing.text = [NSString stringWithFormat:@"%d total items", self.musicBPMLibrary.totalNumberOfItems];
        } else if ([keyPath isEqualToString:@"currentIndexBeingProcessed"]) {
             NSLog(@" current index being processed = %d", self.musicBPMLibrary.currentIndexBeingProcessed);
             NSUInteger total = self.musicBPMLibrary.totalNumberOfItems;
             [self.progressView setProgress:(self.musicBPMLibrary.currentIndexBeingProcessed+0.0)/(total>0?total:1) animated:YES];
            
        } else if ([keyPath isEqualToString:@"itemBeingProcessed"]) {
            MusicLibraryItem * item = self.musicBPMLibrary.itemBeingProcessed;
            NSString *artist = [item.mediaItem valueForProperty:MPMediaItemPropertyArtist];
            NSString *title = [item.mediaItem valueForProperty:MPMediaItemPropertyTitle];
            self.currentlyProcessing.text = [NSString stringWithFormat:@"Processing : %@ - %@", artist,title]; 
        }
    }
}
- (void)viewDidUnload
{
    [super viewDidUnload];
   }
-(void) afterSplash
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"workoutmusic" bundle:nil];
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
    [self.musicBPMLibrary removeObserver:self forKeyPath:@"totalNumberOfItems"];
    [self.musicBPMLibrary removeObserver:self forKeyPath:@"currentIndexBeingProcessed"];
    [self.musicBPMLibrary removeObserver:self forKeyPath:@"itemBeingProcessed"];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
