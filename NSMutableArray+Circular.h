//
//  NSArray+Circular.h
//  WorkoutMusic
//
//  Created by John La Barge on 5/10/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Circular)
-(void) startFrom:(NSUInteger)index;
@end
