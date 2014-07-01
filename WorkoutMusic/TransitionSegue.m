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
    WOMusicAppDelegate * app = (WOMusicAppDelegate *)[[UIApplication sharedApplication] delegate];

    UIWindow * window = app.window;
    UITabBarController *dst = (UITabBarController *) self.destinationViewController;
    [UIView transitionWithView:window
                      duration:0.3
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        window.rootViewController = dst;
                        
                    } completion:^(BOOL finished) {
                        
                        if( finished )  {
                            app.tabs = dst;
                        }
                    }];
    
    
}

@end
