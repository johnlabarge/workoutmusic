//
//  WorkoutList.m
//  WorkoutMusic
//
//  Created by La Barge, John on 3/17/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import "WorkoutList.h"
#import "MusicLibraryBPMs.h"

@implementation WorkoutList

-(id) initWithLibrary:(MusicLibraryBPMs *) library {
    self.bpmLibrary = library;
    listmakerqueue = dispatch_queue_create("listmaker",NULL);
    return self;
}
-(BOOL) generateList:(void(^)(void))afterGenerated {
    
    BOOL generated = NO;
    NSLog(@"\n\n\n\n generate list");
    __block WorkoutList * me = self;
    if (self.workoutTime.intValue >= 300) {
       
        /*
         * TODO: clean this up, should be able to have a workout type spec storage.
         */
        if ([self.workoutType isEqualToString:@"pyramid"]) {
           
            dispatch_async(listmakerqueue, ^{
                NSLog(@"creating pyramid");
                NSArray * workoutSongs = [self.bpmLibrary createPyramid:self.workoutTime.intValue];
                dispatch_async(dispatch_get_main_queue(), ^{
                     me.intervals = self.bpmLibrary.pyramidIntervals;
                    [me calculateActualTime:workoutSongs];
                    me.workoutSongs = workoutSongs;
                    afterGenerated();
               
                });
            });
            generated  = YES;
        } else if ([self.workoutType isEqualToString:@"fastToSlow"]) {
            dispatch_async(listmakerqueue, ^{
                NSLog(@"creating fasttoslow");
                NSArray * workoutSongs = [self.bpmLibrary createFastToSlow:self.workoutTime.intValue];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [me calculateActualTime:workoutSongs];
                    me.intervals = self.bpmLibrary.fastToSlowIntervals;
                    me.workoutSongs = workoutSongs;
                    afterGenerated();
               
                });
            });
            generated = YES;
        } else if ([self.workoutType isEqualToString:@"slowToFast"]) {
            dispatch_async(listmakerqueue, ^{
            NSLog(@"creating slowToFast");
            NSArray * workoutSongs = [self.bpmLibrary createSlowToFast:self.workoutTime.intValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                    [me calculateActualTime:workoutSongs];
                     me.intervals = self.bpmLibrary.slowToFastIntervals;
                     me.workoutSongs = workoutSongs;
                     afterGenerated();
               
                });
            });
            generated = YES;
        }
    }
    return generated;

}

-(void) calculateActualTime:(NSArray *)songs
{
    __block NSInteger totalTime = 0;
    [songs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MusicLibraryItem * item = (MusicLibraryItem *) obj;
        totalTime += [[item.mediaItem valueForProperty:MPMediaItemPropertyPlaybackDuration] intValue];
        NSLog(@"total time: %d", totalTime);
    }];
    self.actualWorkoutTime = [NSNumber numberWithInt:totalTime];
    NSLog(@"actualWorkoutTime:%d", self.actualWorkoutTime.intValue);

}
@end
