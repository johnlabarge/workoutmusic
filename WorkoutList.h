//
//  WorkoutList.h
//  WorkoutMusic
//
//  Created by La Barge, John on 3/17/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MusicLibraryBPMS.h" 
#import "Workout.h"
#import "SongJockeySong.h" 
#import "SJPlaylists.h"
#import "WorkoutListItem.h"


@interface WorkoutList : NSObject {
    dispatch_queue_t listmakerqueue;
}
@property (nonatomic, strong) Workout * workout;

@property (nonatomic, strong) NSArray * intervals; 
@property (nonatomic, strong) MusicLibraryBPMs * bpmLibrary;
@property (nonatomic, strong) NSNumber * workoutTime;
@property (nonatomic, strong) NSArray  * workoutListItems;
@property (nonatomic, strong) NSString * workoutType;
@property (nonatomic, strong) NSNumber * currentIntervalIndex;
@property (nonatomic, strong) NSNumber * actualWorkoutTime;

+(id) sharedInstance;
+(id) instantiateForLibrary:(MusicLibraryBPMs *) library;
+(id)setInstance:(id)instance;
-(instancetype)initWithLibrary:(MusicLibraryBPMs *)library; 
-(BOOL) generateListForWorkout:(Workout *) workout afterGenerated:(void(^)(void))after;
-(NSUInteger) numberOfSongsPerInterval:(NSInteger)interval;
-(NSUInteger) numberOfIntervals;
-(NSArray *) songsForInterval:(NSInteger)interval;
-(SJPlaylist *)toSJPlaylist;
-(NSInteger) playListIndex:(WorkoutListItem *) item andSong: (SongJockeySong *) song;
-(void) reloadLibrary;
-(MPMediaItemArtwork *) firstArtworkForCategory:(NSString *)category;

@end
