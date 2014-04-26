//
//  SongsTableViewController.h
//  WorkoutMusic
//
//  Created by John La Barge on 2/27/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorkoutList.h"
#import "WorkoutListItem.h" 
#import "Workout.h"

@interface SongsTableViewController : UITableViewController
@property (strong, nonatomic) WorkoutList * workoutList;
@property (strong, nonatomic) WorkoutListItem *currentListItem;

@property (strong, nonatomic) Workout * workout;


@end
