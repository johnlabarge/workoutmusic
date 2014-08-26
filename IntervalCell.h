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
#import "WorkoutDesignerVC.h"
#import "TimeLabel.h"
#import "SelectionDelegate.h"
#import "WOMSelectionBox.h"
@class WorkoutDesignerVC; 
@interface IntervalCell : UITableViewCell <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet TimeLabel *timeLabel;
@property (weak, nonatomic) IBOutlet WOMSelectionBox *selectionBox;


@property (readwrite, assign) BOOL isSelected;

@property (weak, nonatomic) WorkoutInterval * workoutInterval;
@property (strong, nonatomic) IBOutlet UIView *timeView;

@property (weak, nonatomic) IBOutlet UIButton *repeatButton;

@property (nonatomic, assign) NSInteger seconds; 
@property (strong, nonatomic) IBOutlet UISlider *tempoSlider;
@property (nonatomic, strong) WorkoutDesignerVC * parent;
@property (nonatomic, weak) UITableView * parentTable; 

@end
