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
    
    [UIView transitionWithView:src.view duration:0.5 options:UIViewAnimationOptionCurveEaseOut animations:NULL completion:^(BOOL finished) {
        if (finished) {
            __weak WOMusicAppDelegate * app = (WOMusicAppDelegate *)[[UIApplication sharedApplication] delegate];
            if ([dst isMemberOfClass:[UITabBarController class]]) {
                /*Since the splash is the rootViewController hanging the tabs on during this transition.
                 TODO : do this a better way.
                 */
                app.tabs = (UITabBarController *)dst;
                
            }
            NSArray *subViewArray = [app.window subviews];
            for (id obj in subViewArray)
            {
                [obj removeFromSuperview];
            }
            app.window.rootViewController = dst;
            
            NSLog(@"app.tabs.delegate %@", [app.tabs.delegate description]);
            NSLog(@"app.tabs %@",[app.tabs description]);
        }
    }];

    
}

@end
