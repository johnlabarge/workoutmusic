//
//  IntervalCell.m
//  WorkoutInterval
//
//  Created by John La Barge on 10/12/13.
//
//

#import "IntervalCell.h"

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
- (IBAction)updateIntervalTime:(id)sender {
    self.workoutInterval.intervalSeconds = [self.timeField.text integerValue];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.workoutInterval.intervalSeconds = [self.timeField.text integerValue];
    return YES;
}
-(BOOL) textFieldShouldReturn:(UITextField *) textField
{
    [textField resignFirstResponder];
    self.workoutInterval.intervalSeconds = [self.timeField.text integerValue];
    return YES;
}


- (BOOL) textField: (UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range replacementString: (NSString *)string {
    //return yes or no after comparing the characters
    
    // allow backspace
    if (!string.length)
    {
        return YES;
    }
    
    ////for Decimal value start//////This code use use for allowing single decimal value
    //    if ([theTextField.text rangeOfString:@"."].location == NSNotFound)
    //    {
    //        if ([string isEqualToString:@"."]) {
    //            return YES;
    //        }
    //    }
    //    else
    //    {
    //        if ([[theTextField.text substringFromIndex:[theTextField.text rangeOfString:@"."].location] length]>2)   // this allow 2 digit after decimal
    //        {
    //            return NO;
    //        }
    //    }
    ////for Decimal value End//////This code use use for allowing single decimal value
    
    // allow digit 0 to 9
    if ([string intValue] || [string isEqualToString:@"0"])
    {
        return YES;
    }
    
    return NO;
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
   
}
- (IBAction)sliderChanged:(id)sender {
    NSLog(@"slider value=%.2f",self.tempoSlider.value);
    NSInteger intVal = round(self.tempoSlider.value);
    [self.tempoSlider setValue:intVal animated:NO];
    NSLog(@"slider int value=%d", intVal);
    self.workoutInterval.speed = intVal;
}


-(void) setSeconds:(NSInteger)seconds
{
    _seconds = seconds;
    [self.timePicker selectRow:(seconds/10)-1 inComponent:0 animated:YES];
}

@end
