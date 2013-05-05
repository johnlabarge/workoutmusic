//
//  workoutmusicViewController.h
//  WorkoutMusic
//
//  Created by La Barge, John on 3/23/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import "SuperViewController.h"
#import "WorkoutGraph.h"

@interface  PlayerViewController : SuperViewController <UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView * tableView;
@property (nonatomic, strong) IBOutlet UILabel * workoutTimeRemaining;
@property (nonatomic, strong) IBOutlet UILabel * songRemainingTime;
@property (nonatomic, strong) IBOutlet UIButton * playButton;
@property (nonatomic, strong) IBOutlet UIButton * pauseButton;
@property (nonatomic, strong) IBOutlet UIButton * previousButton;
@property (nonatomic, strong) IBOutlet UIButton * nextButton;
@property (nonatomic, strong) IBOutlet UILabel * intervalLabel;
@property (nonatomic, strong) IBOutlet UIButton *showSongsButton;
@property (nonatomic, strong) IBOutlet UIToolbar *musicControlBar;
@property (nonatomic, strong) IBOutlet UIView *songsView;
@property (nonatomic, strong) IBOutlet UIImage * retractSongsImage;
@property (nonatomic, strong) IBOutlet UIImage * expandSongsImage;
@property (nonatomic, strong) IBOutlet UIView * songsTableContainer;
@property (nonatomic, strong) IBOutlet UIView * buttonBar; 

@property (nonatomic, strong) IBOutlet WorkoutGraph * workoutGraph; 

@property (nonatomic, strong) NSNumber * remainingPlaybacktime; 
@property (nonatomic, strong) MPMusicPlayerController *musicPlayerController;
@property (nonatomic, strong) NSArray * playQueueArray;


@property (nonatomic, strong) NSTimer * workoutTimer;
@property (nonatomic, assign) NSInteger currentSongIndex;
@property (nonatomic, assign) BOOL songsExpanded;
-(IBAction)playMusic;
-(IBAction)showSongs:(id)sender;
-(IBAction)pauseMusic;
-(IBAction)prev;
-(IBAction)next;


@end
