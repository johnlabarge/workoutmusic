//
//  MusicLibraryBPMs.m
//  WorkoutMusicSlow//
//  Created by John La Barge on 11/15/12.
//  Copyright (c) 2012 John La Barge. All rights reserved.
//

#import "MusicLibraryBPMs.h"
#import "WorkoutMusicSettings.h"
#import "Tempo.h"



@interface MusicLibraryBPMs() {
    dispatch_queue_t _requestQueue;
}
typedef void(^ItemUpdatedCallback)(MusicLibraryItem *);
typedef void(^ItemUpdater)(ENAPIRequest *);

typedef NSString*(^Classifier)(MusicLibraryItem *);
typedef ItemUpdater(^Updater)(MusicLibraryItem *, ItemUpdatedCallback);

@property (nonatomic, strong) dispatch_queue_t itemSaverQueue;

@property (nonatomic, assign) BOOL processed;
@property (nonatomic, strong) NSArray * filters;
@property (nonatomic, strong) Updater updater;
@property (nonatomic, strong) NSMutableArray * pendingAPIRequests;
@property (nonatomic, strong) Classifier musicClassifier;

-(void) lookupBPMFor:(MusicLibraryItem *)item whenUpdated: (ItemUpdatedCallback) itemUpdated;
-(MusicBPMEntry *) findBPMEntryInCacheFor:(NSString *)artist andTitle:(NSString *)title;
-(void) saveMusicBPMEntryInCache:(MusicLibraryItem *) item;
-(void) addRequest:(ENAPIRequest *)request;
@end
@implementation MusicLibraryBPMs
@synthesize unfilteredItems;
@synthesize managedObjectContext;



-(id) initWithManagedObjectContext:(NSManagedObjectContext *)moc
{
    self.filters = [Tempo ranges];
    
    self.musicClassifier = [[self class] energyTimesBPMClassifier];
    self.override_notfound = NO;
    //self.musicClassifier = [[self class] energyClassifier];
    
    _requestQueue = dispatch_queue_create("echnoest_request_queue", NULL);
    
    [ENAPIRequest setApiKey:@"4N3RGRQDQPUETU3BV" andConsumerKey:@"433d5d6e8f39a40ea0fed4bff7556acd" andSharedSecret:@"jTppHq3qQCaeF3+kUgbmTQ"];
    NSArray * mpItems = [MusicLibraryBPMs getMusicItems];
    self.pendingAPIRequests = [[NSMutableArray alloc] initWithCapacity:50];
    self.libraryItems = [[NSMutableArray alloc] initWithCapacity:mpItems.count];
    __block MusicLibraryBPMs * me = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        me.totalNumberOfItems = me.libraryItems.count;
    });
    
    NSMutableArray * mutLibraryItems = (NSMutableArray *) self.libraryItems;
    for (MPMediaItem * item in mpItems)
    {
        [mutLibraryItems addObject:[[MusicLibraryItem alloc] initWithMediaItem:item]];
    }
    self.unfilteredItems = self.libraryItems;
    self.managedObjectContext = moc;
    self.processed = NO;
    [self createUpdater];                                                         
    return self;
}

+(instancetype) currentInstance:(id)instance
{
    static id _currentInstance;
    if (instance != nil && _currentInstance != instance) {
        _currentInstance = instance;
    }
    return _currentInstance;
}

-(void) pruneICloudItems
{
    [self.libraryItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MusicLibraryItem * item = obj;
        if (item.isICloudItem) {
            [self.libraryItems removeObject:item];
            self.didContainICloudItems = YES;
        }
        
    }];
}

