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
typedef NS_ENUM(NSInteger, OverrideState) {
        Clear_Override,
        Execute_Override,
        No_Override
};
@property (nonatomic, weak) MusicLibraryItem * musicItem;
-(void)glow;
@end
