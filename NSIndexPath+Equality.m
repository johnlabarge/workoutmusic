//
//  NSIndexPath+Equality.m
//  WorkoutMusic
//
//  Created by John La Barge on 8/17/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import "NSIndexPath+Equality.h"

@implementation NSIndexPath (Equality)
-(BOOL) isEqual:(id)object
{
    BOOL result = NO;
    if ([object isKindOfClass:[NSIndexPath class]]) {
        NSComparisonResult  comparison = [self compare:object];
        result = (comparison == NSOrderedSame);
    }
    return result;
}
@end
