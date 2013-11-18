//
//  EditWorkoutSegue.m
//  WorkoutMusic
//
//  Created by John La Barge on 11/16/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import "EditWorkoutSegue.h"
#import "Workout.h"
#import "IndividualWorkout.h"
#import "WorkoutDesignerVC.h"

@implementation EditWorkoutSegue
-(void) perform
{
    IndividualWorkout * iw = (IndividualWorkout *) self.sourceViewController;
    UIViewController * parent = [iw presentingViewController];
    UINavigationController *parentNav =(UINavigationController *) parent;
    [iw dismissViewControllerAnimated:YES completion:^{
        
    }];
    [parentNav pushViewController:self.destinationViewController animated:YES];
    
}
@end
