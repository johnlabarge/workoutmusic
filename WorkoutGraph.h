//
//  WorkoutGraph.h
//  WorkoutGraphic
//
//  Created by La Barge, John on 3/29/13.
//  Copyright (c) 2013 La Barge, John. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Workout.h"

@interface WorkoutGraph : UIView

@property (nonatomic, strong) Workout * workout; 
@property (nonatomic, assign) NSInteger numberOfIntervals;
@property (nonatomic, assign) NSInteger activeinterval;
@property (nonatomic, strong) NSArray * intervals;
@property (nonatomic, assign) NSInteger currentInterval;
@property (nonatomic, assign) BOOL active; 

-(void) startAnimate;
-(void) stopAnimate;
-(void) reloadData; 
@end




