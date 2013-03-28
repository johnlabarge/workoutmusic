//
//  WorkoutTimeSetSegue.m
//  WorkoutMusic
//
//  Created by La Barge, John on 3/25/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import "WorkoutTimeSetSegue.h"
#import "WorkoutTimeViewController.h"
@implementation WorkoutTimeSetSegue
- (void) perform {
    
    
    
    UIViewController *src = (UIViewController *) self.sourceViewController;
    UIViewController *dst = (UIViewController *) self.destinationViewController;
    
    
    
    WOMusicAppDelegate * app = [[UIApplication sharedApplication] delegate];
    WorkoutTimeViewController * wtvc = (WorkoutTimeViewController *) src;
    wtvc.workoutlist.workoutTime =  wtvc.selectedTime;
    
    [UIView transitionWithView:src.view duration:0.8
     
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        
                        UINavigationController * navController = (UINavigationController *) app.window.rootViewController;
                        [navController pushViewController:dst animated:YES];
                    }
     
                    completion:NULL];
    
    
}

@end
