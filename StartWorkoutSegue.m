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
#import "WOMusicAppDelegate.h"
@implementation StartWorkoutSegue
-(void) perform
{
    IndividualWorkout * iw = (IndividualWorkout *) self.sourceViewController;
    WorkoutViewController *workoutVC = (WorkoutViewController *) self.destinationViewController;
   /* UIViewController * parent = [iw presentingViewController];*/
    WOMusicAppDelegate * app = (WOMusicAppDelegate *) [UIApplication sharedApplication].delegate;
    UITabBarController * parent = app.tabs;
    
    
    
    NSLog(@" start workout segue : %lu", (unsigned long)iw.workout.intervals.count);
    /*UINavigationController *parentNav =(UINavigationController *) parent;
    [iw dismissViewControllerAnimated:YES completion:^{
        workoutVC.workout = iw.workout;
    }];*/
    
    UINavigationController * nav = (UINavigationController *) parent.selectedViewController;
    [iw dismissViewControllerAnimated:YES completion:^{
        workoutVC.workout = iw.workout;
        [nav pushViewController:workoutVC animated:YES];
    }];
  
  
        
}

@end
