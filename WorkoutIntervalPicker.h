//
//  WorkoutIntervalPicker.h
//  WorkoutMusic
//
//  Created by La Barge, John on 11/7/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorkoutInterval.h"

@interface WorkoutIntervalPicker : UIPickerView
@property (nonatomic, strong) WorkoutInterval * interval;
@end
