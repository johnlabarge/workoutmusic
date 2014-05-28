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
#import "NSMutableArray+Shuffle.h"
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
}
/*
 * class methods ....
 */
+(NSArray *) getMusicItems;

/*
 *   instance properties
 */
@property (nonatomic, assign) BOOL loaded;
/* TODO don't expose mutable array.
 */
@property (nonatomic, strong) NSMutableArray *libraryItems;
@property (nonatomic, strong) NSMutableArray * unfilteredItems;
@property (nonatomic, strong) NSArray * sortedItems;
@property (nonatomic, retain) NSManagedObjectContext * managedObjectContext;

@property (nonatomic, strong) MusicLibraryItem *itemBeingProcessed;
@property (nonatomic, assign) NSUInteger totalNumberOfItems;
@property (nonatomic, assign) NSUInteger currentIndexBeingProcessed;
@property (nonatomic, assign) BOOL shouldPruneICloudItems;
@property (nonatomic, assign) BOOL didContainICloudItems;
@property (nonatomic, assign) BOOL didContainOldDRMItems; 
@property (nonatomic, assign) BOOL override_notfound;
@property (nonatomic, assign) BOOL processed;
@property (nonatomic, strong) NSMutableDictionary * classifiedItems;
+(instancetype) currentInstance:(id)instance;

-(id)initWithManagedObjectContext:(NSManagedObjectContext *)moc;
-(void) processItunesLibrary;
- (void)unfilter;
-(NSArray *) sortByClassification; 
-(NSString *) classificationForMusicItem:(MusicLibraryItem *)item;
-(NSMutableArray *) randomItemsForIntensity:(NSString *)classification;

/**
 * random MusicLibraryItems
 */

-(NSArray *) randomItemsForTempo:(NSInteger)tempo andDuration:(NSInteger)seconds;

@end

@interface MusicLibraryItem : NSObject <NSCopying>
@property (nonatomic, assign) double energy;
@property (nonatomic, assign) double danceability;
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
@property (readonly) MPMediaItemArtwork * artwork;
@property (nonatomic, assign) BOOL overridden;
@property (nonatomic, assign) BOOL notfound;
@property (nonatomic, assign) double loudness;
@property (nonatomic, assign) NSUInteger overridden_intensity;
@property (readonly) NSString * albumArtist;
@property (nonatomic, strong) MusicBPMEntry * cacheEntry; 

-(void) applyMusicBPMEntry:(MusicBPMEntry *)entry;
-(BOOL) isICloudItem;
-(BOOL) isOldDRM;

-(void) overrideIntensityTo:(NSInteger)intensityNum;
-(void) clearOverride;

@end;