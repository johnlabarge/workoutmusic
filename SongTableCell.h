//
//  SongTableCell.h
//  WorkoutMusic
//
//  Created by John La Barge on 11/29/12.
//  Copyright (c) 2012 John La Barge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SongTableCell : UITableViewCell {
    UILabel *title;
    UILabel *bpm;

}
@property (nonatomic, retain) IBOutlet UILabel * title;
@property (nonatomic, retain) IBOutlet UILabel * bpm;

@end
