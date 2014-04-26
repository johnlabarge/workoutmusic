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
#import "SJPlaylists.h"
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
    [self setInstance:sharedInstnace];
    return sharedInstnace;
}


-(instancetype) initWithLibrary:(MusicLibraryBPMs *) library {
    self.bpmLibrary = library;
    listmakerqueue = dispatch_queue_create("listmaker",NULL);
    return self;
}

-(BOOL) generateListForWorkout:(Workout *) workout afterGenerated:(void(^)(void))after
{
    __weak typeof(self) me = self;
    NSLog(@"generate List For Workout");
    NSLog(@"workout intervals : %d",workout.intervals.count);
    dispatch_async(listmakerqueue, ^{
        NSMutableArray  * listItems = [[NSMutableArray alloc] initWithCapacity:workout.intervals.count];
        [workout.intervals enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSLog(@"workout Interval : %d", idx);
            WorkoutInterval * interval = (WorkoutInterval *) obj;
            WorkoutListItem * listItem = [[WorkoutListItem alloc] initWithInterval:interval];
            
            NSArray * musicItems = [me.bpmLibrary randomItemsForTempo:interval.speed andDuration:interval.intervalSeconds];
            
            if (musicItems.count > 0) {
                NSInteger secondsPerSong = interval.intervalSeconds/musicItems.count;
               [musicItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [listItem addSongJockeySong:[me songJockeySongForSeconds:secondsPerSong ofMusicItem:(MusicLibraryItem *)obj]];
                }];
               
            } else {
                NSLog(@"Zero listItems for interval %d", idx);
            }
            [listItems addObject:listItem];
            
        }];
        me.workoutListItems = listItems;
        
        after();
        
    });
    return YES;
}

-(NSUInteger) numberOfSongsPerInterval:(NSInteger)interval
{
    WorkoutListItem * item = self.workoutListItems[interval];
    NSArray * songs = item.songs;
    
    //NSLog(@" workoutListItems for interval-%d:%d",interval,songs.count);
    return songs.count;
}

-(NSUInteger) numberOfIntervals
{
    return self.workoutListItems.count;
}

-(NSArray *) songsForInterval:(NSInteger)interval
{
    return self.workoutListItems[interval];
}

-(SongJockeySong *) songJockeySongForSeconds:(NSInteger)seconds ofMusicItem:(MusicLibraryItem *)item
{
    SongJockeySong * toReturn = [[SongJockeySong alloc] initWithItem:item.mediaItem];
    toReturn.seconds = seconds;
    toReturn.userInfo[@"bpm"] = [NSNumber numberWithDouble:item.bpm];
    return toReturn;
}


-(SJPlaylist *)toSJPlaylist
{
    __block SJPlaylist * toReturn = [[SJPlaylist alloc] init];
    [self.workoutListItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        WorkoutListItem * item = (WorkoutListItem *)obj;
        [item.songs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SongJockeySong * song = obj;
            song.userInfo[@"workoutInterval"] = item.workoutInterval;
            [toReturn addSong:obj];
        }];
    }];
    return toReturn;
    
}

-(NSInteger) startIndexForWorkoutListItem:(WorkoutListItem *)item
{
    NSInteger itemIndex = [self.workoutListItems indexOfObject:item];
    __block NSInteger songsBefore = 0;
    [self.workoutListItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx == itemIndex) *stop = YES;
        else {
            WorkoutListItem * item = (WorkoutListItem *) obj;
            songsBefore += item.songs.count;
        }
    }];
    return songsBefore;
}
-(NSInteger) playListIndex:(WorkoutListItem *) item andSong: (SongJockeySong *) song;
{
    return [self startIndexForWorkoutListItem:item] + [item.songs indexOfObject:song];
}
@end
