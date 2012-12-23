//
//  MusicLibraryBPMs.h
//  WorkoutMusic
//
//  Created by John La Barge on 11/15/12.
//  Copyright (c) 2012 John La Barge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MusicBPMEntry.h"
#import "ENAPI.h"
/*
 * Your API Key: 4N3RGRQDQPUETU3BV
 
 Your Consumer Key: 433d5d6e8f39a40ea0fed4bff7556acd
 
 Your Shared Secret: jTppHq3qQCaeF3+kUgbmTQ
 *
 *
 *
 */

@interface MusicLibraryBPMs : NSObject <ENAPIRequestDelegate> {
    NSString * apiKey;
    NSArray * libraryItems;
    NSArray * unfilteredItems; 
}

+(NSArray *) getMusicItems;
@property (nonatomic, retain) NSArray * libraryItems;
@property (nonatomic, retain) NSArray * unfilteredItems;
@property (nonatomic, retain) NSManagedObjectContext * managedObjectContext;

-(id)initWithManagedObjectContext:(NSManagedObjectContext *)moc;
-(void) processItunesLibrary:(void (^)(void)) itemUpdated;
- (void)requestFinished:(ENAPIRequest *)request;
- (void)requestFailed:(ENAPIRequest *)request;
- (void)filterWithMin:(NSInteger)min andMax:(NSInteger)max;
- (void)unfilter;
@end

@interface MusicLibraryItem : NSObject {
    
    MPMediaItem * mediaItem;
    double bpm;
}
-(id) initWithMediaItem:(MPMediaItem *)theMediaItem;
@property double bpm;
@property (nonatomic, retain) MPMediaItem *mediaItem;
@end;