//
//  NewWorkoutCell.m
//  WorkoutMusic
//
//  Created by John La Barge on 2/5/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import "NewWorkoutCell.h"

@implementation NewWorkoutCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)dispatchAdd:(id)sender {
    [self.delegate perform:self.addButton actionInfo:@{@"action":@"newWorkout"}];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
