//  MusicLibraryBPMs.m
//  WorkoutMusicSlow//
//  Created by John La Barge on 11/15/12.
//  Copyright (c) 2012 John La Barge. All rights reserved.
//

#import "MusicLibraryBPMs.h"
#import "WorkoutMusicSettings.h"
#import "WOMusicAppDelegate.h"
#import "Tempo.h"
#import "Reachability.h" 
#import <math.h>

#define MIN_TEMPO 50
#define MAX_TEMPO 180




@interface MusicLibraryBPMs() {
    dispatch_queue_t _requestQueue;
}
typedef void(^ItemUpdatedCallback)(MusicLibraryItem *);
typedef void(^ItemUpdater)(ENAPIRequest *);

typedef NSString*(^Classifier)(MusicLibraryItem *);
typedef ItemUpdater(^Updater)(MusicLibraryItem *, ItemUpdatedCallback);

@property (nonatomic, strong) dispatch_queue_t itemSaverQueue;

@property (nonatomic, assign) NSUInteger requestsRemaining;
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
  //  self.musicClassifier = [[self class] energyClassifier];
    self.musicClassifier = [[self class] livelinessClassifier];
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
    self.requestsRemaining = 120; 
}
-(void) initMusicItems
{
    NSArray * mpItems = [MusicLibraryBPMs getMusicItems];
    self.libraryItems = [[NSMutableArray alloc] initWithCapacity:mpItems.count];
    
    NSMutableDictionary * seenItems = [[NSMutableDictionary alloc] initWithCapacity:mpItems.count];
    NSMutableArray * mutLibraryItems = (NSMutableArray *) self.libraryItems;
    for (MPMediaItem * item in mpItems)
    {
        NSString * key = [NSString stringWithFormat:@"%@-%@",[item valueForProperty:MPMediaItemPropertyArtist], [item valueForProperty:MPMediaItemPropertyTitle]];
        if (!seenItems[key]) {
            [mutLibraryItems addObject:[[MusicLibraryItem alloc] initWithMediaItem:item]];
            seenItems[key] = item;
        }
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
    
    __weak typeof(self) weakSelf=self;
    
    [[Tempo classifications] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        __block NSMutableIndexSet * deletions = [[NSMutableIndexSet alloc] init];
        NSMutableArray * items = weakSelf.classifiedItems[obj];
        [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            MusicLibraryItem * item = (MusicLibraryItem *)obj;
            if (item.isICloudItem) {
                [deletions addIndex:idx];
                weakSelf.didContainICloudItems = YES;
            }
            
        }];
        if (weakSelf.didContainICloudItems) {
            [items removeObjectsAtIndexes:deletions];
        }
       }
     ];
    [self.libraryItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MusicLibraryItem * item = obj;
        if (item.isICloudItem) {
            [weakSelf.libraryItems removeObject:item];
            weakSelf.didContainICloudItems = YES;
        }
        
    }];
}

