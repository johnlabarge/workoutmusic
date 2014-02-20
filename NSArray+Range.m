//
//  NSArray+Range.m
//  WorkoutMusic
//
//  Created by John La Barge on 2/20/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import "NSArray+Range.h"

@implementation NSArray (Range)
-(BOOL)fallsWithin:(double)num {
    return (num >= [self[0] doubleValue] && num <= [self[1] doubleValue]);
}
@end
