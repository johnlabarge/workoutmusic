//
//  SongInstruction.h
//  WorkoutMusic
//
//  Created by John La Barge on 11/29/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//
#import <MediaPlayer/MediaPlayer.h>
#import <Foundation/Foundation.h>
#import "MusicLibraryBPMs.h"

@interface SongInstruction : NSObject
@property (nonatomic, strong) MusicLibraryItem * musicItem;
@property (nonatomic, assign) NSInteger startSeconds;
@property (nonatomic, assign) NSInteger endSeconds;
-(instancetype)initWithMusicItem:(MusicLibraryItem *)item start:(NSInteger)start andEnd:(NSInteger)end; 
@end
