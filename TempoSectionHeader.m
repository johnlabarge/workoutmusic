//
//  TempoSectionHeader.m
//  WorkoutMusic
//
//  Created by John La Barge on 5/26/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import "TempoSectionHeader.h"

@interface TempoSectionHeader()

@end
@implementation TempoSectionHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self)
    {
        NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"TempoSectionHeader"
                                                         owner:self
                                                       options:nil];
        UIView *nibView = [objects firstObject];
        UIView *contentView = self.contentView;
        CGSize contentViewSize = contentView.frame.size;
        nibView.frame = CGRectMake(0, 0, contentViewSize.width, contentViewSize.height);
        [contentView addSubview:nibView];
      
    }
    return self;
}




-(void)awakeFromNib {
    
}

 


@end
