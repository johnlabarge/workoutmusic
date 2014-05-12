//
//  NSArray+Circular.m
//  WorkoutMusic
//
//  Created by John La Barge on 5/10/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import "NSMutableArray+Circular.h"

@implementation NSMutableArray (Circular)

-(void)startFrom:(NSUInteger)index {
    
    NSUInteger pivot = index;
    if (pivot >0 && pivot < self.count) {
        NSUInteger pointer = 0;
        while (pointer < pivot) {
            id object = self[pointer];
            [self removeObjectAtIndex:pointer];
            [self addObject:object];
            pointer++;
        }
    }
    
}


@end
