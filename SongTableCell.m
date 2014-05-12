//
//  SongTableCell.m
//  WorkoutMusic
//
//  Created by John La Barge on 11/29/12.
//  Copyright (c) 2012 John La Barge. All rights reserved.
//

#import "SongTableCell.h"

@implementation SongTableCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionOld context:nil];

    }
    return self;
}
-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
       //[self.contentView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setArtworkImage:(UIImage *)inImage
{
    _artworkImage = inImage;
    self.artworkImageView.image = _artworkImage;
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  //  NSLog(@"observed value for kp %@ changed: %@",keyPath,change);
    if ( [keyPath isEqual:@"frame"] && object == self.contentView )
    {
        CGRect newFrame = self.contentView.frame;
        CGRect oldFrame = [[change objectForKey:NSKeyValueChangeOldKey] CGRectValue];
        //    NSLog(@"frame old: %@  new: %@",NSStringFromCGRect(oldFrame),NSStringFromCGRect(newFrame));
        
        if ( newFrame.origin.x != 0 ) self.contentView.frame = oldFrame;
    }
}
-(void)dealloc{
    // [self.contentView removeObserver:self forKeyPath:@"frame"];
}
@end
