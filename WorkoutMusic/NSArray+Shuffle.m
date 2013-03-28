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

-(NSArray *) shuffle {
    NSMutableArray * shuffled = [[NSMutableArray alloc] init];
    int count = self.count;
    
    for (int i=0; i < self.count; i++ ){
        [shuffled addObject:[self objectAtIndex:i]];
    }
    //Fisher-Yates shuffle
    for (int i=count-1; i > 0; i--) {
        int r = arc4random() % i;
        [shuffled exchangeObjectAtIndex:r withObjectAtIndex:i];
    }
    return shuffled;
}
@end
