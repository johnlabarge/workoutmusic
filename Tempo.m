//
//  Tempo.m
//  WorkoutMusic
//
//  Created by John La Barge on 12/1/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import "Tempo.h"

@implementation Tempo
+(NSString *) speedDescription:(NSInteger)speed
{
    switch (speed) {
        case SLOW:
            return @"Slow";
        case MEDIUM:
            return @"Medium";
        case FAST:
            return @"Fast";
        case VERYFAST:
            return @"Very Fast";
    }
    return nil;
}
@end
