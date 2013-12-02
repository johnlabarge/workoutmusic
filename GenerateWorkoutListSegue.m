//
//  GenerateWorkoutListSegue.m
//  WorkoutMusic
//
//  Created by La Barge, John on 3/18/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import "GenerateWorkoutListSegue.h"
#import "PlayerViewController.h"

@implementation GenerateWorkoutListSegue
- (void) perform {
    
    
    
    UIViewController *src = (UIViewController *) self.sourceViewController;
    PlayerViewController  * player = (PlayerViewController *) self.destinationViewController;
   // UIViewController *dst = (UIViewController *) self.destinationViewController;
    
    
    
    WOMusicAppDelegate * app = [[UIApplication sharedApplication] delegate];
    SuperViewController * svc = (SuperViewController *) src;
    svc.workoutlist.workoutType = self.identifier;
    /*
    BOOL listGenerated = [svc.workoutlist generateList:^{
        
        NSLog(@"\n\n after generated!!");
        
        [UIView transitionWithView:src.view duration:0.8
         
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^{
                            
                            UINavigationController * navController = (UINavigationController *) app.window.rootViewController;
                            [navController pushViewController:player animated:YES];
                        }
         
                        completion:NULL];
        
    }];
    */

    
    
}
@end