-(void) createUpdater {
     self.itemSaverQueue = dispatch_queue_create("item saver", NULL);
    __weak typeof(self)weakSelf = self;
    self.updater = ^(MusicLibraryItem *item, ItemUpdatedCallback callback) {
        
        MusicLibraryItem * weakItem = item;
        __weak ItemUpdatedCallback weakCallback = callback;
        
        
        return ^(ENAPIRequest * request) {
            
            if (200 == request.httpResponseCode) {
                __weak ENAPIRequest *req = request;
                
                
                    NSArray * songs = [req.response valueForKeyPath:@"response.songs"];
                    if (songs.count > 0) {
                        NSDictionary * song = [songs objectAtIndex:0];
                        NSLog(@"%@ ",[song valueForKeyPath:@"audio_summary.danceability"]);
                        double tempo = [[song valueForKeyPath:@"audio_summary.tempo"] doubleValue];
                        weakItem.energy = [[song valueForKeyPath:@"audio_summary.energy"] doubleValue];
                        weakItem.bpm = tempo;
                        [weakSelf saveMusicBPMEntryInCache:weakItem];
                        weakCallback(weakItem);
                        
                    } else {
                        weakItem.notfound = YES;
                        [weakSelf saveMusicBPMEntryInCache:weakItem];
                        weakCallback(weakItem);
                        NSLog(@"no song found at echonest for %@-%@", weakItem.artist, weakItem.title);
                    }
                    
                
            } else {
                NSLog(@"\n\n NON 200 RESPONSE ");
                
                NSLog(@"%lu", (unsigned long) request.httpResponseCode);
            }
            
            
            [weakSelf.pendingAPIRequests removeObject:request];

        };
    };
}

-(void) processItunesLibrary:(void (^)(MusicLibraryItem * item))beforeUpdatingItem  afterUpdatingItem:( void (^)(MusicLibraryItem * item) ) itemUpdated
{
    NSLog(@"processing itunes library....%lu items",(unsigned long)self.libraryItems.count);
    __weak MusicLibraryBPMs * me = self;
    int count = 0;
    for (int i=0; i < self.libraryItems.count; i++) {
        BOOL last = (i == (self.libraryItems.count - 1));
        if (last) NSLog(@"Processing last music item...");
        MusicLibraryItem *mi = self.libraryItems[i];
        
        beforeUpdatingItem(mi);
        if (mi.bpm == 0) {
            dispatch_async(_requestQueue, ^{
                [self lookupBPMFor:mi whenUpdated:itemUpdated last:last];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"media_processed"
                                                                    object:me
                                                                  userInfo:@{@"currentIndexBeingProcessed":[NSNumber numberWithInteger:count],
                                                                             @"itemBeingProcessed":mi,
                                                                             @"totalItems":[NSNumber numberWithInteger:me.libraryItems.count]}];

                [[NSRunLoop currentRunLoop]run];
            });
            
        }
        count++;
    }
    if (self.shouldPruneICloudItems) {
        [self pruneICloudItems];
    }
    self.processed = YES;
}


