//
//  NewWorkoutCell.h
//  WorkoutMusic
//
//  Created by John La Barge on 2/5/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActionDelegate.h"

@interface NewWorkoutCell : UICollectionViewCell
@property (nonatomic, weak) IBOutlet UIButton * addButton;
@property (nonatomic, weak) id <ActionDelegate> delegate;
@end
