//
//  WorkoutsVC.m
//  WorkoutMusic
// 
//  Created by John La Barge on 2/23/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import "WorkoutsVC.h"
#import "WorkoutsCV.h"
#import "IndividualWorkout.h"
#import "WorkoutMusicSettings.h"
#import "PlayListChooserViewController.h"


@interface WorkoutsVC ()
@property (nonatomic, weak) WorkoutsCV * workoutsCV;
@end

@implementation WorkoutsVC

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        NSLog(@"will rotate to landscape...");
        
    }
}
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"individualWorkout"]) {
        IndividualWorkout * iworkoutVC = (IndividualWorkout *) segue.destinationViewController;
        iworkoutVC.workout = self.workoutsCV.selectedWorkout;
    }
    else if ([segue.identifier isEqualToString:@"embeddedWorkoutsCV"]) {
        self.workoutsCV = segue.destinationViewController;
    }
}

@end
