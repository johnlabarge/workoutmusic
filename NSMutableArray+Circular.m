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
        for (NSInteger i=0; i < pivot; i++) {
            id object = self[0];
            [self removeObjectAtIndex:0];
            [self addObject:object];
        }
    }
    
}


@end
