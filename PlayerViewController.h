//
//  workoutmusicViewController.h
//  WorkoutMusic
//
//  Created by La Barge, John on 3/23/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import "SuperViewController.h"

@interface  PlayerViewController : SuperViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView * tableView;
@property (nonatomic, strong) IBOutlet UILabel * workoutTimeRemaining;
@property (nonatomic, strong) IBOutlet UILabel * songRemainingTime;
@property (nonatomic, strong) IBOutlet UIButton * playButton;
@property (nonatomic, strong) IBOutlet UIButton * pauseButton;
@property (nonatomic, strong) IBOutlet UIButton * previousButton;
@property (nonatomic, strong) IBOutlet UIButton * nextButton;
@property (nonatomic, strong) NSNumber * remainingPlaybacktime; 
@property (nonatomic, strong) MPMusicPlayerController *musicPlayerController;
@property (nonatomic, strong) NSArray * playQueueArray; 
@property (nonatomic, strong) NSTimer * workoutTimer; 

@end
