//
//  WorkoutListItem.h
//  WorkoutMusic
//
//  Created by John La Barge on 11/21/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MusicLibraryBPMs.h"
#import "WorkoutInterval.h"
#import "SongInstruction.h"

@interface WorkoutListItem : NSObject
@property (nonatomic, readonly) NSArray * songInstructions;
@property (nonatomic, strong) WorkoutInterval * workoutInterval;
@property (readonly) NSString * speedDescription;

-(instancetype) initWithInterval:(WorkoutInterval *)interval;
-(void) addSongInstruction:(SongInstruction *)instruction;

@end