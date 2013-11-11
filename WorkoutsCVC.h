//
//  WorkoutsCVC.h
//  WorkoutInterval
//
//  Created by La Barge, John on 10/27/13.
//
//

#import <UIKit/UIKit.h>
#import "WorkoutGraph.h"

@interface WorkoutsCVC : UICollectionViewCell
@property (strong, nonatomic) Workout * workout;
@property (strong, nonatomic) IBOutlet WorkoutGraph *graph;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
-(void) highlight;
-(void) unhlighlight; 
@end
