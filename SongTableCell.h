//
//  SongTableCell.h
//  WorkoutMusic
//
//  Created by John La Barge on 11/29/12.
//  Copyright (c) 2012 John La Barge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SongTableCell : UITableViewCell 

@property (nonatomic, strong) IBOutlet UILabel * tempoClass;
@property (nonatomic, strong) IBOutlet UILabel * time;
@property (nonatomic, strong) IBOutlet UIImageView *artworkImageView;
@property (nonatomic, strong) UIImage * artworkImage;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) NSString *description;
@property (weak, nonatomic) IBOutlet UILabel *bpmLabel;

@end
