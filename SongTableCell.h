//
//  SongTableCell.h
//  WorkoutMusic
//
//  Created by John La Barge on 11/29/12.
//  Copyright (c) 2012 John La Barge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SongTableCell : UITableViewCell 
@property (nonatomic, strong) IBOutlet UILabel * title;
@property (nonatomic, strong) IBOutlet UILabel * tempoClass;
@property (nonatomic, strong) IBOutlet UILabel * time;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIImage * artworkImage;

@end