-(void) pruneOldDRMItems
{
    __weak typeof(self) weakSelf=self;
    
    [[Tempo classifications] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    
       
        NSMutableArray * items = self.classifiedItems[obj];
        __block NSMutableIndexSet * deletions = [[NSMutableIndexSet alloc] init];
        [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            MusicLibraryItem * item = (MusicLibraryItem *)obj;
            if (item.isOldDRM) {
                [deletions addIndex:idx];
                weakSelf.didContainOldDRMItems = YES;
            }
            
        }];
        [items removeObjectsAtIndexes:deletions];
    }
     ];
    [self.libraryItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MusicLibraryItem * item = obj;
        if (item.isOldDRM) {
            [weakSelf.libraryItems removeObject:item];
            weakSelf.didContainOldDRMItems = YES;
        }
        
    }];
}
-(void) applyAudioSummary:(NSDictionary *)summary toMusicItem:(MusicLibraryItem *)item
{
    double danceability = [[summary valueForKeyPath:@"audio_summary.danceability"] doubleValue];
    double loudness = [[summary valueForKeyPath:@"audio_summary.loudness"] doubleValue];
    
    double tempo = [[summary valueForKeyPath:@"audio_summary.tempo"] doubleValue];
    item.energy = [[summary valueForKeyPath:@"audio_summary.energy"] doubleValue];
    item.bpm = tempo;
    item.danceability = danceability;
    item.loudness = loudness;
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
                    weakSelf.requestsRemaining = [request.urlResponse.allHeaderFields[@"X-Ratelimit-Remaining"] integerValue];
                   if (weakSelf.requestsRemaining == 0) {
                       [NSThread sleepForTimeInterval:3.0];
                   }
                    NSLog(@"requests Remaining: %lu ", (unsigned long)weakSelf.requestsRemaining);
                    NSArray * songs = [request.response valueForKeyPath:@"response.songs"];
                    if (songs.count > 0) {
                        NSDictionary * song = [songs objectAtIndex:0];
                        [weakSelf applyAudioSummary:song toMusicItem:weakItem];
                        
                        [weakSelf addToClassificationBucket:weakItem];
                        weakCallback(item);
                        
                    } else {
                        weakItem.notfound = YES;
                        [weakSelf saveMusicBPMEntryInCache:weakItem];
                       
                        [weakSelf addToClassificationBucket:weakItem];
                         weakCallback(weakItem);
                        NSLog(@"####  \n #### \n no song found at echonest for %@-%@", weakItem.artist, weakItem.title);
                    }
                    
                
            } else {
                NSLog(@"\n\n NON 200 RESPONSE ");
                weakItem.notfound = YES;
                weakSelf.numberNotFound++;
                [weakSelf saveMusicBPMEntryInCache:weakItem];
                weakCallback(weakItem);
                NSLog(@"%lu", (unsigned long) request.httpResponseCode);
            }
            
            
            [weakSelf.pendingAPIRequests removeObject:request];

        };
    };
}
-(NSArray *) loadItemDataFromCacheAndReturnMissingItems:(void (^)(MusicLibraryItem * item, NSUInteger index))processedItem
{
    NSLog(@"-- begin loadItemsFromCacheAndReturnMissingItems");
 

    /*
     * build predicate for all the music items
     */
    NSMutableArray * itemsNotInCache = [[NSMutableArray alloc] initWithCapacity:50];
    NSManagedObjectContext *moc = self.managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"MusicBPMEntry" inManagedObjectContext:moc];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MusicBPMEntry"];
    [request setEntity:entityDescription];
   
    __weak typeof(self) weakSelf =self;
    [self.libraryItems  enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        MusicLibraryItem * item = (MusicLibraryItem *)obj;
        NSString * artist = item.artist;
        NSString * title = item.title;
        NSPredicate * predicate;
        
        if (artist && title) {
            predicate = [NSPredicate predicateWithFormat:@"(artist like %@) AND (title like %@)",artist, title];
        } else if (title) {
            predicate = [NSPredicate predicateWithFormat:@"(title like %@)",title];
        }
        [request setPredicate:predicate];
         NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                            initWithKey:@"artist" ascending:YES];
        [request setSortDescriptors:@[sortDescriptor]];
        
        
        NSArray *array;
        NSError *error;
        array = [moc executeFetchRequest:request error:&error];

        
        NSLog(@"***** found %lu entries matching %@ and %@", (unsigned long)array.count, artist, title);
        
        if (array == nil || array.count == 0) {
            NSLog(@" nil array from coredata request, error: %@", error.localizedDescription);
            [itemsNotInCache addObject:item];
        } else {
            
            
            MusicBPMEntry *entry = (MusicBPMEntry *)array[0];
            
            if ([entry.notfound boolValue] && weakSelf.override_notfound) {
                [itemsNotInCache addObject:item];
                item.cacheEntry = entry;
            }
            else  {
                NSLog(@"Found %d matching musicBPM entries",(int) array.count);
                MusicBPMEntry * entry = (MusicBPMEntry *) array[0];
                NSLog(@"COREDATA - found %@ - %@ in database", artist, title);
                [item applyMusicBPMEntry:entry];
                if (item.overridden) self.numberOfOverriddenItems++;
                if (item.notfound) self.numberNotFound++;
                item.cacheEntry = entry;
                [weakSelf addToClassificationBucket:item];
                processedItem(item,idx-itemsNotInCache.count);
                
            }
        }
        
    }];
    NSLog(@"%lu items not in cache",(unsigned long)itemsNotInCache.count);
    return itemsNotInCache;
}
-(void) processItunesLibrary {
        __weak typeof(self) weakSelf = self;
    self.classifiedItems = nil;
    dispatch_async(_requestQueue, ^{
        weakSelf.requestMoc = [[NSManagedObjectContext alloc ]init];
        /*
          TODO fix encapsulation */
        WOMusicAppDelegate * app = (WOMusicAppDelegate *) [UIApplication sharedApplication].delegate;
        [weakSelf.requestMoc setPersistentStoreCoordinator:app.persistentStoreCoordinator];
    });
    NSLog(@"processing itunes library....%lu items",(unsigned long)self.libraryItems.count);
    
    __block NSArray * itemsNotInCache;
    
    
        itemsNotInCache = [weakSelf loadItemDataFromCacheAndReturnMissingItems:^(MusicLibraryItem * item, NSUInteger index){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"media_processed"
                                                            object:weakSelf
                                                          userInfo:@{@"currentIndexBeingProcessed":[NSNumber numberWithInteger:index],
                                                                     @"itemBeingProcessed":item,
                                                                     @"totalItems":[NSNumber numberWithInteger:weakSelf.libraryItems.count]}];
        
    }];
   
    
    
  
    
    if (itemsNotInCache.count > 0) {
        

        NSUInteger last = itemsNotInCache.count -1;
        [itemsNotInCache enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MusicLibraryItem * item = (MusicLibraryItem *)obj;
                [weakSelf lookupBPMFromEchonest:item whenUpdated:^(MusicLibraryItem *item) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"media_processed"
                                                                        object:weakSelf
                                                                        userInfo:@{@"currentIndexBeingProcessed":[NSNumber numberWithInteger:(idx + (weakSelf.libraryItems.count - itemsNotInCache.count))],
                                                                                @"itemBeingProcessed":item,
                                                                             @"totalItems":[NSNumber numberWithInteger:weakSelf.libraryItems.count]}];
                    if (idx == last) {
                        [weakSelf pruneICloudItems];
                        [weakSelf pruneOldDRMItems];
                        [weakSelf finishProcessing];
                    }
                
            }];

            
        }];
        
    } else {
        [self pruneICloudItems];
        [self pruneOldDRMItems];
        [self finishProcessing];
    }
 
}

