//
//  NSArray+NSArray_Shuffle.m
//  WorkoutMusic
//
//  Created by La Barge, John on 3/16/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import "NSArray+Shuffle.h"
#import <stdlib.h>

@implementation NSArray (Shuffle)

-(NSMutableArray *) shuffle {
    NSMutableArray * shuffled = [[NSMutableArray alloc] init];
    NSUInteger count = self.count;
    
    for (NSUInteger i=0; i < self.count; i++ ){
        [shuffled addObject:[self objectAtIndex:i]];
    }
    //Fisher-Yates shuffle
    for (NSUInteger i=count-1; i > 0; i--) {
        int r = arc4random() % i;
        [shuffled exchangeObjectAtIndex:r withObjectAtIndex:i];
    }
    return shuffled;
}
@end
