//
//  TableSectionExpansionDelegate.h
//  WorkoutMusic
//
//  Created by John La Barge on 5/26/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TableSectionExpansionDelegate <NSObject>
-(void)expandSection:(NSUInteger)sectionNum;
-(void)contractSection:(NSUInteger)sectionNum;

@end
