//
//  SongTableCell.h
//  WorkoutMusic
//
//  Created by John La Barge on 11/29/12.
//  Copyright (c) 2012 John La Barge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeLabel.h"

@interface SongTableCell : UITableViewCell 

@property (nonatomic, strong) IBOutlet UILabel * tempoClass;
@property (nonatomic, strong) IBOutlet TimeLabel * time;
@property (nonatomic, strong) IBOutlet UIImageView *artworkImageView;
@property (nonatomic, strong) UIImage * artworkImage;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, copy) NSString *songDescription;
@property (weak, nonatomic) IBOutlet UILabel *bpmLabel;

@end
