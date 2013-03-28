//
//  PlayListPickerViewController.h
//  WorkoutMusic
//
//  Created by La Barge, John on 3/17/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h" 

@interface WorkoutTimeViewController : SuperViewController
@property  (nonatomic, strong) IBOutlet UIPickerView * workoutTimePicker;
@property  (nonatomic, strong) IBOutlet UIButton * pyramidButton;
@property  (nonatomic, strong) IBOutlet UIButton * fastToSlowButton;
@property  (nonatomic, strong) IBOutlet UIButton * slowToFastButton; 
@property  (nonatomic, strong) NSNumber * selectedTime;
@property  (nonatomic, strong) IBOutlet UIButton * setButton; 
@end
