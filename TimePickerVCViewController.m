//
//  TimePickerVCViewController.m
//  WorkoutMusic
//
//  Created by John La Barge on 11/11/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import "TimePickerVCViewController.h"

@interface TimePickerVCViewController ()
@property (nonatomic, strong) NSMutableArray *timeOptions;
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
    self.timeOptions = [[NSMutableArray alloc] initWithCapacity:60];
    self.timeLabels = [[NSMutableArray alloc] initWithCapacity:60];
    for (int i=0; i< 60; i++) {
        [self.timeOptions addObject: [self stringForSeconds:(i+1)*10]];
        [self.timeLabels addObject: [self labelFor:[self.timeOptions objectAtIndex:i]]];
    }
    self.timePicker.delegate = self;
    self.timePicker.dataSource =self;

}
-(NSString *) stringForSeconds:(NSInteger)seconds
{
    

    NSInteger minutes = seconds/60;
    NSInteger leftOverSeconds = seconds-(minutes*60);
   return [NSString stringWithFormat:@"%d min %ds", minutes, leftOverSeconds];
    
}
- (IBAction)doneAction:(id)sender {
    NSInteger selectedRow= [self.timePicker selectedRowInComponent:0];
    self.interval.intervalSeconds = (selectedRow+1)*10;
    NSLog(@"new interval seconds = %d", self.interval.intervalSeconds);
    [self.view removeFromSuperview];
    [self.blurView removeFromSuperview];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.timePicker.showsSelectionIndicator = YES;
    [UIView animateWithDuration:0.2 animations:^{
        self.view.backgroundColor = [UIColor grayColor];
    }];
    
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
    NSLog(@"number of rows :%d",self.timeOptions.count);
  //  NSLog(@"did select row");
   //  self.selectedSeconds = ([self.timePicker selectedRowInComponent:0]+1)*10;
    //[self.blurView removeFromSuperview];
   
    
}
- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSLog(@"title for row : %@", [self.timeOptions objectAtIndex:row]);
    return [self.timeOptions objectAtIndex:row]; 
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    NSLog(@"number of ComponentsInPickerView");
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSLog(@"numberOfRowsInComponent %d",self.timeOptions.count);
    return 60;
}
- (IBAction)doneWithTime:(id)sender {
    // self.selectedSeconds = ([self.timePicker selectedRowInComponent:0]+1)*10;
    //[self.blurView removeFromSuperview];
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 20.0; 
}
@end
