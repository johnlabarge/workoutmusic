//
//  TimeUtils.m
//  WorkoutMusic
//
//  Created by La Barge, John on 3/28/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import "TimeUtils.h"

@implementation TimeUtils
+(NSString *)minutesColonSeconds:(NSInteger)seconds
{
    NSInteger minutes = seconds/60;
    NSInteger remainingSeconds = seconds - (minutes*60);
    NSString * remainingSecondsS;
    if (remainingSeconds < 10) {
        remainingSecondsS = [NSString stringWithFormat:@"0%lu",remainingSeconds];
    } else {
        remainingSecondsS = [NSString stringWithFormat:@"%lu", remainingSeconds];
    }
    
    NSString * ret = [NSString stringWithFormat:@"%lu:%@",minutes, remainingSecondsS];
    return ret; 
}
@end