-(void) batchLookupFromEchonest:(NSArray *)items  each:(void (^)(MusicLibraryItem * item, NSUInteger index))processing after:(void (^)(void))done
{
    
    if (internetConnection()) {
        __block NSString *  taste_profile_id;
        NSMutableDictionary * musicItems = [[NSMutableDictionary alloc] initWithCapacity:items.count];
        [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MusicLibraryItem * item = (MusicLibraryItem *)obj;
            NSString * key = [NSString stringWithFormat:@"%@-%@",item.artist,item.title];
            musicItems[key] = item;
        }];
        __weak typeof(self) weakSelf =self;
        
        CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
        NSString * taste_profile_name = (NSString *) CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, newUniqueId));
        
        //create temporary taste profile
        [ENAPIRequest POSTWithEndpoint:@"tasteprofile/create" andParameters:@{@"name":taste_profile_name, @"type":@"song"} andCompletionBlock:^(ENAPIRequest * request) {
            
            if (200 == request.httpResponseCode){
                //create update request
                taste_profile_id = [request.response valueForKeyPath:@"response.id"];
                
                NSMutableArray * requestItems = [[NSMutableArray alloc] initWithCapacity:items.count];
                [musicItems enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    MusicLibraryItem * item = (MusicLibraryItem *)obj;
                    [requestItems addObject:@{@"item":@{@"song_name":item.title, @"artist_name":item.artist}}];
                }];
                
                
                NSError *   jsonError;
                NSData * requestData = [NSJSONSerialization dataWithJSONObject:requestItems options:NSJSONWritingPrettyPrinted error:&jsonError];
                //batch update the profile
                [ENAPIRequest POSTWithEndpoint:@"tasteprofile/update" andParameters:@{@"id":taste_profile_id,@"data":requestData}  andCompletionBlock:^(ENAPIRequest * request) {
                    if (request.httpResponseCode == 200) {
                        NSLog(@"\n### ticket ####\n%@",[request.response valueForKeyPath:@"response.ticket"]);
                        NSString * ticket = [request.response valueForKeyPath:@"response.ticket"];
                        [weakSelf waitForBatchEchonestTicket:ticket
                                              tasteProfileId:taste_profile_id
                                                  musicItems:musicItems
                                                        each:processing
                                                     andDone:done];
                    } else {
                        NSString * error = [[NSString alloc] initWithData:request.data encoding:NSUTF8StringEncoding];
                        
                        NSLog(@"call to update taste profile failed..%@",error);
                        [ENAPIRequest POSTWithEndpoint:@"tasteprofile/delete" andParameters:@{@"id":taste_profile_id} andCompletionBlock:^(ENAPIRequest * request) {
                            if (request.httpResponseCode == 200) {
                                NSLog(@"\n\n successfully cleaned up taste profile..but ticket reported erroneous status");
                            }
                        }];
                        done();
                    }
                }];
            }else {
                NSLog(@"Problem creating tasteProfile");
            }
            
        }];
    } else {
        done();  
    }
}

