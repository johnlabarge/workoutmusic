//
//  WorkoutInterval.h
//  WorkoutInterval
//
//  Created by John La Barge on 10/12/13.
//
//

#import <Foundation/Foundation.h>
#import "Workout.h"
#import "Tempo.h"



#define SLOWINTERVAL @"0"
#define MEDIUMINTERVAL @"1"
#define FASTINTERVAL @"2" 
#define VERYFASTINTERVAL @"3" 
@class Workout;
@interface WorkoutInterval : NSObject
@property (nonatomic, assign) NSInteger intervalSeconds;
@property (nonatomic, assign) NSInteger speed;
@property (nonatomic, strong) Workout * workout;
-(instancetype) initForWorkout:(Workout *)workout;
-(NSString *) representation;
-(id) initFromDict:(NSDictionary *)dict forWorkout:(Workout *)workout;
-(NSDictionary *) toDict; 
@end
