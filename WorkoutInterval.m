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
    [retDict setObject:[NSNumber numberWithInteger:self.intervalSeconds] forKey:@"intervalSeconds"];
    [retDict setObject:[NSNumber numberWithInteger:self.speed] forKey:@"speed"];
    return retDict;
}

-(NSString *) representation {
    return [NSString stringWithFormat:@"%ld", (long)self.speed];
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
-(id) copyWithZone:(NSZone *)zone
{
    /*
    *TODO : better design.
    * hacked up properties to tell workout of change
    * because of that copy has to use the side door.
    */
    NSNumber * speedNumber = [NSNumber numberWithInteger:self.speed];
    NSNumber * secondsNumber = [NSNumber numberWithInteger:self.intervalSeconds];
    WorkoutInterval *another = [[WorkoutInterval alloc] initFromDict:@{@"intervalSeconds":secondsNumber,@"speed":speedNumber} forWorkout:self.workout];
    another.speed = self.speed;
    another.intervalSeconds = self.intervalSeconds;
    return another;
}

@end
