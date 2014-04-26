//
//  Tempo.m
//  WorkoutMusic
//
//  Created by John La Barge on 12/1/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import "Tempo.h"
#import "NSArray+Range.h"

@implementation Tempo

+(NSArray *) intensities
{
    static NSArray * intensities;
    if (!intensities) {
        intensities = @[@"Low", @"Medium", @"High", @"Very High", @"Unknown"];
    }
    return intensities;
    
}
+(NSUInteger) toIntensityNum:(NSString *)tempo{
    return [[self classifications] indexOfObject:tempo];
}

+(NSString *) tempoToIntensity:(NSString *) tempo {
    NSUInteger index = [[self classifications] indexOfObject:tempo];
    return [self intensities][index];
}


+(NSArray *)classifications
{
    static NSArray *speedDescriptions;

    if (!speedDescriptions) {
        speedDescriptions = @[@"Slow", @"Medium", @"Fast", @"Very Fast", @"Unknown"];
        
    }
    return speedDescriptions;
}


+(NSString *) speedDescription:(NSInteger)speed
{
    NSArray * speedDescriptions = [self classifications];
    if (speed >= 0 && speed < speedDescriptions.count) {
        return speedDescriptions[speed];
    } else {
        return @"Unknown";
    }
}


+(NSString *) tempoClassificationForBPM:(double)bpm
{
    return [self speedDescription:[self classifySpeed:bpm]];
}
+(NSArray *) ranges {
    static NSArray * ranges;
    if (!ranges) {
        ranges = @[
                   [self slowRange],
                   [self mediumRange],
                   [self fastRange],
                   [self veryFastRange],
                   ];
    }
    return  ranges;
}
+(NSArray *) slowRange {
    static NSArray * slowRange;
    if (!slowRange) {
        slowRange = @[@60, @95];
    }
    return slowRange;
}

+(NSArray *) mediumRange {
    static NSArray * mediumRange;
    if (!mediumRange) {
        mediumRange = @[@96, @125];
    }
    return mediumRange;
}

+(NSArray *) fastRange {
    static NSArray * fastRange;
    if (!fastRange) {
        fastRange = @[@126, @159];
    }
    return fastRange;
}

+(NSArray *) veryFastRange {
    static NSArray * veryFastRange;
    if (!veryFastRange) {
        veryFastRange = @[@160, @400];
    }
    return veryFastRange;
}

+(NSInteger) classifySpeed:(double)bpm
{
    if ([self isSlow:bpm]) {
        return SLOW;
    } else if ([self isMedium:bpm]) {
        return MEDIUM;
    } else if ([self isFast:bpm]) {
        return FAST;
    } else if ([self isVeryFast:bpm]) {
        return VERYFAST;
    } else {
        return -1;
    }
}

+(BOOL) isSlow:(double)bpm {
    return [[self slowRange] fallsWithin:bpm];
}
+(BOOL) isMedium:(double)bpm {
    return [[self mediumRange] fallsWithin:bpm];
}
+(BOOL) isFast:(double)bpm {
   return [[self fastRange] fallsWithin:bpm];
}
+(BOOL) isVeryFast:(double)bpm {
   return [[self veryFastRange] fallsWithin:bpm];
}
@end
