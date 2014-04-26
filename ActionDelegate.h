//
//  ActionDelegate.h
//  WorkoutMusic
//
//  Created by John La Barge on 2/9/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ActionDelegate <NSObject>
-(void) perform:(id)sender actionInfo:(NSDictionary *)info;
@end
