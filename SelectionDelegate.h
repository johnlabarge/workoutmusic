//
//  SelectionDelegate.h
//  WorkoutMusic
//
//  Created by John La Barge on 6/11/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SelectionDelegate <NSObject>
-(void) selectionStateChanged:(BOOL)newState sender:(id)sender;
@end