-(void) lookupBPMFor:(MusicLibraryItem *)item whenUpdated: ( void (^)(MusicLibraryItem *) ) itemUpdated last:(BOOL)last {
    
    
    NSString * artist = [item.mediaItem valueForProperty:MPMediaItemPropertyArtist];
    NSString * title  = [item.mediaItem valueForProperty:MPMediaItemPropertyTitle];
    NSString * lookupArtist = artist;
    NSString * lookupTitle = title;
    if (!artist || [[artist stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        NSArray * strings = [title componentsSeparatedByString:@"-"];
        lookupArtist = [strings[0] stringByReplacingOccurrencesOfString:@" " withString:@""];
        lookupTitle = [strings[1] stringByReplacingOccurrencesOfString:@" " withString:@""];
       
    }
    MusicBPMEntry * entry =  [self findBPMEntryInCacheFor:artist andTitle:title];
    double energy = [entry.energy doubleValue];
    if (entry != nil && energy != 0.0) {
        NSLog(@"COREDATA - found %@ - %@ in database", artist, title);
        item.bpm = [entry.bpm doubleValue];
        item.energy = energy;
        itemUpdated(item);
    } else if ((![entry.notfound boolValue]) || self.override_notfound){
        NSLog(@"ECHONEST - going to echonest for %@ - %@ ", artist, title);
      
        [self lookupBPMFromEchonest:item whenUpdated:itemUpdated artist:lookupArtist song:lookupTitle];
    }
    if (last) {
        [[NSNotificationCenter defaultCenter ] postNotificationName:@"workoutsongsprocessed" object:self];
    }

}



-(void) saveMusicBPMEntryInCache:(MusicLibraryItem *) item
{
    
    
    __weak NSString * artist = [item.mediaItem valueForProperty:MPMediaItemPropertyArtist];
    __weak NSString * title  = [item.mediaItem valueForProperty:MPMediaItemPropertyTitle];
    __weak MusicLibraryItem * weakItem = item;
    NSLog(@"Saving song : %@ by %@", title, artist);
   [self.managedObjectContext performBlock:^{
    MusicBPMEntry *entry = (MusicBPMEntry *)[NSEntityDescription insertNewObjectForEntityForName:@"MusicBPMEntry" inManagedObjectContext:managedObjectContext];
    entry.artist = artist;
    entry.title = title;
    entry.bpm = [[NSNumber alloc ] initWithDouble:weakItem.bpm];
    entry.energy = [[NSNumber alloc] initWithDouble:weakItem.energy];
    entry.notfound = [[NSNumber alloc] initWithBool:weakItem.notfound];
    entry.danceability = [[NSNumber alloc] initWithDouble:weakItem.danceability];
  
    
          NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
            NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
            if(detailedErrors != nil && [detailedErrors count] > 0) {
                for(NSError* detailedError in detailedErrors) {
                    NSLog(@"error : %@", detailedError.localizedDescription);
                }
            }
            else {
                NSLog(@"  %@", error.localizedDescription);
            }
        }
       NSLog(@"total managed Objects: %lu", (unsigned long)self.managedObjectContext.registeredObjects.count);
       if (error != nil) {
           NSLog(@"error: %@", error.localizedDescription);
       }

    }];
    
}

-(MusicBPMEntry *) findBPMEntryInCacheFor:(NSString *)artist andTitle:(NSString *)title
{
    NSLog(@"****** finding BMP Entry in cache******");
    NSLog(@"looking for artist=%@ and title=%@",artist,title);
    MusicBPMEntry * entry = nil;
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"MusicBPMEntry" inManagedObjectContext:moc];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MusicBPMEntry"];
    [request setEntity:entityDescription];
    NSString * predicateS;
    NSPredicate * predicate;
    
    /*
     * TODO: more sophisticated way of pulling artist/title from song title.
     */
    
    if (artist && title) {
        predicateS = [NSString stringWithFormat:@"(artist like '%@') AND (title like '%@')", artist, title];
        predicate = [NSPredicate predicateWithFormat:@"(artist like %@) AND (title like %@)",artist, title];
    } else if (title) {
        predicateS = [NSString stringWithFormat:@"(title like '%@')", title];
        predicate = [NSPredicate predicateWithFormat:@"(title like %@)",title];
    }
    NSLog(@"resulting predicate string = %@",predicateS);
    if (predicateS) {
        
    
        [request setPredicate:predicate];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"artist" ascending:YES];
        [request setSortDescriptors:@[sortDescriptor]];
    
        NSError *error;
        NSArray *array = [moc executeFetchRequest:request error:&error];
        NSLog(@"***** found %lu entries matching %@ and %@", (unsigned long)array.count, artist, title);
   
        if (array == nil) {
            NSLog(@" nil array from coredata request, error: %@", error.localizedDescription);
        }
    
        if (array.count > 0) {
            NSLog(@"Found %d matching musicBPM entries",(int) array.count);
            entry = (MusicBPMEntry *) array[0];
        }
    }
 
    NSLog(@"returning entry: %@ - %@ bpm:%.2f energy:%.2f", entry.artist, entry.title, entry.bpm.doubleValue, entry.energy.doubleValue);
    return entry;
}

