//
//  WorkoutListItem.m
//  WorkoutMusic
//
//  Created by John La Barge on 11/21/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import "WorkoutListItem.h"

@interface WorkoutListItem()
@property (nonatomic, strong) NSMutableArray * instructions;
@end
@implementation WorkoutListItem

-(instancetype) initWithInterval:(WorkoutInterval *)interval
{
    self = [super init];
    self.workoutInterval = interval;
    return self;
}

-(void) addSongInstruction:(SongInstruction *)instruction
{
    if (!self.instructions) {
        self.instructions = [[NSMutableArray alloc] initWithCapacity:2];
    }
    [self.instructions addObject:instruction];
}

-(NSArray *) songInstructions
{
    return [NSArray arrayWithArray:self.instructions];
}

-(NSString *)speedDescription
{
    return [Tempo speedDescription:self.workoutInterval.speed];
}

@end