-(void) waitForBatchEchonestTicket:(NSString *)ticket tasteProfileId:(NSString *)tpid musicItems:(NSDictionary *)musicItems each:(void (^)(MusicLibraryItem * item, NSUInteger index))processing andDone:(void (^)(void))done
{
    __weak typeof(self) weakSelf = self;
    NSLog(@"waiting for ticket from echonest\n");
    [ENAPIRequest GETWithEndpoint:@"tasteprofile/status" andParameters:@{@"ticket":ticket} andCompletionBlock:^(ENAPIRequest * request) {
        if (request.httpResponseCode == 200) {
            NSString *ticket_status = [request.response valueForKeyPath:@"response.ticket_status"];
            NSLog(@"ticket status = %@",ticket_status);
            if ([ticket_status isEqualToString:@"pending"]) {
                [NSThread sleepForTimeInterval:0.5];
                [weakSelf waitForBatchEchonestTicket:ticket tasteProfileId:tpid musicItems:musicItems each:processing andDone:done];
            } else if ([ticket_status isEqualToString:@"complete"]) {
                [weakSelf readTasteProfile:tpid each:processing musicItems:musicItems andDone:done];
            } else  {
                [ENAPIRequest POSTWithEndpoint:@"tasteprofile/delete" andParameters:@{@"id":tpid} andCompletionBlock:^(ENAPIRequest * request) {
                    if (request.httpResponseCode == 200) {
                        NSLog(@"\n\n successfully cleaned up taste profile..but ticket reported erroneous status");
                    }
                }];
                done();

            }
            
        } else {
            NSLog(@"error getting ticket status!");
            done();
        }
    }];

    
    
    
    

}
-(void) readTasteProfile:(NSString *)tasteProfile each:(void (^)(MusicLibraryItem * item, NSUInteger index))processing musicItems:(NSDictionary *)musicItems andDone:(void (^)(void))done
{
    __weak typeof(self) weakSelf = self;
    [ENAPIRequest GETWithEndpoint:@"tasteprofile/read" andParameters:@{@"id":tasteProfile, @"bucket":@"audio_summary"} andCompletionBlock:^(ENAPIRequest * request) {
        
        if (request.httpResponseCode == 200){
            NSArray * returnedItems = [request.response valueForKeyPath:@"response.items"];
            [returnedItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSDictionary * returnedItem = (NSDictionary *)obj;
                
                NSString * songKey = [NSString stringWithFormat:@"%@-%@", [returnedItem valueForKeyPath:@"artist_name"], [returnedItem valueForKeyPath:@"song_name"]];
                MusicLibraryItem * item = musicItems[songKey];
                processing(item,idx);
                [weakSelf applyAudioSummary:returnedItem toMusicItem:item];
                [weakSelf saveMusicBPMEntryInCache:item];
            }];
          
            
        }
        [ENAPIRequest POSTWithEndpoint:@"tasteprofile/delete" andParameters:@{@"id":tasteProfile} andCompletionBlock:^(ENAPIRequest * request) {
            if (request.httpResponseCode == 200) {
                NSLog(@"\n\n successfully cleaned up taste profile..");
            }
        }];
        done();
    }];
    

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
    item.currentClassification = classification; 
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
        item.overridden = [entry.overridden boolValue];
        item.overridden_intensity = [entry.overridden_intensity integerValue];
        
        itemUpdated(item);
    } else if ((![entry.notfound boolValue]) || self.override_notfound){
        NSLog(@"ECHONEST - going to echonest for %@ - %@ ", artist, title);
      
        [self lookupBPMFromEchonest:item whenUpdated:itemUpdated];
    }
    


}

