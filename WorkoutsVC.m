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

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        NSLog(@" did rotate to landscape");
        CGPoint position = self.workoutSelector.frame.origin;
        CGSize size = self.workoutSelector.frame.size;
        NSLog(@"%.2f, %.2f, %.2f x %.2f", position.x, position.y, size.width, size.height);
    }
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"individualWorkout"]) {
        IndividualWorkout * iworkoutVC = (IndividualWorkout *) segue.destinationViewController;
        iworkoutVC.workout = self.workoutsCV.selectedWorkout;
    }
    else if ([segue.identifier isEqualToString:@"embeddedWorkoutsCV"]) {
        self.workoutsCV = segue.destinationViewController;
    } else if ([segue.identifier isEqualToString:@"changeworkoutsongs"]) {
        PlaylistChooserViewController * playlistChooser = (PlaylistChooserViewController *) segue.destinationViewController;
        playlistChooser.delegate = self;
        
    }
}
-(void)optionChosen:(NSObject *)option
{
    NSString * playListName = (NSString *)option;
    [WorkoutMusicSettings setWorkoutSongsPlaylist:playListName];
}
@end
