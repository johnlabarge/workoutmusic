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
#import "NSArray+Shuffle.h"
#import "ENAPI.h"
#import "Tempo.h"


#define APPROX_TIME @"approxTime"
#define TEMPO @"tempo"
#define DESC @"description"
#define SLOPSECONDS 60

@class MusicLibraryItem;
/*
 * Your API Key: 4N3RGRQDQPUETU3BV
 
 Your Consumer Key: 433d5d6e8f39a40ea0fed4bff7556acd
 
 Your Shared Secret: jTppHq3qQCaeF3+kUgbmTQ
 *
 *
 *
 */

@interface MusicLibraryBPMs : NSObject {
    NSString * apiKey;
    NSArray * libraryItems;
    NSArray * unfilteredItems; 
}
/*
 * class methods ....
 */
+(NSArray *) getMusicItems;

/*
 *   instance properties
 */
@property (nonatomic, assign) BOOL loaded; 
@property (nonatomic, retain) NSArray * libraryItems;
@property (nonatomic, retain) NSArray * unfilteredItems;
@property (nonatomic, retain) NSManagedObjectContext * managedObjectContext;

@property (nonatomic, strong) MusicLibraryItem *itemBeingProcessed;
@property (nonatomic, assign) NSUInteger totalNumberOfItems;
@property (nonatomic, assign) NSUInteger currentIndexBeingProcessed;

-(id)initWithManagedObjectContext:(NSManagedObjectContext *)moc;
-(void) processItunesLibrary:(void (^)(MusicLibraryItem * item))beforeUpdatingItem  afterUpdatingItem:( void (^)(MusicLibraryItem *item ) ) itemUpdated;
- (void)filterWithMin:(NSInteger)min andMax:(NSInteger)max;
- (void)unfilter;

/**
 * random MusicLibraryItems
 */

-(NSArray *) randomItemsForTempo:(NSInteger)tempo andDuration:(NSInteger)seconds;

@end

@interface MusicLibraryItem : NSObject <NSCopying>
-(id) initWithMediaItem:(MPMediaItem *)theMediaItem;
-(id) copyWithZone:(NSZone *)zone;
@property double bpm;
@property (nonatomic, strong) MPMediaItem *mediaItem;          /* Todo: a bit of a hack to hang*/
@property (nonatomic, strong) NSString * intervalDescription;  /* these properties on the item object.*/
@property (readonly) NSString * tempoClassification;
@property (nonatomic, assign) NSInteger intervalIndex;
@property (readonly) NSInteger durationInSeconds;
@property (readonly) NSString * title;
@property (readonly) NSString * artist;
@end;