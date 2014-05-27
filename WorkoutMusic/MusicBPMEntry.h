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

@property (nonatomic, strong) NSString * artist;
@property (nonatomic, strong) NSNumber * bpm;
@property (nonatomic, strong) NSNumber * energy;
@property (nonatomic, strong) NSNumber * danceability;
@property (nonatomic, strong) NSNumber * liveliness;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSNumber * notfound;
@property (nonatomic, strong) NSNumber * overridden_intensity;
@property (nonatomic, strong) NSNumber * overridden; 

@end
