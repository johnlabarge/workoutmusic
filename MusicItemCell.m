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

@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *albumArtImageView;
@property (strong, nonatomic) UIColor * oldBackgroundColor;
@property (strong, nonatomic) UIColor * glowColor;
@property (weak, nonatomic) IBOutlet UISlider * intensitySlider;
@property (weak, nonatomic) IBOutlet UIButton *clearSaveOverrideButton;
@property (nonatomic, assign) OverrideState overrideState;
@property (readonly) MusicLibraryBPMs * library;
@property (weak, nonatomic) IBOutlet UILabel *curentIntensity;


@end

@implementation MusicItemCell

-(void) prepareCellWidgets
{

    
      //[self.intensitySlider setThumbImage:[UIImage imageNamed:@"thumb"] forState:UIControlStateNormal];
    self.clearSaveOverrideButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.clearSaveOverrideButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
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


-(void) prepareIntensityWidget:(NSUInteger)intensityIndex
{
   
    if ((self.musicItem.notfound || intensityIndex == UNKNOWN) && !self.musicItem.overridden) {
        self.intensitySlider.value = 0;
    } else {
        self.intensitySlider.value = intensityIndex;
    }
    
}
- (void) updateOverrideIntensityButton {

    
    if (self.intensitySlider.value  != [ Tempo toIntensityNum:self.musicItem.currentClassification] || (self.musicItem.notfound && !self.musicItem.overridden)) {
        [self.clearSaveOverrideButton setTitle:@"Save Intensity Change?" forState:UIControlStateNormal];
        self.clearSaveOverrideButton.hidden = NO;
        self.overrideState=Execute_Override;
    } else if (self.musicItem.overridden && !self.musicItem.notfound) {
        [self.clearSaveOverrideButton setTitle:@"Reset to Suggested Intensity" forState:UIControlStateNormal];
        self.overrideState = Clear_Override;
    } else {
        self.clearSaveOverrideButton.hidden = YES;
        self.overrideState = No_Override;
    }
    
    NSLog(@"Update override intensity button for %@ clearSave = %@ musicItem.overridden = %@, ", self.musicItem.title, @(self.clearSaveOverrideButton.hidden), @(self.musicItem.overridden));
}
- (void) setMusicItem:(MusicLibraryItem *)musicItem
{
    _musicItem = musicItem;

    
    NSUInteger intensityIndex = [self musicItemIntensityIndex];
    [self prepareIntensityWidget:intensityIndex];
    
    [self updateOverrideIntensityButton];
 
    self.artistLabel.text = musicItem.artist;
    self.titleLabel.text = musicItem.title;
    [self updateIntensityText];
    self.albumArtImageView.image = [musicItem.artwork imageWithSize:CGSizeMake(70.0,70.0)];

    
}
-(void) prepareForReuse
{
    [self updateOverrideIntensityButton];
}
-(void) updateIntensityText
{
        self.curentIntensity.text = [NSString stringWithFormat:@"%@ intensity (adjust above)", [Tempo intensities][(NSInteger)self.intensitySlider.value] ];
}
-(void)awakeFromNib {
    [super awakeFromNib];
    [self prepareCellWidgets];
     self.glowColor = [UIColor colorWithRed:252.0/255.0 green:136/255.0 blue:0.0 alpha:1.0];
    
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
    [self.musicItem clearOverride:@{@"row": @(self.row)}];
}
- (IBAction)sliderChanged:(id)sender {
    NSInteger intVal = round(self.intensitySlider.value);
    [self.intensitySlider setValue:intVal animated:NO];
    
    [self  updateOverrideIntensityButton];
    [self updateIntensityText];
}
 

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void) glow
{
    [UIView animateWithDuration:1.0 animations:^{
        self.oldBackgroundColor = self.backgroundColor;
        self.contentView.backgroundColor = self.glowColor;
    
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:1.0 animations:^{
            self.contentView.backgroundColor = self.oldBackgroundColor;
            }];
        }
        
    }];
}
-(MusicLibraryBPMs *) library {
    return [MusicLibraryBPMs currentInstance:nil];
}
    
- (IBAction)clearSaveOverride:(id)sender {
    switch (self.overrideState) {
        case Clear_Override:
            [self.musicItem clearOverride:@{@"row":@(self.row)}];
            break;
        case Execute_Override:
            [self.musicItem overrideIntensityTo:self.intensitySlider.value userInfo:@{@"row":@(self.row)}];
            break;
        default:
            break;
    }
}
@end
