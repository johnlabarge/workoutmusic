//
//  WorkoutList.m
//  WorkoutMusic
//
//  Created by La Barge, John on 3/17/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import "WorkoutList.h"
#import "MusicLibraryBPMs.h"
#import "Workout.h"
#import "WorkoutListItem.h"
@implementation WorkoutList


+(id) setInstance:(id)instance
{
    static id myInstance;
    if (instance != nil) {
        myInstance = instance;
    }
    return myInstance;
}

+(id) sharedInstance
{
    return [self setInstance:nil];
}

+(id) instantiateForLibrary:(MusicLibraryBPMs *)library {
    static dispatch_once_t once;
    static id sharedInstnace;
    dispatch_once(&once, ^{
        sharedInstnace = [[self alloc] initWithLibrary:library];
    });
    return sharedInstnace;
}


-(id) initWithLibrary:(MusicLibraryBPMs *) library {
    self.bpmLibrary = library;
    listmakerqueue = dispatch_queue_create("listmaker",NULL);
    return self;
}

-(BOOL) generateListForWorkout:(Workout *) workout afterGenerated:(void(^)(void))after
{
    dispatch_async(listmakerqueue, ^{
        NSMutableArray  * listItems = [[NSMutableArray alloc] initWithCapacity:self.workout.intervals.count];
        [self.workout.intervals enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            WorkoutInterval * interval = (WorkoutInterval *) obj;
            WorkoutListItem * listItem = [[WorkoutListItem alloc] initWithInterval:interval];
            
            NSArray * musicItems = [self.bpmLibrary randomItemsForTempo:interval.speed andDuration:interval.intervalSeconds];
            if (musicItems.count > 0) {
                NSInteger secondsPerSong = interval.intervalSeconds/musicItems.count;
               [musicItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [listItem addSongInstruction:[self songInstructionForSeconds:secondsPerSong ofMusicItem:(MusicLibraryItem *)obj]];
                }];
                [listItems addObject:listItem];
            }
            
            
        }];
        self.workoutListItems = listItems;
        
        after();
        
    });
    return YES;
}

-(SongInstruction *) songInstructionForSeconds:(NSInteger)seconds ofMusicItem:(MusicLibraryItem *)item
{
    NSInteger middle =item.durationInSeconds/2;
    NSInteger halfTime = seconds/2;
    NSInteger theStart = middle-halfTime;
    NSInteger theEnd = middle+halfTime;
    return [[SongInstruction alloc] initWithMusicItem:item start:theStart andEnd:theEnd];
}

-(NSArray *) songInstructionsForInterval:(NSInteger)interval
{
    WorkoutListItem * item = (WorkoutListItem *) [self.workoutListItems objectAtIndex:interval];
    return item.songInstructions;
}
@end
