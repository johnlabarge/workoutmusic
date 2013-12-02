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

@interface WorkoutViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property WorkoutList * workoutList;
@property Workout * workout;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) IBOutlet WorkoutGraph *graph;
@property (strong, nonatomic) IBOutlet UITableView *songTable;
@end
