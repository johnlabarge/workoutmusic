//
//  TransitionSegue.m
//  WorkoutMusic
//
//  Created by La Barge, John on 3/9/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import "TransitionSegue.h"

@implementation TransitionSegue



- (void) perform {
    
    
    
    UIViewController *src = (UIViewController *) self.sourceViewController;
    UIViewController *dst = (UIViewController *) self.destinationViewController;
    

    
    [UIView transitionWithView:src.view duration:0.8

                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        
                        WOMusicAppDelegate * app = [[UIApplication sharedApplication] delegate];
                        app.window.rootViewController = dst;
                    
                        
                    }
     
    
                    completion:NULL];

    
}

@end
