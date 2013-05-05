//
//  WorkoutGraph.h
//  WorkoutGraphic
//
//  Created by La Barge, John on 3/29/13.
//  Copyright (c) 2013 La Barge, John. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WorkoutGraph : UIView


@property (nonatomic, assign) NSInteger numberOfIntervals;
@property (nonatomic, assign) NSInteger activeinterval;
@property (nonatomic, strong) NSArray * intervals;
@property (nonatomic, assign) NSInteger currentInterval;

-(void) startAnimate;
-(void) stopAnimate;

@end




