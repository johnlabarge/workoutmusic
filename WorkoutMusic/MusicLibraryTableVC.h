//
//  MusicLibraryTableVC.h
//  WorkoutMusic
//
//  Created by John La Barge on 11/29/12.
//  Copyright (c) 2012 John La Barge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SongTableCell.h"
#import "MusicLibraryBPMS.h"

@interface MusicLibraryTableVC : UITableViewController
@property (nonatomic, retain) MusicLibraryBPMs * library;
+ (NSArray *) getMusicItems;
- (void) updateMusic;
@end
