//
//  IntervalCell.h
//  WorkoutInterval
//
//  Created by John La Barge on 10/12/13.
//
//

#import <UIKit/UIKit.h>
#import "Workout.h"
#import "WorkoutInterval.h"
#import "WorkoutIntervalPicker.h"
#import "WorkoutDesignerVC.h"
#import "TimeLabel.h"

@interface IntervalCell : UITableViewCell <UITextFieldDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) IBOutlet TimeLabel *timeLabel;


@property (readwrite, assign) BOOL isSelected;

@property (weak, nonatomic) WorkoutInterval * workoutInterval;
@property (strong, nonatomic) IBOutlet UIView *timeView;


@property (nonatomic, assign) NSInteger seconds; 
@property (strong, nonatomic) IBOutlet UISlider *tempoSlider;
@property (nonatomic, strong) WorkoutDesignerVC * parent;

-(void) selectCell;
-(void) deselectCell; 
@end
