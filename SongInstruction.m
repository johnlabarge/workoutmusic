//
//  SongInstruction.m
//  WorkoutMusic
//
//  Created by John La Barge on 11/29/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import "SongInstruction.h"
#import "MusicLibraryBPMs.h"
@implementation SongInstruction
-(instancetype) initWithMusicItem:(MusicLibraryItem *)item start:(NSInteger)start andEnd:(NSInteger)end
{
    self = [super init];
    self.musicItem = item;
    return self;
}
@end
