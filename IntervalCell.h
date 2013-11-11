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
@interface IntervalCell : UITableViewCell <UITextFieldDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *timeField;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UISegmentedControl *speedControl;
@property (readwrite, assign) BOOL isSelected;

@property (weak, nonatomic) WorkoutInterval * workoutInterval;
@property (strong, nonatomic) IBOutlet UIView *timeView;

@property (strong, nonatomic) IBOutlet WorkoutIntervalPicker *timePicker;
@property (nonatomic, assign) NSInteger seconds; 
@property (strong, nonatomic) IBOutlet UISlider *tempoSlider;
-(void) selectCell;
-(void) deselectCell; 
@end
