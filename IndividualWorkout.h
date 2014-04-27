//
//  IndividualWorkout.h
//  WorkoutMusic
//
//  Created by John La Barge on 11/16/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorkoutGraph.h"
@interface IndividualWorkout : UIViewController <UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIButton *editButton;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;
@property (strong, nonatomic) IBOutlet UIButton *startButton;
@property (strong, nonatomic) IBOutlet WorkoutGraph *graphView;
@property (strong, nonatomic) IBOutlet UILabel *workoutTimeLabel;

@property (strong, nonatomic) Workout *workout;
@end
