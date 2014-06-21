//
//  MusicCategoryCell.m
//  WorkoutMusic
//
//  Created by John La Barge on 6/7/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import "MusicCategoryCell.h"
#import "MusicLibraryBPMs.h"

@interface MusicCategoryCell()
@property (readonly) MusicLibraryBPMs * library;
@end

@implementation MusicCategoryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setCategoryText:(NSString *)categoryText
{
    _categoryText = categoryText;
    [self updateText];
}
-(void) setCount:(NSInteger)count
{
    _count = count;
    [self updateText];
}
-(void) updateText
{
    if ([_categoryText rangeOfString:@"All"].location != NSNotFound  ) {
        self.categoryLabel.text = [NSString stringWithFormat:@"All Songs(%lu)",self.count];
        
    } else {
        
        self.categoryLabel.text = [NSString stringWithFormat:@"%@ Intensity Songs(%lu)", self.categoryText,self.count];
    }
}


@end
