//
//  workoutmusicSecondViewController.m
//  WorkoutMusic
//
//  Created by John La Barge on 11/12/12.
//  Copyright (c) 2012 John La Barge. All rights reserved.
//

#import "CategorizedVC.h"
@interface CategorizedVC ()

@end

@implementation CategorizedVC

@synthesize categoryControl;
@synthesize musicLibraryTableVC;
@synthesize musicTableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.musicLibraryTableVC = [[MusicLibraryTableVC alloc] init];
    [self.musicTableView setDataSource:self.musicLibraryTableVC];
    [self.musicTableView setDelegate:self.musicLibraryTableVC];
    self.musicLibraryTableVC.tableView = self.musicTableView;
    [self.musicLibraryTableVC updateMusic]; 
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)categoryChanged
{
    if (self.categoryControl.selectedSegmentIndex == 0) {
        [self.musicLibraryTableVC.library unfilter];
    }
    else if (self.categoryControl.selectedSegmentIndex == 1) {
        [self.musicLibraryTableVC.library filterWithMin:60 andMax:95];
    } else if (self.categoryControl.selectedSegmentIndex == 2) {
        [self.musicLibraryTableVC.library filterWithMin:96 andMax:125];
    } else if (self.categoryControl.selectedSegmentIndex == 3) {
        [self.musicLibraryTableVC.library filterWithMin:125 andMax:159];
    } else {
        [self.musicLibraryTableVC.library filterWithMin:160 andMax:400];
    }
    
}

-(IBAction)playMusic
{
    self.musicPlayerController = [MPMusicPlayerController applicationMusicPlayer];
    
    NSMutableArray * playQueueArray = [[NSMutableArray alloc] initWithCapacity:self.musicLibraryTableVC.library.libraryItems.count ];
    for (MusicLibraryItem * item in self.musicLibraryTableVC.library.libraryItems) {
        [playQueueArray addObject:item.mediaItem];
    }
    
    
    MPMediaItemCollection * playQueue = [MPMediaItemCollection collectionWithItems:playQueueArray];
    [self.musicPlayerController setQueueWithItemCollection:playQueue];
    [self.musicPlayerController play];
}

-(IBAction)pauseMusic
{
    [self.musicPlayerController pause];
}

-(IBAction)prev
{
    [self.musicPlayerController skipToPreviousItem];
}
-(IBAction)next
{
    [self.musicPlayerController skipToNextItem];
}


@end
