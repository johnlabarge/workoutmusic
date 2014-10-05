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
  
    WorkoutViewController *workoutVC = (WorkoutViewController *) self.destinationViewController;
   /* UIViewController * parent = [iw presentingViewController];*/
    WOMusicAppDelegate * app = (WOMusicAppDelegate *) [UIApplication sharedApplication].delegate;
    UITabBarController * parent = app.tabs;
    
    /*UINavigationController *parentNav =(UINavigationController *) parent;
    [iw dismissViewControllerAnimated:YES completion:^{
        workoutVC.workout = iw.workout;
    }];*/
    
    UINavigationController * nav = (UINavigationController *) parent.selectedViewController;
    [nav pushViewController:workoutVC animated:YES];
 
  
  
        
}

@end