-(void) finishProcessing
{
    
    self.processed = YES;
    if (self.shouldPruneICloudItems) {
        [self pruneICloudItems];
    }
    [self pruneOldDRMItems];
    [[NSNotificationCenter defaultCenter ] postNotificationName:@"workoutsongsprocessed" object:self];
}
+(void) saveCacheEntry:(MusicBPMEntry *)entry {
    [[MusicLibraryBPMs currentInstance:nil] saveCacheEntry:entry];
}
-(void) saveCacheEntry:(MusicBPMEntry *)entry {
    NSLog(@"saving managed object for: %@-%@", entry.artist,entry.title);
     NSError * error;
    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
}


-(void) reclassify:(MusicLibraryItem *)item from:(NSInteger) oldIntensity as:(NSInteger)newIntensity userInfo:(NSDictionary *)userInfo  {
    
    NSString * old = [Tempo speedDescription:oldIntensity];
    [self.classifiedItems[old] removeObject:item];
    NSString * newClass = [Tempo speedDescription:newIntensity];
    [self.classifiedItems[newClass] addObject:item];
    item.currentClassification = [Tempo speedDescription:newIntensity];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reclassified_media" object:nil userInfo:@{@"musicItem":item, @"newIntensity":[NSNumber numberWithInteger:newIntensity], @"info":userInfo}];

}

