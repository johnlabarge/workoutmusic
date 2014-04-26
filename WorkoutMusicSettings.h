//
//  WorkoutMusicSettings.h
//  WorkoutMusic
//
//  Created by La Barge, John on 5/1/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WorkoutMusicSettings : NSObject
 
+(WorkoutMusicSettings *)sharedInstance;
+(NSString *) workoutSongsPlaylist;
+(void) setWorkoutSongsPlaylist:(NSString *)playlist;

@end
