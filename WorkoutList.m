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
    [self reloadLibrary];
    return self;
}

-(void) reloadLibrary {
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

}
-(NSArray *) missingCategories
{
    NSArray * intensities = [Tempo classifications];
    NSMutableArray * missing = [[NSMutableArray alloc] initWithCapacity:5];
    [intensities enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSString * classification = (NSString *) obj;
        NSArray * songsForClassification = (NSArray *)self.shuffledSongsByIntensity[classification];
        if  (!songsForClassification || songsForClassification.count == 0)
        {
            [missing addObject:obj];
        }
    }];
    NSMutableArray * result = [[NSMutableArray alloc] initWithCapacity:5];
    [missing enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString * classification  = (NSString *)obj;
       
        if (![classification isEqualToString:@"Unknown"]) {
            [result addObject:intensities[[Tempo toIntensityNum:classification]]];
        }
        
    }];
    return result;
}
-(NSArray *) randomItemsForClassification:(NSString *) classification andDuration:(NSInteger)secondsLength {
    NSMutableArray * array  = [[NSMutableArray alloc] initWithCapacity:3];
    __weak NSMutableArray *list = array;
    __block NSMutableArray * shuffledLibrary = self.shuffledSongsByIntensity[classification];
    __block NSInteger totalLength = secondsLength;
    [shuffledLibrary enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         
         MusicLibraryItem * item = (MusicLibraryItem *) obj;
         NSLog(@"adding  %@ - %@",@(idx), item.title);
         [list addObject:item];
         totalLength -= item.durationInSeconds;
         if (totalLength <= 0) {
             NSLog(@"before startFrom first Item is %@",((MusicLibraryItem *)shuffledLibrary[0]).title);
             NSLog(@"circling - idx+1=%@ and count=%@",@(idx+1),@(shuffledLibrary.count));
             
             [shuffledLibrary startFrom:idx+1];
             
             NSLog(@"after startFrom first Item is %@",((MusicLibraryItem *)shuffledLibrary[0]).title);
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

            
        }];
        me.generating = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"dispatching done..");
            me.workoutListItems = listItems;
            after();
        });
     
        
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

-(MPMediaItemArtwork *) firstArtworkForCategory:(NSString *)category
{
    MPMediaItemArtwork * art = nil;
    NSArray * songList;
    if (category) {
        songList = (NSArray *)self.shuffledSongsByIntensity[category];
    } else {
        songList = self.bpmLibrary.libraryItems;
    }
    MusicLibraryItem * item;
    NSInteger index = 0;
    if (songList != nil) {
        while (!art && index < songList.count) {
            if (index < songList.count) {
                item = (MusicLibraryItem *)songList[index];
                art = item.artwork;
                index++;
            }
        }
    }
    return art;
    
}

-(BOOL)canGenerateWorkout:(Workout *)workout {
    __block BOOL result = YES;
    NSArray * categories = [workout getCategories];
    NSArray * intensities = [Tempo classifications]; 
    [categories enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSInteger categoryIndex = [((NSNumber *)obj) integerValue];
        NSString * classification = intensities[categoryIndex];
        NSArray * songsForClassification = (NSArray *)self.shuffledSongsByIntensity[classification];
        if (!songsForClassification.count) {
                    result = NO;
                    *stop = YES;
        }
    }];
    return result;
}
@end