-(void) saveMusicBPMEntryInCache:(MusicLibraryItem *) item
{
    
    
    __weak NSString * artist = [item.mediaItem valueForProperty:MPMediaItemPropertyArtist];
    __weak NSString * title  = [item.mediaItem valueForProperty:MPMediaItemPropertyTitle];
    __weak MusicLibraryItem * weakItem = item;
    NSLog(@"Saving song : %@ by %@", title, artist);
    __block MusicBPMEntry * entry = item.cacheEntry;
    [self.managedObjectContext lock];
    [self.managedObjectContext performBlock:^{
        if (!entry) {
            entry = (MusicBPMEntry *)
            [NSEntityDescription insertNewObjectForEntityForName:@"MusicBPMEntry" inManagedObjectContext:managedObjectContext];
        } else {
            entry = (MusicBPMEntry *) [self.managedObjectContext objectWithID:entry.objectID];
        }
        entry.artist = artist;
        entry.title = title;
        entry.bpm = [[NSNumber alloc ] initWithDouble:weakItem.bpm];
        entry.energy = [[NSNumber alloc] initWithDouble:weakItem.energy];
        entry.notfound = [[NSNumber alloc] initWithBool:weakItem.notfound];
        entry.danceability = [[NSNumber alloc] initWithDouble:weakItem.danceability];
        entry.loudness = [[NSNumber alloc] initWithDouble:weakItem.loudness];
        
        
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

-(void) lookupBPMFromEchonest:(MusicLibraryItem *)item whenUpdated:(ItemUpdatedCallback)itemUpdated  {
    NSLog(@"callingq....");
    while  (self.requestsRemaining == 0) {
        [NSThread sleepForTimeInterval:1.0];
    }
    __block ENAPIRequest * request;
    NSString * theArtist = item.artist;
    theArtist = [theArtist componentsSeparatedByString:@"&"][0];
    theArtist = [theArtist componentsSeparatedByString:@","][0];
    NSRange range = [theArtist rangeOfString:@"-"];
    if (range.location != NSNotFound) {
        NSLog(@"-------------------------- artist with dash : %@",theArtist);
        theArtist = item.albumArtist;
    }

    NSString * theSong = item.title;
    
    theSong = [theSong componentsSeparatedByString:@"("][0];
    theSong = [theSong componentsSeparatedByString:@"-"][0];
    theSong = [theSong componentsSeparatedByString:@"["][0];
    [NSThread sleepForTimeInterval:0.5];
    __weak typeof(self) weakSelf = self;
    if (theArtist && theSong) {
        
        dispatch_async(_requestQueue, ^{
            if (weakSelf.requestsRemaining == 0) {
                [NSThread sleepForTimeInterval:1.0];
            } if (weakSelf.requestsRemaining == 6) {
                [NSThread sleepForTimeInterval:2.0];
            } else {
                [NSThread sleepForTimeInterval:0.25];
            }
            request = [ENAPIRequest GETWithEndpoint:@"song/search"
                                            andParameters:@{@"artist": theArtist,
                                                            @"title" : theSong,
                                                            @"bucket": @"audio_summary",
                                                            @"results": @1}
                             andCompletionBlock:[self.updater(item,itemUpdated) copy]
                      ];
              [weakSelf addRequest:request];
               NSLog(@"url: %@", [request.url absoluteString] );
                        [[NSRunLoop currentRunLoop]run];
        });
        
        } else {
            dispatch_async(_requestQueue, ^{
                if (weakSelf.requestsRemaining == 0) {
                    [NSThread sleepForTimeInterval:1.0];
                } if (weakSelf.requestsRemaining == 6) {
                    [NSThread sleepForTimeInterval:2.0];
                } else {
                    [NSThread sleepForTimeInterval:0.25];
                }
            request = [ENAPIRequest GETWithEndpoint:@"song/search"
                                  andParameters:@{
                                                  @"title" : theSong,
                                                  @"bucket": @"audio_summary",
                                                  @"results": @1}
                             andCompletionBlock:[self.updater(item,itemUpdated) copy]
                       ];
                  [weakSelf addRequest:request];
                    NSLog(@"url: %@", [request.url absoluteString] );
                        [[NSRunLoop currentRunLoop]run];
            });
            
        }
                       
   
  

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
        NSMutableArray * filteredItems = [[NSMutableArray alloc] initWithCapacity:workoutItems.count];
        
        workoutItems = [workOutPlaylist items];
        for (MPMediaItem *potentialSong in workoutItems) {
            if ( ((NSNumber *)[potentialSong valueForProperty:MPMediaItemPropertyMediaType]).integerValue & MPMediaTypeMusic) {
                NSString *songTitle = [potentialSong valueForProperty: MPMediaItemPropertyTitle];
                [filteredItems addObject:potentialSong];
                NSLog (@"%@", songTitle);
            }
        }
        workoutItems = filteredItems;
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
       
       if (item.overridden) {
           return [Tempo speedDescription:item.overridden_intensity];
       }
       
       
       else if (item.energy < 0.3 && item.energy > 0.01) {
            return [Tempo speedDescription:SLOW];
        } else if (item.energy >= 0.3 && item.energy < 0.65) {
            return [Tempo speedDescription:MEDIUM];
        } else if (item.energy >= 0.65 && item.energy < 0.85) {
            return [Tempo speedDescription:FAST];
        } else if (item.energy >= 0.85 && item.energy > 0.85){
            return [Tempo speedDescription:VERYFAST];
        } else {
            return [Tempo speedDescription:UNKNOWN];
        }
    };
}

+(Classifier) livelinessClassifier {
    return ^NSString * (MusicLibraryItem * item) {
        NSLog(@" item.overridden=%d && item.notfound=%d",item.overridden,item.notfound);
        if (item.overridden) {
            return [Tempo speedDescription:item.overridden_intensity];
        } else if (item.notfound) {
            return [Tempo speedDescription:UNKNOWN];
        }else {
            double item_liveliness = liveliness(item.bpm, item.loudness, item.energy, item.danceability);
            NSLog(@"\n item artist = %@ item title = %@ ## enerfy = %.2f  ### loudness = %.2f liveliness = %.2f\n", item.artist, item.title, item.energy, item.loudness, item_liveliness);
            if ( item_liveliness > 0.1 && item_liveliness <= 0.67) {
                return [Tempo speedDescription:SLOW];
            } else if (item_liveliness  >  0.67 && item_liveliness <= 0.80) {
                return [Tempo speedDescription:MEDIUM];
            } else if (item_liveliness > 0.80 && item_liveliness <= 0.99) {
                return [Tempo speedDescription:FAST];
            } else if (item_liveliness > 0.99) {
                return [Tempo speedDescription:VERYFAST];
            }
        }
        return [Tempo speedDescription:UNKNOWN];
    };
}
+(Classifier) energyTimesBPMClassifier {
   
    return ^NSString *(MusicLibraryItem *item) {
        
        if (item.overridden) {
            return [Tempo speedDescription:item.overridden_intensity];
        }
        
        
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
-(Classifier)tempoClassificationForItem:(MusicLibraryItem *)item {
    
    return ^NSString *(MusicLibraryItem * item) {
        
        if (item.overridden) {
            return [Tempo speedDescription:item.overridden_intensity];
        }
        
        
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
    [self processItunesLibrary];

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


BOOL internetConnection()
{
    Reachability * r = [Reachability reachabilityForInternetConnection];
    return ([r currentReachabilityStatus] >  NotReachable);
}

double clamp(double n, double mn, double mx){
    return fmin(mx, fmax(mn,n));
}
double norm(double n, double mn, double mx){
    return (n-mn)/(mx-mn);
}
double nclamp(double n, double mn, double mx){
    return norm(clamp(n,mn,mx),mn,mx);
}

double liveliness(double tempo, double loudness, double energy, double danceability)
{
    NSLog(@"log of silence: %.2f, log of 5: %.2f,  loudness : %.2f",log(60), log(0), loudness);
    NSLog(@"bpm = %.2f, energy=%.2f, dance = %.2f, bpm fraction: %.2f", tempo, energy, danceability, nclamp(tempo,MIN_TEMPO, MAX_TEMPO) );
    
    double result =  MAX(energy,danceability);
    
    if (tempo < 80) {
        result *= 0.9;
    } else if (tempo >= 125) {
        result *=1.15;
    } else if (tempo > 130 ) {
        result *=1.25;
    }
    
    if (loudness > -5) {
        result *=1.2;
    }
    return result;
}
@end

@implementation MusicLibraryItem /* TODO: merge with SongJockey stuff - redundant. */
-(id) initWithMediaItem:(MPMediaItem *)theMediaItem
{
    self.mediaItem = theMediaItem;
    return self;
}
-(void) applyMusicBPMEntry:(MusicBPMEntry *)entry;
{
    double energy = [entry.energy doubleValue];
    if (entry) {
        if (![entry.notfound boolValue] || [entry.overridden boolValue]) {
            self.danceability =  [entry.danceability doubleValue];
            self.bpm = [entry.bpm doubleValue];
            self.energy = energy;
            self.overridden = [entry.overridden boolValue];
            self.loudness = [entry.loudness doubleValue];
            if (self.overridden) {
                NSLog(@"found overridden song..");
            }
            self.overridden_intensity = [entry.overridden_intensity integerValue];
            self.notfound = [entry.notfound boolValue];
        }else {
            self.notfound = [entry.notfound boolValue];
        }
     }
}

-(MusicBPMEntry *) findCacheEntry {
    
    if ( self.cacheEntry) {
        return self.cacheEntry;
    }
    MusicLibraryBPMs * library = [MusicLibraryBPMs currentInstance:nil];
    MusicBPMEntry * entry = [library findBPMEntryInCacheFor:self.artist andTitle:self.title];
    return entry;
}


-(void)overrideIntensityTo:(NSInteger)intensityNum userInfo:(NSDictionary *)info
{
    MusicLibraryBPMs * library = [MusicLibraryBPMs currentInstance:nil];
    MusicBPMEntry * cacheEntry = [self findCacheEntry];
    NSUInteger oldIntensity;
    if (self.overridden) {
        oldIntensity = self.overridden_intensity;
    } else {
        oldIntensity = [Tempo toIntensityNum:library.musicClassifier(self)];
    }
    cacheEntry.overridden = [NSNumber numberWithBool:YES];
    cacheEntry.overridden_intensity = [NSNumber numberWithInteger:intensityNum];
    self.overridden = YES;
    self.overridden_intensity = intensityNum;
    [library saveCacheEntry:cacheEntry];
    [library reclassify:self from:oldIntensity as:intensityNum userInfo:info];
    library.numberOfOverriddenItems++;
}
-(void) clearOverride:(NSDictionary *)info {
    if (self.overridden) {
        MusicLibraryBPMs * library = [MusicLibraryBPMs currentInstance:nil];
        MusicBPMEntry * cacheEntry = [self findCacheEntry];
        NSUInteger oldIntensity = self.overridden_intensity;
        self.overridden = NO;
        cacheEntry.overridden = [NSNumber numberWithBool:NO];
        cacheEntry.overridden_intensity = 0;
        NSString * newClass = library.musicClassifier(self);
        NSUInteger intensityNum = [Tempo toIntensityNum:newClass];
        [library saveCacheEntry:cacheEntry];
        [library reclassify:self from:oldIntensity as:intensityNum userInfo:info];
        library.numberOfOverriddenItems--;
    }
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
-(NSString *) albumArtist
{
    return [self.mediaItem valueForKey:MPMediaItemPropertyAlbumArtist];
}


@end


