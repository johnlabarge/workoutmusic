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
    self.selectionStyle = UITableViewCellSelectionStyleGray;
    [self.tempoSlider setThumbImage:[UIImage imageNamed:@"thumb"] forState:UIControlStateNormal];
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
        [self.parent presentTimePickerForInterval:self.workoutInterval];
    }
    

    
    /* [self.parent presentViewController:timePickerVC animated:YES completion:^{
        theInterval.intervalSeconds = timePickerVC.selectedSeconds;
    }];*/
    //FXBlurView * blur = [[FXBlurView alloc] initWithFrame:CGRectMake(0,0,320,568)];
    //[self.parent.view addSubview:blur];
    
}
- (IBAction)sliderChanged:(id)sender {
    NSInteger intVal = round(self.tempoSlider.value);
    [self.tempoSlider setValue:intVal animated:NO];
    self.workoutInterval.speed = intVal;
    self.isSelected = YES;
    [self.parent selectIndexPath:[self.parentTable indexPathForCell:self]];
}

- (IBAction)tappedWidget:(id)sender {
    NSIndexPath * indexPath = [self.parentTable indexPathForCell:self];
    
    if (self.isSelected) {
        self.isSelected = NO;
         [self.parent deSelectIndexPath:indexPath];
    
        
    } else {
        self.isSelected = YES;
        [self.parent selectIndexPath:indexPath];
        
        
    }
}




@end