-(void) lookupBPMFromEchonest:(MusicLibraryItem *)item whenUpdated:(ItemUpdatedCallback)itemUpdated artist:(NSString *)theArtist song:(NSString *)theSong {
    NSLog(@"calling echonest....");
    ENAPIRequest * request;
    if (theArtist && theSong) {
      [NSThread sleepForTimeInterval:0.6];
        request = [ENAPIRequest GETWithEndpoint:@"song/search"
                                            andParameters:@{@"artist": theArtist,
                                                            @"title" : theSong,
                                                            @"bucket": @"audio_summary",
                                                            @"results": @1}
                             andCompletionBlock:[self.updater(item,itemUpdated) copy]
                      ];
        
    } else {
        [NSThread sleepForTimeInterval:0.6];
        request = [ENAPIRequest GETWithEndpoint:@"song/search"
                                  andParameters:@{
                                                  @"title" : theSong,
                                                  @"bucket": @"audio_summary",
                                                  @"results": @1}
                             andCompletionBlock:[self.updater(item,itemUpdated) copy]
                   ];
     
    }
    NSLog(@"url: %@", [request.url absoluteString] );
    [self addRequest:request];
 
}



-(void) addRequest:(ENAPIRequest *)request
{
    [self.pendingAPIRequests addObject:request];
}


+(NSArray *) getMusicItems
{
    MPMediaQuery *playlistQuery = [MPMediaQuery playlistsQuery];
    NSArray * playlists = [playlistQuery collections];
  
    MPMediaItemCollection *workOutPlaylist;
    NSLog(@"looking for playlist: %@", [WorkoutMusicSettings workoutSongsPlaylist]);
    for (MPMediaItemCollection * playlist in playlists) {
        
        NSLog(@"found play list: %@",[playlist valueForProperty:MPMediaPlaylistPropertyName]);
        if ([[playlist valueForProperty:MPMediaPlaylistPropertyName] isEqualToString:[WorkoutMusicSettings workoutSongsPlaylist]]) {
             workOutPlaylist = playlist;
             break;
        }
    }
    NSArray * workoutItems;
    if (workOutPlaylist != nil) {
        workoutItems = [workOutPlaylist items];
        for (MPMediaItem *song in workoutItems) {
            NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
            NSLog (@"%@", songTitle);
        }
    }
 
    
    NSLog(@"found %lu workoutItems",(unsigned long)workoutItems.count);
    return workoutItems;
    
}


#pragma mark filtering
-(void) filterByClassification:(NSString *)classification
{
    self.libraryItems = [self doFilter:self.unfilteredItems withClassification:classification andClassifier:self.musicClassifier];
}

-(NSString *)classificationForMusicItem:(MusicLibraryItem *)item
{
    return self.musicClassifier(item);
}
+(Classifier) energyClassifier {

   return ^NSString *(MusicLibraryItem * item) {
        if (item.energy < 0.3 && item.energy > 0.01) {
            return [Tempo speedDescription:SLOW];
        } else if (item.energy < 0.6) {
            return [Tempo speedDescription:MEDIUM];
        } else if (item.energy < 0.92) {
            return [Tempo speedDescription:FAST];
        } else {
            return [Tempo speedDescription:VERYFAST];
        }
    };
}
+(Classifier) energyTimesBPMClassifier {
   
    return ^NSString *(MusicLibraryItem *item) {
        
        double value = ((item.energy*3)+(2*(item.bpm/170)))/5;
        if (value > .86)  {
            return [Tempo speedDescription:VERYFAST];
        } else if (value> .7) {
            return [Tempo speedDescription:FAST];
        } else if (value > .5) {
            return [Tempo speedDescription:MEDIUM];
        } else if (value > .01) {
            return [Tempo speedDescription:SLOW];
        } else {
            return [Tempo speedDescription:UNKNOWN];
        }
    };
}
-(NSString *) tempoClassificationForItem:(MusicLibraryItem *)item {
    
    return ^NSString *(MusicLibraryItem * item) {
        if (item.bpm >=60 && item.bpm <=95) {
            return [Tempo speedDescription:SLOW];
        } else if (item.bpm >=96 && item.bpm <=125) {
            return [Tempo speedDescription:MEDIUM];
        } else if (item.bpm >= 125 && item.bpm <=159) {
            return [Tempo speedDescription:FAST];
        }
        return [Tempo speedDescription:VERYFAST];
    };
}
-(void) processLibraryAndLogOutput
{
    [self processItunesLibrary:^(MusicLibraryItem *item) {
        NSLog(@"processing : %@", [item.mediaItem valueForProperty:MPMediaItemPropertyTitle]);
    } afterUpdatingItem:^(MusicLibraryItem *item) {
        NSLog(@"processed: %@", [item.mediaItem valueForProperty:MPMediaItemPropertyTitle]);
    }];

}
-(NSMutableArray *) doFilter:(NSArray *)list withClassification:(NSString *)classification  andClassifier:(Classifier)classify
{
    NSMutableArray * theFilteredItems = [[NSMutableArray alloc] initWithCapacity:[list count]];
    if (!self.processed) {
        [self processLibraryAndLogOutput];
    }
    __weak Classifier classifyIt = classify;
    __weak NSMutableArray * filtered = theFilteredItems;
    [list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MusicLibraryItem * item = (MusicLibraryItem *)obj;
        NSString * itemClassification =  classifyIt(item);
        if ([itemClassification isEqualToString:classification]) {
            [filtered addObject:item];
        }
        
    }];

    return theFilteredItems;
}
-(void) unfilter
{
    self.libraryItems = self.unfilteredItems;
}

