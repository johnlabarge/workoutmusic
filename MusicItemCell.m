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
@property (weak, nonatomic) IBOutlet UIButton *clear_override_button;
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

-(NSUInteger)musicItemIntensityIndex
{
    NSString * tempoClass = [[MusicLibraryBPMs currentInstance:nil] classificationForMusicItem:self.musicItem];
    NSUInteger intensityIndex = [Tempo toIntensityNum:tempoClass];
    return intensityIndex;
}
-(void) prepareClearOverrideButton
{
    /* because overridden need to setup each time. 
     */
    if (!self.musicItem.overridden) {
        self.clear_override_button.enabled = NO;
        self.clear_override_button.hidden = YES;
    } else {
        self.clear_override_button.enabled = YES;
        self.clear_override_button.hidden = NO;
    }
}

-(void) prepareIntensityWidget:(NSUInteger)intensityIndex
{
   
    if ((self.musicItem.notfound || intensityIndex == UNKNOWN) && !self.musicItem.overridden) {
        [self.intensityControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
    } else {
        [self.intensityControl setSelectedSegmentIndex:intensityIndex];
    }
    [self.intensityControl setSelected:NO];
    
}
- (void) setMusicItem:(MusicLibraryItem *)musicItem
{
    _musicItem = musicItem;

    [self prepareClearOverrideButton];
    NSUInteger intensityIndex = [self musicItemIntensityIndex];
    [self prepareIntensityWidget:intensityIndex];

    
    self.overrideStatusLabel.text = (self.musicItem.overridden? @"intensity overriden by user" : @"suggested intensity");
    self.artistLabel.text = musicItem.artist;
    self.titleLabel.text = musicItem.title;

    self.albumArtImageView.image = [musicItem.artwork imageWithSize:CGSizeMake(50.0,50.0)];
    if (musicItem.overridden) {
        self.backgroundColor = [UIColor colorWithRed:253.0/255.0 green:227.0/255.0 blue:137.0/255.0 alpha:0.75];
    } else if (!musicItem.notfound && (intensityIndex!= UNKNOWN)) {
        self.backgroundColor= [UIColor whiteColor];
    } else if (!musicItem.overridden ){
        self.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:0.5];
        self.overrideStatusLabel.text = @"unable to suggest intensity";
    }
    self.danceLabel.text = [NSString stringWithFormat:@"%.2f", musicItem.danceability ];
    self.bpmAmt.text = [NSString stringWithFormat:@"%.2f", musicItem.bpm];
    self.energyAmt.text = [NSString stringWithFormat:@"%.2f", musicItem.energy];
    
 
    
}
-(void)awakeFromNib {
    [super awakeFromNib];
    [self prepareCellWidgets];
}
- (IBAction)overrideIntensityForItem:(id)sender {
    
    
    [self.musicItem overrideIntensityTo:self.intensityControl.selectedSegmentIndex];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)clearOverride:(id)sender {
    [self.musicItem clearOverride];
}
 

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
