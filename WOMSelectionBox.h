//
//  WOMSelectionBox.h
//  WorkoutMusic
//
//  Created by John La Barge on 6/11/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectionDelegate.h"

@interface WOMSelectionBox : UIView 
@property (nonatomic, assign) BOOL selectedState;
@property (nonatomic, strong) UIColor * selectedColor;
@property (nonatomic, strong) NSDictionary * userInfo;
@property (nonatomic, weak) id<SelectionDelegate> selectDelegate;
-(void)select;
-(void)unselect; 
@end
