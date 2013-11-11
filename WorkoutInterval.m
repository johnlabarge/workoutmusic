//
//  WorkoutInterval.m
//  WorkoutInterval
//
//  Created by John La Barge on 10/12/13.
//
//

#import "WorkoutInterval.h"

@implementation WorkoutInterval

-(instancetype) initForWorkout:(Workout *)workout
{
    self = [super init];
    _workout = workout;
    _intervalSeconds = 60;
    _speed = MEDIUM;
    return self;
}
-(instancetype) initFromDict:(NSDictionary *)dict forWorkout:(Workout *)workout
{
    self = [super init];
    _workout = workout;
    _intervalSeconds  = [ (NSNumber *)[dict objectForKey:@"intervalSeconds"] intValue];
    _speed = [ (NSNumber *)[dict objectForKey:@"speed"] intValue];
    return self;
}

-(NSDictionary *) toDict
{
    NSMutableDictionary *retDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    [retDict setObject:[NSNumber numberWithInt:self.intervalSeconds] forKey:@"intervalSeconds"];
    [retDict setObject:[NSNumber numberWithInt:self.speed] forKey:@"speed"];
    return retDict;
}

-(NSString *) representation {
    return [NSString stringWithFormat:@"%d", self.speed];
}

-(void) setIntervalSeconds:(NSInteger)intervalSeconds
{
    _intervalSeconds = intervalSeconds;
    [self.workout intervalChanged:self];
}
-(void) setSpeed:(NSInteger)speed
{
    _speed = speed;
    [self.workout intervalChanged:self];
}
-(void) dealloc
{
    self.workout = nil;
}
@end
