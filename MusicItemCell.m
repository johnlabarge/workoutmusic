//
//  MusicItemCellTableViewCell.m
//  WorkoutMusic
//
//  Created by John La Barge on 4/1/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import "MusicItemCell.h"
#import "MusicLibraryBPMs.h"

@interface MusicItemCell()
@property (weak, nonatomic) IBOutlet UIButton *classificationButton;
@property (weak, nonatomic) IBOutlet UILabel *overrideStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *albumArtImageView;
@property (weak, nonatomic) IBOutlet UILabel *energyAmt;
@property (weak, nonatomic) IBOutlet UILabel *bpmAmt;
@property (weak, nonatomic) IBOutlet UISegmentedControl *intensityControl;
@property (weak, nonatomic) IBOutlet UILabel *danceLabel;
@property (weak, nonatomic) IBOutlet UILabel *livelyLabel;


@end

@implementation MusicItemCell

-(void) prepareCellWidgets
{
    NSDictionary * normal_attributes = @{UITextAttributeTextColor : [UIColor blueColor],
                                         UITextAttributeTextShadowColor : [UIColor clearColor],
                                         UITextAttributeFont : [UIFont fontWithName:@"HelveticaNeue-Thin" size:10.0]
                                         };
    NSDictionary * selected_attributes = @{UITextAttributeTextColor: [UIColor redColor],
                                           UITextAttributeTextShadowColor: [UIColor clearColor],
                                           UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0,1)],
                                           UITextAttributeFont : [UIFont fontWithName:@"HelveticaNeue-Thin" size:13.0]};
    
    
    [[UISegmentedControl appearance] setTitleTextAttributes:normal_attributes forState:UIControlStateNormal];
    
    [[UISegmentedControl appearance] setTitleTextAttributes:selected_attributes forState:UIControlStateSelected];
    //self.intensityControl.apportionsSegmentWidthsByContent = YES;
   /* [self.intensityControl setWidth:70 forSegmentAtIndex:0];
    [self.intensityControl setWidth:70 forSegmentAtIndex:1];
    [self.intensityControl setWidth:70 forSegmentAtIndex:2];
    [self.intensityControl setWidth:70 forSegmentAtIndex:3];*/
    
}

- (void) setMusicItem:(MusicLibraryItem *)musicItem
{
    _musicItem = musicItem;
    [self prepareCellWidgets];
    NSString * tempoClass = [[MusicLibraryBPMs currentInstance:nil] classificationForMusicItem:musicItem];
    NSUInteger intensityIndex = [Tempo toIntensityNum:tempoClass];
    
    self.classificationButton.titleLabel.text = [[MusicLibraryBPMs currentInstance:nil] classificationForMusicItem:musicItem ];
    self.overrideStatusLabel.text = (self.musicItem.overridden? @"intensity overriden by user" : @"suggested intensity");
    self.artistLabel.text = musicItem.artist;
    self.titleLabel.text = musicItem.title;
    self.livelyLabel.text = [NSString stringWithFormat:@"%.2f", musicItem.liveliness];
    self.albumArtImageView.image = [musicItem.artwork imageWithSize:CGSizeMake(50.0,50.0)];
    
    if (!musicItem.notfound) {
        [self.intensityControl setSelectedSegmentIndex:intensityIndex];
        self.backgroundColor= [UIColor whiteColor];
    } else if (!musicItem.overridden ){
        [self.intensityControl setSelected:NO];
        [self.intensityControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
        self.backgroundColor = [UIColor yellowColor];
        self.overrideStatusLabel.text = @"unable to suggest intensity";
    }
    self.danceLabel.text = [NSString stringWithFormat:@"%.2f", musicItem.danceability ]; 
    self.bpmAmt.text = [NSString stringWithFormat:@"%.2f", musicItem.bpm];
    self.energyAmt.text = [NSString stringWithFormat:@"%.2f", musicItem.energy];
    
    
}
- (IBAction)overrideIntensityForItem:(id)sender {
}

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
    

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
