//
//  Workout.h
//  WorkoutInterval
//
//  Created by John La Barge on 10/12/13.
//
//
#import "WorkoutInterval.h"
#import <Foundation/Foundation.h>
@class WorkoutInterval;

@interface Workout : NSObject
@property (nonatomic, strong) NSMutableArray * intervals;
@property (readwrite, assign) NSInteger workoutSeconds;
@property (nonatomic, strong) NSString * name;
+(NSString *) pathToWorkout:(NSString *)workoutName;
-(instancetype) initFromDict:(NSDictionary *) dict;
-(WorkoutInterval *) newInterval;
-(void) deleteInterval:(WorkoutInterval *)interval; 
-(void) recalculate;
-(void) save;
-(void) renameFile:(NSString *)newName;
-(void) intervalChanged:(WorkoutInterval *)sender; 
@end
