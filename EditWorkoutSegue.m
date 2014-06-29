//
//  EditWorkoutSegue.m
//  WorkoutMusic
//
//  Created by John La Barge on 4/27/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import "EditWorkoutSegue.h"
#import "WOMusicAppdelegate.h"
#import "WorkoutDesignerVC.h"
#import "individualWorkout.h"

@implementation EditWorkoutSegue
-(void) perform
{
    
    WOMusicAppDelegate * app = (WOMusicAppDelegate *) [UIApplication sharedApplication].delegate;
    UITabBarController * parent = app.tabs;
    IndividualWorkout * iw = (IndividualWorkout *) self.sourceViewController;
    UINavigationController * designerNav = (UINavigationController *) parent.viewControllers[1];
    WorkoutDesignerVC * designer = (WorkoutDesignerVC *)designerNav.topViewController;
    designer.model = iw.workout;
    [iw dismissViewControllerAnimated:YES completion:^{
        parent.selectedIndex = 1;

    }];

    
    
   
    
    
    
}

@end
