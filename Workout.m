//
//  Workout.m
//  WorkoutInterval
//
//  Created by John La Barge on 10/12/13.
//
//

#import "Workout.h"
#import "WorkoutInterval.h"
#import "Workouts.h"

@implementation Workout
+(NSString *) pathToWorkout:(NSString *)workoutName

{
    
    
    return [[Workouts path] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json",workoutName]];

}
-(id) init
{
    self = [super init];
    
    _name = @"untitled";
    _intervals = [[NSMutableArray alloc] initWithCapacity:20];
    WorkoutInterval * firstInterval = [[WorkoutInterval alloc] initForWorkout:self];
    firstInterval.speed = SLOW;
    
    
    [self.intervals addObject:firstInterval];
    [self recalculate];
    
    
    return self;
}

-(id) initFromDict:(NSDictionary *) dict
{
    
    _name = [dict objectForKey:@"name"];
    _workoutSeconds = [(NSNumber *)[dict objectForKey:@"workoutSeconds"] intValue];
    
    self.intervals = [[NSMutableArray alloc] initWithCapacity:20];
    NSArray * intervalDicts = (NSArray *)[dict objectForKey:@"intervals"];
    [intervalDicts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary * intervalDict =  (NSDictionary *) obj;
        [self.intervals addObject:[[WorkoutInterval alloc] initFromDict:intervalDict forWorkout:self]];
    }];
    return self;
}


-(void) setName:(NSString *)name
{
    NSLog(@"changing name from %@ to %@", _name, name);
    if (![name isEqualToString:_name]) {
        NSError * error;
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        if ([fileMgr fileExistsAtPath:[Workout pathToWorkout:_name]]) {
            NSLog(@"Saving with name: %@",_name); 
            [[NSFileManager defaultManager] removeItemAtPath:[Workout pathToWorkout:self.name] error:&error];
            _name = name;
            if (error) {
                NSLog(@" couldn't remove old file..");
            }
            [self save];
        }
    }
   
}
-(NSDictionary *) toDict
{
    NSMutableDictionary * workoutDict = [[NSMutableDictionary alloc] initWithCapacity:3];
    NSMutableArray * workoutIntervals = [[NSMutableArray alloc] initWithCapacity:[self.intervals count]];
    
    [workoutDict setObject:self.name forKey:@"name"];
    [workoutDict setObject:[NSNumber numberWithInt:self.workoutSeconds] forKey:@"workoutSeconds"];
    
    [self.intervals enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        WorkoutInterval * interval = (WorkoutInterval *) obj;
        [workoutIntervals addObject:[interval toDict]];
    }];
    
    [workoutDict setObject:workoutIntervals forKey:@"intervals"];
    
    return workoutDict;
}

-(void) save
{
    [self saveAs:self.name];
}
-(void) saveAs:(NSString *)workoutName
{
    NSDictionary * foundationVersion =  [self toDict];
    
    NSString *path = [Workout pathToWorkout:workoutName];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:foundationVersion                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        NSLog(@"writing json to path: %@", path); 
        [jsonData writeToFile:path atomically:YES];
    }

}





-(WorkoutInterval *) newInterval
{
    WorkoutInterval * interval = [[WorkoutInterval alloc] initForWorkout:self];
    interval.speed = 0;
    
    [self.intervals addObject:interval];
    
    
    [self recalculate];
    [self save];
    return interval;
    
}



-(void) recalculate
{
    __block NSInteger totalSeconds =0;
    [self.intervals enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        WorkoutInterval * interval = (WorkoutInterval *) obj;
        totalSeconds += interval.intervalSeconds;
        
    }];
    self.workoutSeconds = totalSeconds;
    
}

-(void) deleteInterval:(WorkoutInterval *)interval {
    [self.intervals removeObject:interval];
}

-(void) renameFile:(NSString*)newName
{
  
    NSError *error;
    
    [[NSFileManager defaultManager] moveItemAtPath:[Workout pathToWorkout:self.name] toPath:[Workout pathToWorkout:newName] error:&error];

}
-(void) dealloc
{
    [self.intervals enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
       // [obj removeObserver:self forKeyPath:@"intervalSeconds"];
    }];
}

-(void) intervalChanged:(WorkoutInterval *)sender
{
    [self recalculate];
    [self save];
}
@end
