//
//  Tempo.h
//  WorkoutMusic
//
//  Created by John La Barge on 11/21/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SLOW 0
#define MEDIUM 1
#define FAST 2
#define VERYFAST 3

@interface Tempo : NSObject 
+(NSString *) speedDescription:(NSInteger)speed;
+(NSString *) tempoClassificationForBPM:(double)bpm;
+(NSInteger) classifySpeed:(double)bpm;
+(BOOL)isSlow:(double)bpm;
+(BOOL)isMedium:(double)bpm;
+(BOOL)isFast:(double)bpm;
+(BOOL)isVeryFast:(double)bpm;
+(NSArray *) ranges;
+(NSArray *) slowRange;
+(NSArray *) mediumRange;
+(NSArray *) fastRange;
+(NSArray *) veryFastRange;
@end
