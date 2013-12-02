//
//  WorkoutListItemCell.h
//  WorkoutMusic
//
//  Created by John La Barge on 12/1/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WorkoutListItemCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *songTitleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *albumArtImageView;
@property (strong, nonatomic) IBOutlet UILabel *intervalSecondsLabel;

@end
