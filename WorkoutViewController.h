//
//  WorkoutViewController.h
//  WorkoutMusic
//
//  Created by John La Barge on 11/30/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorkoutList.h"
#import "WorkoutGraph.h"
#import "Workout.h"
#import "SongJockeySong.h"

@interface WorkoutViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property WorkoutList * workoutList;
@property (weak, nonatomic) IBOutlet UIView *songTableContainer;
@property (strong, nonatomic) Workout * workout;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIButton *playPause;
@property (strong, nonatomic) IBOutlet WorkoutGraph *graph;
@property (weak, nonatomic) IBOutlet UIView *controlsView;
@property (weak, nonatomic) IBOutlet UITableView * tableView; 
@property (strong, nonatomic) IBOutlet UITableView *songTable;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end
