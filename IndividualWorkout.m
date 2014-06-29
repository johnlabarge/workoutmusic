//
//  IndividualWorkout.m
//  WorkoutMusic
//
//  Created by John La Barge on 11/16/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import "IndividualWorkout.h"
#import "WorkoutDesignerVC.h"
#import "WorkoutViewController.h"

@interface IndividualWorkout ()
@property (nonatomic, strong) UIAlertView * alert;
@end

@implementation IndividualWorkout

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.nameLabel.text = self.workout.name;
    self.graphView.workout = self.workout;
    self.workoutTimeLabel.text = [self timeText];
    NSLog(@"intervals = %lu",(unsigned long)self.workout.intervals.count);
}
	// Do any additional setup after loading the view.


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)canceled:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}
-(void)viewDidAppear:(BOOL)animated {
    
}
-(NSString *)timeText
{
    NSString * text = nil;
    NSInteger minutes = self.workout.workoutSeconds/60;
    NSInteger seconds = self.workout.workoutSeconds - (60*minutes);
    if (seconds > 0) {
        text = [NSString stringWithFormat:@"%ld min %ld sec", (long)minutes, (long)seconds];
    } else {
        text = [NSString stringWithFormat:@"%ld min", (long)minutes];
    }
    return text;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"editWorkout"]) {
        WorkoutDesignerVC * wdvc = (WorkoutDesignerVC *) segue.destinationViewController;
        NSLog(@"workout intervals = %lu",(unsigned long)self.workout.intervals.count);
        wdvc.model = self.workout;
    } else if ([segue.identifier isEqualToString:@"startWorkout"]) {
        WorkoutViewController * wovc = (WorkoutViewController *) segue.destinationViewController;
        wovc.workout = self.workout;
        NSLog(@"workout intervals = %lu",(unsigned long)self.workout.intervals.count);

    }
}
- (IBAction)deleteWorkout:(id)sender {
    self.alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"Delete this workout forever?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Do it!", nil];
    
    [self.alert show];
}



- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex) {
        [self.workout destroy];
        [self dismissViewControllerAnimated:YES completion:^{}];
    }
}

@end
