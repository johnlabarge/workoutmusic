//
//  ModalTransitioningControllerDelegate.h
//  WorkoutMusic
//
//  Created by John La Barge on 6/29/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModalTransitioningControllerDelegate : NSObject <UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

@property (assign, nonatomic) BOOL presenting;

@property (assign, nonatomic) CGRect fromRect; 
@end
