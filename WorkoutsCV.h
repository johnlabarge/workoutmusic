//
//  WorkoutsCV.h
//  WorkoutInterval
//
//  Created by La Barge, John on 10/27/13.
//
//

#import <UIKit/UIKit.h>
#import "Workout.h"
#import "ActionDelegate.h"

@interface WorkoutsCV : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIAlertViewDelegate>
@property (strong, nonatomic) NSArray * workouts;
@property (strong, nonatomic) Workout * selectedWorkout;
@property (weak, nonatomic) IBOutlet UICollectionView * collectionView;
@end
