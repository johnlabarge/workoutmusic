//
//  MusicItemCellTableViewCell.h
//  WorkoutMusic
//
//  Created by John La Barge on 4/1/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicLibraryBPMs.h"

@interface MusicItemCell : UITableViewCell
@property (nonatomic, weak) MusicLibraryItem * musicItem;
@end
