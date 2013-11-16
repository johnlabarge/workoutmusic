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

@implementation IntervalCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) awakeFromNib
{
    UITapGestureRecognizer *timeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editTime)];
    timeTap.numberOfTapsRequired = 1;
    timeTap.delaysTouchesBegan = NO;

    [self.timeLabel addGestureRecognizer:timeTap];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)setSpeed:(id)sender {
    
    UISegmentedControl * speedControl = (UISegmentedControl *) sender;
    
    self.workoutInterval.speed = [speedControl selectedSegmentIndex];
}





-(void) selectCell
{
    
    //self.selected = true;
    self.contentView.layer.borderColor = [UIColor blackColor].CGColor;
    self.contentView.layer.borderWidth = 1.0;
    
}
-(void) deselectCell
{
    //self.selected = false;
    self.contentView.layer.borderWidth = 0.0;
    self.contentView.layer.borderColor = [UIColor whiteColor].CGColor;
}
- (IBAction)editTime {
    
    NSLog(@"edit time");

    [self.parent presentTimePickerForInterval:self.workoutInterval];

    
    /* [self.parent presentViewController:timePickerVC animated:YES completion:^{
        theInterval.intervalSeconds = timePickerVC.selectedSeconds;
    }];*/
    //FXBlurView * blur = [[FXBlurView alloc] initWithFrame:CGRectMake(0,0,320,568)];
    //[self.parent.view addSubview:blur];
    
}
- (IBAction)sliderChanged:(id)sender {
    NSLog(@"slider value=%.2f",self.tempoSlider.value);
    NSInteger intVal = round(self.tempoSlider.value);
    [self.tempoSlider setValue:intVal animated:NO];
    NSLog(@"slider int value=%d", intVal);
    self.workoutInterval.speed = intVal;
}



@end
