//
//  WorkoutsCV.m
//  WorkoutInterval
//
//  Created by La Barge, John on 10/27/13.
//
//

#import "WorkoutsCV.h"
#import "WorkoutsCVC.h"
#import "Workouts.h"
#import "IndividualWorkout.h"
#import "WorkoutsHeader.h"
#import "NewWorkoutCell.h"
#import "WorkoutsCollectionViewLayout.h"

@interface WorkoutsCV ()

@end

@implementation WorkoutsCV

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
    self.workouts = [Workouts list];
    
    
    UINib *nib = [UINib nibWithNibName:@"WorkoutCVC" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"workoutCell"];
    
    UINib *nib2 = [UINib nibWithNibName:@"newWorkoutCell" bundle:nil];
    [self.collectionView registerNib:nib2 forCellWithReuseIdentifier:@"newWorkoutCell"];
    

    
	// Do any additional setup after loading the view.
     
   // self.collectionView.collectionViewLayout = [[WorkoutsCollectionViewLayout alloc] init];
}

-(void) viewWillAppear:(BOOL)animated
{
    self.workouts = [Workouts list];
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
       return self.workouts.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
-(Workout *) workoutForIndexPath:(NSIndexPath *)path
{
    NSInteger index = [path indexAtPosition:1];
    Workout * workout = nil;
    if (index < self.workouts.count) {
        workout = (Workout *) self.workouts[index];
    }
    return workout;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell * cell;
    if (indexPath.row < self.workouts.count) {
        Workout * workout = [self workoutForIndexPath:indexPath];
        WorkoutsCVC * woCell = (WorkoutsCVC *) [self.collectionView dequeueReusableCellWithReuseIdentifier:@"workoutCell" forIndexPath:indexPath];
        woCell.workout = workout;
        if (self.selectedWorkout == workout) {
            woCell.selected = true;
        }
        NSLog(@"Index Path: %d-%d", [indexPath indexAtPosition:0], [indexPath indexAtPosition:1]);
        cell = woCell;
    }  
    
    return cell;
}




#pragma mark - UICollectionViewDelegate
- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Selection event...%d", [indexPath indexAtPosition:1]);
   /* WorkoutsCVC * cell = (WorkoutsCVC *)[collectionView cellForItemAtIndexPath:indexPath];
     [cell highlight];
    Workout * workout = [self workoutForIndexPath: indexPath];
    NSLog(@"workout %@ selected.", workout.name);*/
    self.selectedWorkout = [self workoutForIndexPath:indexPath];
    [self.parentViewController performSegueWithIdentifier:@"individualWorkout" sender:self];
    //WorkoutsCVC * cell = [(WorkoutsCVC *) collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
      [self.collectionView reloadData];
    //[[Model sharedInstance] placeOrder:drink];
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}
#pragma mark – UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    // 2
    return CGSizeMake(100, 100);
    
}


/*- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(50, 20, 50, 20);
}*/


-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section  {
    return CGSizeMake(0.0,0.0);
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"collection view rotate");
    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark ActionDelegate
-(void) perform:(id)sender actionInfo:(NSDictionary *)info
{
    if ([info[@"action"] isEqualToString:@"newWorkout"]) {
        [self.parentViewController performSegueWithIdentifier:@"newWorkout" sender:sender]; 
    }
}


@end
