//
//  TimePickerVCViewController.m
//  WorkoutMusic
//
//  Created by John La Barge on 11/11/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import "TimePickerVCViewController.h"

@interface TimePickerVCViewController ()
@property (nonatomic, strong) NSArray * minuteOptions;
@property (nonatomic, strong) NSMutableArray * secondsOptions;
@property (nonatomic, strong) NSMutableArray * timeLabels;
@end

@implementation TimePickerVCViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setup];
        // Custom initialization
    }
    return self;
}
-(id) initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    [self setup];
    return self;
}

-(void) setup {
    
    self.minuteOptions = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7", @"8", @"9",@"10"];
    self.secondsOptions = [[NSMutableArray alloc] initWithCapacity:60];

    for (int i=0; i< 60; i++) {
        NSString * secondsOption;
        if (i < 10) {
            secondsOption  = [NSString stringWithFormat:@"0%@",@(i)];
        } else {
            secondsOption  = @(i).stringValue;
        }
        [self.secondsOptions addObject:secondsOption];
    }
    self.timePicker.delegate = self;
    self.timePicker.dataSource =self;
    
    

}

- (IBAction)doneAction:(id)sender {
    self.interval.intervalSeconds = 60*[self.timePicker selectedRowInComponent:0];
    self.interval.intervalSeconds+= [self.timePicker selectedRowInComponent:1];
    NSLog(@"new interval seconds = %ld", (long)self.interval.intervalSeconds);
    [self.view removeFromSuperview];
    [self.blurView removeFromSuperview];
    
}
-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 60.0;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.timePicker.showsSelectionIndicator = YES;
    [UIView animateWithDuration:0.2 animations:^{
        self.view.backgroundColor = [UIColor grayColor];
    }];
    NSInteger minutes = self.interval.intervalSeconds/60;
    NSInteger seconds = self.interval.intervalSeconds-(minutes*60);
    [self.timePicker selectRow:minutes inComponent:0 animated:NO];
    [self.timePicker selectRow:seconds inComponent:1 animated:NO];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    
    return [self.timeLabels objectAtIndex:row];
}*/

-(UILabel *) labelFor:(NSString *)text
{
    UILabel * label = [[UILabel alloc] init];
    label.font= [UIFont systemFontOfSize:15.0];
    label.text = text;
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
 //   NSLog(@"number of rows :%lu",(unsigned long)self.timeOptions.count);
  //  NSLog(@"did select row");
   //  self.selectedSeconds = ([self.timePicker selectedRowInComponent:0]+1)*10;
    //[self.blurView removeFromSuperview];
   
    
}
- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    if (component == 0) {
        return self.minuteOptions[row];
    }
    return self.secondsOptions[row];
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel * label = (UILabel *)view;
    
    if (!label) {
        label = [[UILabel alloc] init];
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:34.0];
    }
    if (component == 0) {
        label.text = self.minuteOptions[row];
    } else {
        label.text = self.secondsOptions[row];
    }
    return label;
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return self.minuteOptions.count;
    } else {
        return self.secondsOptions.count;
    }
    
}

 
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40.0;
}
@end
