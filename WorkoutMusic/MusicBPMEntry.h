//
//  MusicBPMEntry.h
//  WorkoutMusic
//
//  Created by La Barge, John on 12/18/12.
//  Copyright (c) 2012 John La Barge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MusicBPMEntry : NSManagedObject

@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSNumber * bpm;
@property (nonatomic, retain) NSString * title;

@end
