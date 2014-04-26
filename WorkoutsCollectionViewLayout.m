//
//  WorkoutsCollectionViewLayout.m
//  WorkoutMusic
//
//  Created by John La Barge on 3/17/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import "WorkoutsCollectionViewLayout.h"

@implementation WorkoutsCollectionViewLayout
-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes * attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    attributes.size = CGSizeMake(100.0,100.0);
    return attributes;
}
@end
