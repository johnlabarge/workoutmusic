//
//  WorkoutsCVC.m
//  WorkoutInterval
//
//  Created by La Barge, John on 10/27/13.
//
//

#import "WorkoutsCVC.h"

@implementation WorkoutsCVC

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) setWorkout:(Workout *) workout
{
    _workout = workout;
    self.graph.workout = _workout;
    [self.graph reloadData];
    self.timeLabel.text = [NSString stringWithFormat:@"%d min", _workout.workoutSeconds/60];
    self.nameLabel.text = _workout.name;
    self.graph.backgroundColor = [UIColor blackColor]; 
}

-(void) highlight
{
    self.layer.borderWidth=1.0f;
    self.layer.borderColor=[UIColor greenColor].CGColor;
}
-(void) unhighlight
{
    self.layer.borderWidth=0.0f;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
