//
//  MusicCategoryCell.h
//  WorkoutMusic
//
//  Created by John La Barge on 6/7/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MusicCategoryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (nonatomic, strong) NSString * categoryText;
@property (nonatomic, assign) NSInteger count;
@property (weak, nonatomic) IBOutlet UIImageView *firstArtworkImage;
@end
