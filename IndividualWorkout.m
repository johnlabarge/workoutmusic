//
//  IndividualWorkout.m
//  WorkoutMusic
//
//  Created by John La Barge on 11/16/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import "IndividualWorkout.h"
#import "WorkoutDesignerVC.h"

@interface IndividualWorkout ()

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

-(NSString *)timeText
{
    NSString * text = nil;
    NSInteger minutes = self.workout.workoutSeconds/60;
    NSInteger seconds = self.workout.workoutSeconds - (60*minutes);
    if (seconds > 0) {
        text = [NSString stringWithFormat:@"%d min %d sec", minutes, seconds];
    } else {
        text = [NSString stringWithFormat:@"%d min", minutes];
    }
    return text;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"editWorkout"]) {
        WorkoutDesignerVC * wdvc = (WorkoutDesignerVC *) segue.destinationViewController;
        wdvc.model = self.workout;
    }
}

@end
