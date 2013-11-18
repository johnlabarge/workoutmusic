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

	// Do any additional setup after loading the view.
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
    NSLog(@"Collection View Data source...%d", self.workouts.count);

    return self.workouts.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
-(Workout *) workoutForIndexPath:(NSIndexPath *)path
{
    NSInteger index = [path indexAtPosition:1];
    return (Workout *) [self.workouts objectAtIndex:index];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    WorkoutsCVC *  cell = (WorkoutsCVC *) [self.collectionView dequeueReusableCellWithReuseIdentifier:@"workoutCell" forIndexPath:indexPath];
    cell.workout = [self workoutForIndexPath:indexPath]; 
    NSLog(@"Index Path: %d-%d", [indexPath indexAtPosition:0], [indexPath indexAtPosition:1]);
    
    
    if (cell == nil) {
        cell = (WorkoutsCVC *)[ [NSBundle mainBundle] loadNibNamed:@"WorkoutCVC" owner:self options:nil];
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
    //WorkoutsCVC * cell = [(WorkoutsCVC *) collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    [self performSegueWithIdentifier:@"individualWorkout" sender:self];
    [self.collectionView reloadData];
    //[[Model sharedInstance] placeOrder:drink];
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}
#pragma mark – UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    // 2
    return CGSizeMake(130, 212);
    
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(50, 20, 50, 20);
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"individualWorkout"]) {
        IndividualWorkout * iworkoutVC = (IndividualWorkout *) segue.destinationViewController;
        iworkoutVC.workout = self.selectedWorkout;
    }
}
@end
