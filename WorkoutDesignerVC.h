//
//  ViewController.h
//  WorkoutInterval
//
//  Created by John La Barge on 10/12/13.
//
//

#import <UIKit/UIKit.h>
#import "Workout.h"
#import "WorkoutGraph.h"
#import "TimePickerVCViewController.h"

@interface WorkoutDesignerVC : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *nameField; 
@property (strong, nonatomic) IBOutlet UITableView *intervalsTable;
@property (weak, nonatomic) IBOutlet UIButton *tableExpander;
@property (weak, nonatomic) IBOutlet UILabel *workoutTimeLabel;
@property (weak, nonatomic) IBOutlet WorkoutGraph *workoutGraph;
@property (weak, nonatomic) IBOutlet UIButton *repeatButton;


@property (strong, nonatomic) Workout * model;

-(void) presentTimePickerForInterval:(WorkoutInterval *) interval;

@end
