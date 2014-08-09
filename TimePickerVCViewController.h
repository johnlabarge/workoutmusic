//
//  TimePickerVCViewController.h
//  WorkoutMusic
//
//  Created by John La Barge on 11/11/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorkoutInterval.h"
#import "FXBlurView.h"
@interface TimePickerVCViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate,UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>


@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIPickerView *timePicker;
@property (strong, nonatomic) WorkoutInterval *interval;
@property (nonatomic, assign) NSInteger selectedSeconds;
@property (strong, nonatomic) IBOutlet FXBlurView *blurView;

@property (strong, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *chooseTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) IBOutlet UIView *pickerView;
@property (nonatomic, assign) CGRect fromRect;
@property (nonatomic, assign) NSInteger intervalNumber;


@end
