//
//  WorkoutList.h
//  WorkoutMusic
//
//  Created by La Barge, John on 3/17/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MusicLibraryBPMS.h" 

@interface WorkoutList : NSObject {
    dispatch_queue_t listmakerqueue;
}

@property (nonatomic, strong) NSArray * intervals; 
@property (nonatomic, strong) MusicLibraryBPMs * bpmLibrary;
@property (nonatomic, strong) NSNumber * workoutTime;
@property (nonatomic, strong) NSArray  * workoutSongs;
@property (nonatomic, strong) NSString * workoutType;
@property (nonatomic, strong) NSNumber * currentInterval;
@property (nonatomic, strong) NSNumber * actualWorkoutTime;

-(BOOL) generateList:(void(^)(void))afterGenerated;
-(id) initWithLibrary:(MusicLibraryBPMs *) library;
@end
