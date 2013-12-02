//
//  StartWorkoutSegue.m
//  WorkoutMusic
//
//  Created by John La Barge on 11/30/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import "StartWorkoutSegue.h"
#import "IndividualWorkout.h"
#import "WorkoutViewController.h"

@implementation StartWorkoutSegue
-(void) perform
{
    IndividualWorkout * iw = (IndividualWorkout *) self.sourceViewController;
    UIViewController * parent = [iw presentingViewController];
    UINavigationController *parentNav =(UINavigationController *) parent;
    [iw dismissViewControllerAnimated:YES completion:^{
        
    }];
    WorkoutViewController *workoutVC = (WorkoutViewController *) self.destinationViewController;
    [parentNav pushViewController:self.destinationViewController animated:YES];
    
}

@end