-(void) applyFilter:(NSInteger)speed
{
    [self filterByClassification:[Tempo speedDescription:speed]];
}
-(NSArray *) randomItemsForTempo:(NSInteger) speed andDuration:(NSInteger) secondsLength
{
    [self applyFilter:speed];
    NSArray * theRandomItems = [self randomFilteredItems:secondsLength];
    [self unfilter];
    return theRandomItems;
}



-(NSArray *) randomFilteredItems:(NSInteger)secondsLength {
    
    NSMutableArray * array  = [[NSMutableArray alloc] initWithCapacity:3];
    NSArray * shuffledLibrary = [self.libraryItems shuffle];
    __block NSInteger totalLength = secondsLength;
   
    [shuffledLibrary enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
        MusicLibraryItem * item = (MusicLibraryItem *) obj;
        [array addObject:item];
        totalLength -= item.durationInSeconds;
         *stop = (totalLength <= 0);
    }];
    return array;
}


-(NSArray *) sortByClassification {
    
    NSMutableArray * result = [[NSMutableArray alloc] initWithCapacity:self.libraryItems.count];
    NSArray * classifications = [Tempo classifications];
    [classifications enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
       
        [self filterByClassification:obj];
        [self.libraryItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            [result addObject:obj];
        }];
        
    }];
    [self unfilter];

    self.sortedItems = result;
    return result;
}



@end

@implementation MusicLibraryItem /* TODO: merge with SongJockey stuff - redundant. */
-(id) initWithMediaItem:(MPMediaItem *)theMediaItem
{
    self.mediaItem = theMediaItem;
    return self;
}

-(id) copyWithZone:(NSZone *)zone
{
    MusicLibraryItem *another = [[MusicLibraryItem alloc] initWithMediaItem:[self.mediaItem copy]];
    another.intervalDescription = [self.intervalDescription copyWithZone:zone];
    another.intervalIndex = self.intervalIndex;
    another.bpm = self.bpm;
    return another;
}
-(NSInteger) durationInSeconds {
    NSNumber * songSecondsN = [self.mediaItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
    return songSecondsN.integerValue;
}




-(NSString *)tempoClassification
{
    return [Tempo tempoClassificationForBPM:self.bpm];
}

-(BOOL) isICloudItem
{
    BOOL mediaItemICloud = [[self.mediaItem valueForProperty:MPMediaItemPropertyIsCloudItem] boolValue];
    
    return ( mediaItemICloud || (self.url == nil) );
}

-(NSURL *) url
{
    return [self.mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
}
-(NSString *) title
{
    return [self.mediaItem valueForKey:MPMediaItemPropertyTitle];
}

-(NSString *) artist
{
    return [self.mediaItem valueForKey:MPMediaItemPropertyArtist];
}

-(MPMediaItemArtwork *) artwork
{
    return [self.mediaItem valueForKey:MPMediaItemPropertyArtwork];
}


@end


