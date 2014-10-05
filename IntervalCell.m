//
//  IntervalCell.m
//  WorkoutInterval
//
//  Created by John La Barge on 10/12/13.
//
//

#import "IntervalCell.h"
#import "TimePickerVCViewController.h"
#import "FXBlurView.h"

@interface IntervalCell()
@property (nonatomic, strong) UITapGestureRecognizer * widgetTapper;
@property (nonatomic, assign) BOOL sliderJustChanged;
@end
@implementation IntervalCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)prepareForReuse
{
    [super prepareForReuse];
    self.timeLabel.textColor = [UIColor blackColor];
    self.editing = NO;
    self.selected = NO;
    
}
-(void) setWorkoutInterval:(WorkoutInterval *)workoutInterval
{
    _workoutInterval = workoutInterval;
    self.tempoSlider.value = (float) workoutInterval.speed;
    
}
-(void) awakeFromNib
{
    UITapGestureRecognizer *timeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editTime)];
    timeTap.numberOfTapsRequired = 1;
    timeTap.delaysTouchesBegan = NO;

    [self.timeLabel addGestureRecognizer:timeTap];
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
   // [self.tempoSlider setThumbImage:[UIImage imageNamed:@"thumb"] forState:UIControlStateNormal];
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
    self.widgetTapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedWidget:)];
    [self.timeLabel addGestureRecognizer:self.widgetTapper];
    [self.tempoSlider addGestureRecognizer:self.widgetTapper];
}


- (IBAction)setSpeed:(id)sender {
    
    UISegmentedControl * speedControl = (UISegmentedControl *) sender;
    
    self.workoutInterval.speed = [speedControl selectedSegmentIndex];
}

-(void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    [super setUserInteractionEnabled:userInteractionEnabled];
     self.tempoSlider.userInteractionEnabled = userInteractionEnabled;
}


- (IBAction)editTime {
    if (self.userInteractionEnabled) {
        
        [self.parent presentTimePickerForInterval:self.workoutInterval intervalCell:self];
    }
    
}
- (IBAction)sliderChanged:(id)sender {
    NSInteger intVal = round(self.tempoSlider.value);
    [self.tempoSlider setValue:intVal animated:NO];
    self.workoutInterval.speed = intVal;
   
    [self.parent selectIndexPath:[self.parentTable indexPathForCell:self]];
    self.sliderJustChanged = YES;
}

- (IBAction)tappedWidget:(id)sender {
    NSIndexPath * indexPath = [self.parentTable indexPathForCell:self];
    if (!self.sliderJustChanged) {
        BOOL selected = [[self.parentTable indexPathsForSelectedRows] containsObject:indexPath];
        if (selected) {
            // self.isSelected = NO;
            NSLog(@"deselecting from tapped..");
            [self.parent deSelectIndexPath:indexPath];
            
            
        } else {
            // self.isSelected = YES;
            NSLog(@"selecting from tapped...");
            [self.parent selectIndexPath:indexPath];
        }
    }
    self.sliderJustChanged = NO;
}




@end
