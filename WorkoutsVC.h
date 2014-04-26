//
//  WorkoutsVC.h
//  WorkoutMusic
//
//  Created by John La Barge on 2/23/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OptionDelegate.h"
@interface WorkoutsVC : UIViewController <OptionDelegate>
@property (weak, nonatomic) IBOutlet UIView *workoutSelector;

@end
