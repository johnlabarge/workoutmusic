//
//  MusicLibraryBPMs.m
//  WorkoutMusicSlow//
//  Created by John La Barge on 11/15/12.
//  Copyright (c) 2012 John La Barge. All rights reserved.
//

#import "MusicLibraryBPMs.h"
#import "WorkoutMusicSettings.h"
#import "WOMusicAppDelegate.h"
#import "Tempo.h"



@interface MusicLibraryBPMs() {
    dispatch_queue_t _requestQueue;
}
typedef void(^ItemUpdatedCallback)(MusicLibraryItem *);
typedef void(^ItemUpdater)(ENAPIRequest *);

typedef NSString*(^Classifier)(MusicLibraryItem *);
typedef ItemUpdater(^Updater)(MusicLibraryItem *, ItemUpdatedCallback);

@property (nonatomic, strong) dispatch_queue_t itemSaverQueue;


@property (nonatomic, strong) NSArray * filters;
@property (nonatomic, strong) Updater updater;
@property (nonatomic, strong) NSMutableArray * pendingAPIRequests;
@property (nonatomic, strong) Classifier musicClassifier;
@property (nonatomic, strong) NSManagedObjectContext * requestMoc;

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
    
   // self.musicClassifier = [[self class] energyTimesBPMClassifier];
    self.musicClassifier = [[self class] energyClassifier];
    self.override_notfound = NO;
    self.unfilteredItems = self.libraryItems;
    self.managedObjectContext = moc;
    self.processed = NO;
    [self initENAPI];
    [self initMusicItems];
    [self createUpdater];                                                         
    return self;
}
-(void) initENAPI
{
    [ENAPIRequest setApiKey:@"4N3RGRQDQPUETU3BV" andConsumerKey:@"433d5d6e8f39a40ea0fed4bff7556acd" andSharedSecret:@"jTppHq3qQCaeF3+kUgbmTQ"];
    _requestQueue = dispatch_queue_create("echnoest_request_queue", NULL);
    self.pendingAPIRequests = [[NSMutableArray alloc] initWithCapacity:50];
}
-(void) initMusicItems
{
    NSArray * mpItems = [MusicLibraryBPMs getMusicItems];
    self.libraryItems = [[NSMutableArray alloc] initWithCapacity:mpItems.count];
    
    NSMutableArray * mutLibraryItems = (NSMutableArray *) self.libraryItems;
    for (MPMediaItem * item in mpItems)
    {
        [mutLibraryItems addObject:[[MusicLibraryItem alloc] initWithMediaItem:item]];
    }
    __weak MusicLibraryBPMs * me = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        me.totalNumberOfItems = me.libraryItems.count;
    });
    
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
    [[Tempo classifications] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSMutableArray * items = self.classifiedItems[obj];
        [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            MusicLibraryItem * item = (MusicLibraryItem *)obj;
            if (item.isICloudItem) {
                [items removeObject:item];
                self.didContainICloudItems = YES;
            }
            
        }];
       }
     ];
    [self.libraryItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MusicLibraryItem * item = obj;
        if (item.isICloudItem) {
            [self.libraryItems removeObject:item];
            self.didContainICloudItems = YES;
        }
        
    }];
}

-(void) pruneOldDRMItems
{
    [[Tempo classifications] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSMutableArray * items = self.classifiedItems[obj];
        [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            MusicLibraryItem * item = (MusicLibraryItem *)obj;
            if (item.isOldDRM) {
                [items removeObject:item];
                self.didContainOldDRMItems = YES;
            }
            
        }];
    }
     ];
    [self.libraryItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MusicLibraryItem * item = obj;
        if (item.isOldDRM) {
            [self.libraryItems removeObject:item];
            self.didContainOldDRMItems = YES;
        }
        
    }];
}
-(void) applyAudioSummary:(NSDictionary *)summary toMusicItem:(MusicLibraryItem *)item
{
    double danceability = [[summary valueForKeyPath:@"audio_summary.danceability"] doubleValue];
    double liveliness = [[summary valueForKeyPath:@"audio_summary.liveliness"] doubleValue];
    
    double tempo = [[summary valueForKeyPath:@"audio_summary.tempo"] doubleValue];
    item.energy = [[summary valueForKeyPath:@"audio_summary.energy"] doubleValue];
    item.bpm = tempo;
    item.danceability = danceability;
    item.liveliness = liveliness;
    [self saveMusicBPMEntryInCache:item];
    
   
}

