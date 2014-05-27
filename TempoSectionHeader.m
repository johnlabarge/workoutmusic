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
        self.expansionState = NO;
    }
    return self;
}
- (IBAction)doExpansion:(id)sender {

    if (self.expansionState) {
        self.expansionState = NO;
        [self.expansionDelegate contractSection:self.sectionNumber];
    } else {
        self.expansionState = YES;
        [self.expansionDelegate expandSection:self.sectionNumber];
    }
    [self configureExpansionButton];
}

-(void) configureExpansionButton
{
    if (self.expansionState) {
        [self.expansionButton setImage:[UIImage imageNamed:@"contract_section"] forState:UIControlStateNormal];
       // [self.expansionButton setTitle:@"Contract" forState:UIControlStateNormal];

    } else {
        [self.expansionButton setImage:[UIImage imageNamed:@"expand_section"] forState:UIControlStateNormal];


    }
}

-(void)awakeFromNib {
    [self configureExpansionButton];
}

-(void) setExpansionState:(BOOL)expansionState
{
    _expansionState = expansionState;
    [self configureExpansionButton];
}


@end
