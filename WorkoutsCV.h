//
//  WorkoutsCV.h
//  WorkoutInterval
//
//  Created by La Barge, John on 10/27/13.
//
//

#import <UIKit/UIKit.h>
#import "Workout.h"

@interface WorkoutsCV : UICollectionViewController
@property (strong, nonatomic) NSArray * workouts;
@property (strong, nonatomic) Workout * selectedWorkout;
@end
