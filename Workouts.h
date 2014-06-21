//
//  Workouts.h
//  WorkoutInterval
//
//  Created by La Barge, John on 10/27/13.
//
///Developer/WorkoutInterval/WorkoutInterval/Workout.h

#import <Foundation/Foundation.h>


@interface Workouts : NSObject
+(NSString *)path;
+(NSArray *)list;
+(void) copySampleWorkoutToDirectory;
+(BOOL) workoutsInDirectory; 
@end
