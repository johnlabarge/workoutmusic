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
#import "NSMutableArray+Circular.h"

@interface WorkoutList()
@property (nonatomic, assign) BOOL generating;
@property (nonatomic, strong) NSMutableDictionary * shuffledSongsByIntensity;
@end


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
    self.shuffledSongsByIntensity = [[NSMutableDictionary alloc] initWithCapacity:[Tempo classifications].count];
      __weak typeof(self) me = self;
      __weak NSMutableDictionary * songs = self.shuffledSongsByIntensity;
    [[Tempo classifications] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString * classification = (NSString *)obj;
        NSMutableArray * songList = [me.bpmLibrary randomItemsForIntensity:classification];
        if (songList) {
            songs[classification] = songList;
        }
        
    }];
    return self;
}

-(NSArray *) randomItemsForClassification:(NSString *) classification andDuration:(NSInteger)secondsLength {
    NSMutableArray * array  = [[NSMutableArray alloc] initWithCapacity:3];
    __weak NSMutableArray *list = array;
    __weak NSMutableArray * shuffledLibrary = self.shuffledSongsByIntensity[classification];
    __block NSInteger totalLength = secondsLength;
    [shuffledLibrary enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         MusicLibraryItem * item = (MusicLibraryItem *) obj;
         [list addObject:item];
         totalLength -= item.durationInSeconds;
         if (totalLength <= 0) {
             [shuffledLibrary startFrom:idx+1];
             *stop = YES;
         }
         
     }];
                                               
    return array;
}



-(BOOL) generateListForWorkout:(Workout *) workout afterGenerated:(void(^)(void))after
{
 
    __weak typeof(self) me = self;

    dispatch_async(listmakerqueue, ^{
        me.generating = YES;
        self.workoutListItems = nil; 
        NSMutableArray  * listItems = [[NSMutableArray alloc] initWithCapacity:workout.intervals.count];
        [workout.intervals enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            WorkoutInterval * interval = (WorkoutInterval *) obj;
            WorkoutListItem * listItem = [[WorkoutListItem alloc]
                                          initWithInterval:interval];
            
            NSArray * musicItems = [me randomItemsForClassification:[Tempo speedDescription:interval.speed] andDuration:interval.intervalSeconds];
            
            if (musicItems.count > 0) {
                NSInteger secondsPerSong = interval.intervalSeconds/musicItems.count;
               [musicItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [listItem addSongJockeySong:
                     [me songJockeySongForSeconds:secondsPerSong
                                      ofMusicItem:(MusicLibraryItem *)obj]];
                }];
               
            } else {
                NSLog(@"Zero listItems for interval %lu", (unsigned long)idx);
            }
            [listItems addObject:listItem];
            me.generating = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                me.workoutListItems = listItems;
                after();
            });
            
        }];
     
        
    });
    return YES;
}

-(NSUInteger) numberOfSongsPerInterval:(NSInteger)interval
{
    if (self.generating) {
        return 0;
    } else {
        WorkoutListItem * item = self.workoutListItems[interval];
        NSArray * songs = item.songs;
    
    //NSLog(@" workoutListItems for interval-%d:%d",interval,songs.count);
        return songs.count;
    }
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
