//
//  ModalTransitioningControllerDelegate.m
//  WorkoutMusic
//
//  Created by John La Barge on 6/29/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import "ModalTransitioningControllerDelegate.h"

@implementation ModalTransitioningControllerDelegate


-(instancetype) init
{
    self.presenting = YES;
    return self;
}

#pragma mark UIViewControllerTransitionDelegate
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

// This is used for percent driven interactive transitions, as well as for container controllers that have companion animations that might need to
// synchronize with the main animation.
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}
// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController * toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController * fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    
    if (self.presenting) {
        


        //[[transitionContext containerView] addSubview:fromViewController.view];
       
        //fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        if (self.fromRect.size.height == 0) {
            toViewController.view.frame = CGRectMake(0,-fromViewController.view.bounds.size.height,fromViewController.view.bounds.size.width,fromViewController.view.bounds.size.height);
            [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                toViewController.view.frame = CGRectMake(0,0,fromViewController.view.bounds.size.width, fromViewController.view.bounds.size.height);
                
            } completion:^(BOOL finished) {
                
                [transitionContext completeTransition:YES];
                self.presenting = NO;
            }];
        } else {
            toViewController.view.frame = self.fromRect;
             [[transitionContext containerView] addSubview:toViewController.view];
            [UIView animateWithDuration:3.0 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:1.0 options:
             UIViewAnimationOptionCurveEaseIn animations:^{
           //      toViewController.view.frame = CGRectMake(0,0,fromViewController.view.bounds.size.width, fromViewController.view.bounds.size.height);
                 
                 
             } completion:^(BOOL finished) {
                 [transitionContext completeTransition:YES];
                 self.presenting = NO;
                 
             }];
        }
        
    } else {
        
        [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            fromViewController.view.frame = CGRectMake(0,0,toViewController.view.bounds.size.width, -toViewController.view.bounds.size.height);
            toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
        } completion:^(BOOL finished) {
            [fromViewController.view removeFromSuperview];
            [transitionContext completeTransition:YES];
        }];
        
    }
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
}
-(void)animationEnded:(BOOL)transitionCompleted {
    
}

@end