-(void) createUpdater {
     self.itemSaverQueue = dispatch_queue_create("item saver", NULL);
    __weak typeof(self)weakSelf = self;
    self.updater = ^(MusicLibraryItem *item, ItemUpdatedCallback callback) {
        
        __weak MusicLibraryItem * weakItem = item;
        __weak ItemUpdatedCallback weakCallback = callback;
        
        
        return ^(ENAPIRequest * request) {
            
            if (200 == request.httpResponseCode) {
                __weak ENAPIRequest *req = request;
                
                
                    NSArray * songs = [req.response valueForKeyPath:@"response.songs"];
                    if (songs.count > 0) {
                        NSDictionary * song = [songs objectAtIndex:0];
                        [weakSelf applyAudioSummary:song toMusicItem:weakItem];
                        weakCallback(item);
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
        __weak typeof(self) weakSelf = self;
    
    dispatch_async(_requestQueue, ^{
        weakSelf.requestMoc = [[NSManagedObjectContext alloc ]init];
        /*
          TODO fix encapsulation */
        WOMusicAppDelegate * app = (WOMusicAppDelegate *) [UIApplication sharedApplication].delegate;
        [weakSelf.requestMoc setPersistentStoreCoordinator:app.persistentStoreCoordinator];
    });
    NSLog(@"processing itunes library....%lu items",(unsigned long)self.libraryItems.count);

    
    void(^afterUpdating)(MusicLibraryItem *) = ^(MusicLibraryItem * item) {
        [weakSelf addToClassificationBucket:item];
        itemUpdated(item);
    };
    int count = 0;
    for (int i=0; i < self.libraryItems.count; i++) {
        BOOL last = (i == (self.libraryItems.count - 1));
        if (last) NSLog(@"Processing last music item...");
        MusicLibraryItem *mi = self.libraryItems[i];
        
        beforeUpdatingItem(mi);
        if (mi.bpm == 0) {
            dispatch_async(_requestQueue, ^{
                
                [self lookupBPMFor:mi whenUpdated:afterUpdating last:last];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"media_processed"
                                                                    object:weakSelf
                                                                  userInfo:@{@"currentIndexBeingProcessed":[NSNumber numberWithInteger:count],
                                                                             @"itemBeingProcessed":mi,
                                                                             @"totalItems":[NSNumber numberWithInteger:weakSelf.libraryItems.count]}];

                [[NSRunLoop currentRunLoop]run];
            });
            
        }
        count++;
    }

    self.processed = YES;
}
-(void) addToClassificationBucket:(MusicLibraryItem *)item
{
    if (!self.classifiedItems) {
        self.classifiedItems = [[NSMutableDictionary alloc] initWithCapacity:self.libraryItems.count];
    }
    
    NSString * classification = self.musicClassifier(item);
    if (!self.classifiedItems[classification]) {
        self.classifiedItems[classification] = [[NSMutableArray alloc] initWithCapacity:self.libraryItems.count/4];
    }
    [self.classifiedItems[classification] addObject:item];
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
        item.danceability =  [entry.danceability doubleValue];
        item.bpm = [entry.bpm doubleValue];
        item.energy = energy;
        
        itemUpdated(item);
    } else if ((![entry.notfound boolValue]) || self.override_notfound){
        NSLog(@"ECHONEST - going to echonest for %@ - %@ ", artist, title);
      
        [self lookupBPMFromEchonest:item whenUpdated:itemUpdated artist:lookupArtist song:lookupTitle];
    }
    
    if (last) {
        self.processed = YES;
        if (self.shouldPruneICloudItems) {
            [self pruneICloudItems];
        }
        [self pruneOldDRMItems];
        [[NSNotificationCenter defaultCenter ] postNotificationName:@"workoutsongsprocessed" object:self];
    }

}



-(void) saveMusicBPMEntryInCache:(MusicLibraryItem *) item
{
    
    
    __weak NSString * artist = [item.mediaItem valueForProperty:MPMediaItemPropertyArtist];
    __weak NSString * title  = [item.mediaItem valueForProperty:MPMediaItemPropertyTitle];
    __weak MusicLibraryItem * weakItem = item;
    NSLog(@"Saving song : %@ by %@", title, artist);
    [self.managedObjectContext lock];
    [self.managedObjectContext performBlock:^{
        MusicBPMEntry *entry = (MusicBPMEntry *)[NSEntityDescription insertNewObjectForEntityForName:@"MusicBPMEntry" inManagedObjectContext:managedObjectContext];
        entry.artist = artist;
        entry.title = title;
        entry.bpm = [[NSNumber alloc ] initWithDouble:weakItem.bpm];
        entry.energy = [[NSNumber alloc] initWithDouble:weakItem.energy];
        entry.notfound = [[NSNumber alloc] initWithBool:weakItem.notfound];
        entry.danceability = [[NSNumber alloc] initWithDouble:weakItem.danceability];
        entry.liveliness = [[NSNumber alloc] initWithDouble:weakItem.liveliness];
        
        
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
        if (error != nil) {
            NSLog(@"error: %@", error.localizedDescription);
        }
        
    }];
    [self.managedObjectContext unlock];
    
}

-(MusicBPMEntry *) findBPMEntryInCacheFor:(NSString *)artist andTitle:(NSString *)title
{
    NSLog(@"****** finding BMP Entry in cache******");
    NSLog(@"looking for artist=%@ and title=%@",artist,title);
    MusicBPMEntry * entry = nil;
    NSManagedObjectContext *moc = self.requestMoc;
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
    
  
        NSArray *array;
        NSError *error;
       array = [moc executeFetchRequest:request error:&error];

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
    NSLog(@"callingq....");
    ENAPIRequest * request;
    if (theArtist && theSong) {
      [NSThread sleepForTimeInterval:0.5];
        request = [ENAPIRequest GETWithEndpoint:@"song/search"
                                            andParameters:@{@"artist": theArtist,
                                                            @"title" : theSong,
                                                            @"bucket": @"audio_summary",
                                                            @"results": @1}
                             andCompletionBlock:[self.updater(item,itemUpdated) copy]
                      ];
        
    } else {
        [NSThread sleepForTimeInterval:0.5];
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
    self.unfilteredItems = self.libraryItems;
    self.libraryItems = self.classifiedItems[classification];
}

-(NSString *)classificationForMusicItem:(MusicLibraryItem *)item
{
    return self.musicClassifier(item);
}
+(Classifier) energyClassifier {

   return ^NSString *(MusicLibraryItem * item) {
        if (item.energy < 0.3 && item.energy > 0.01) {
            return [Tempo speedDescription:SLOW];
        } else if (item.energy < 0.65) {
            return [Tempo speedDescription:MEDIUM];
        } else if (item.energy < 0.89) {
            return [Tempo speedDescription:FAST];
        } else if (item.energy > 0.89){
            return [Tempo speedDescription:VERYFAST];
        } else {
            return [Tempo speedDescription:UNKNOWN];
        }
    };
}
+(Classifier) energyTimesBPMClassifier {
   
    return ^NSString *(MusicLibraryItem *item) {
        
        double value = ((item.energy*3)+(1*(item.bpm/170)))/4;
        if (value > .80)  {
            return [Tempo speedDescription:VERYFAST];
        } else if (value> .75) {
            return [Tempo speedDescription:FAST];
        } else if (value > .55) {
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


-(NSMutableArray *) randomItemsForIntensity:(NSString *)classification {
    return [self.classifiedItems[classification] shuffle];
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
        /*
         * Todo - sort this array by song title
         */
        [result addObjectsFromArray:self.classifiedItems[obj]];
        
    }];

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
    
    return [[self.mediaItem valueForProperty:MPMediaItemPropertyIsCloudItem] boolValue];
    
}

-(BOOL) isOldDRM
{
    return (self.url == nil); 
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


