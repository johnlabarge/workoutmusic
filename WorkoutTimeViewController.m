//
//  PlayListPickerViewController.m
//  WorkoutMusic
//
//  Created by La Barge, John on 3/17/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import "WorkoutTimeViewController.h"
#import "WOMusicAppDelegate.h"
#import "WorkoutList.h"

@interface WorkoutTimeViewController() {
    UILabel * label1;
    UILabel * label2;
    
}
@property (nonatomic, strong) NSDictionary * workoutTimes;
@property (nonatomic, strong) NSArray * workoutTimeDescs;
@property (nonatomic, strong) NSArray * workoutImages;
@property (nonatomic, weak) WorkoutList *theWorkout; 
@end

@implementation WorkoutTimeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
           } else {
        NSLog(@"got self?");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad]; 
    self.workoutImages = @[
        [[UIImageView  alloc] initWithImage:[UIImage imageNamed:@"Pyramid.pg"]],
    [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SlowToFast.png"]],
    [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FastThenSlow"]]];
  
    NSLog(@"I am self..");
    NSMutableArray * timeDescs = [[NSMutableArray alloc] initWithCapacity:24];
    NSMutableDictionary * times = [[NSMutableDictionary alloc] init];
    for (int i=0; i <= 120; i+=5) {
        NSString * desc = [NSString stringWithFormat:@"%d min",i];
        [timeDescs addObject:desc];
        [times setObject:[NSNumber numberWithInt:i] forKey:desc];
    }
    self.workoutTimes = times;
    self.workoutTimeDescs = timeDescs;
    [self.workoutTimeDescs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"%@",obj);
    }];
    WOMusicAppDelegate * delegate = [UIApplication sharedApplication].delegate;
    self.theWorkout = delegate.workout;
    label1 = [[UILabel alloc] init];
    label1.text = @"1";
    label2 = [[UILabel alloc] init];
    label2.text = @"2"; 

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark UIPickerViewDelegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"pickerView delegate did select row");
    NSNumber * minutes = [self.workoutTimes objectForKey:[self.workoutTimeDescs objectAtIndex:row]];
    self.selectedTime = [NSNumber numberWithInt:minutes.intValue*60];
    NSLog(@"workout time = %d",[self.selectedTime intValue]*60);

    
}





- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString * title = [self.workoutTimeDescs objectAtIndex:row];
    NSLog(@"%@",title);
    return title;
    
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 20;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 200;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
  {
      return self.workoutTimeDescs.count;
  }


@end
