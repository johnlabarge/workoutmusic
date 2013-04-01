//
//  MusicLibraryBPMs.m
//  WorkoutMusic
//
//  Created by John La Barge on 11/15/12.
//  Copyright (c) 2012 John La Barge. All rights reserved.
//

#import "MusicLibraryBPMs.h"

#define SLOW @"slow"
#define MEDIUM @"medium"
#define MEDIUMFAST @"mediumFast"
#define FAST @"fast"
#define SLOPSECONDS 60

@interface MusicLibraryBPMs()
-(void) lookupBPMFor:(MusicLibraryItem *)item whenUpdated: ( void (^)(MusicLibraryItem *) ) itemUpdated;
-(MusicBPMEntry *) findBPMEntryInCacheFor:(NSString *)artist andTitle:(NSString *)title;
-(void) saveMusicBPMEntryInCache:(MusicLibraryItem *) item;
@property (nonatomic, strong) NSDictionary *  TempoSelectors;
@property (nonatomic, assign) BOOL processed;
@end
@implementation MusicLibraryBPMs
@synthesize libraryItems;
@synthesize unfilteredItems;
@synthesize managedObjectContext;

-(id) initWithManagedObjectContext:(NSManagedObjectContext *)moc
{
    
    self.TempoSelectors = @{
                              SLOW:NSStringFromSelector(@selector(slowFilter)),
                              MEDIUM:NSStringFromSelector(@selector(mediumFilter)),
                              MEDIUMFAST:NSStringFromSelector(@selector(medFastFilter)),
                              FAST: NSStringFromSelector(@selector(fastFilter))
    };
    
    
    
    
    [ENAPI initWithApiKey:@"4N3RGRQDQPUETU3BV"];
    NSArray * mpItems = [MusicLibraryBPMs getMusicItems];
    
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
    self.unfilteredItems = libraryItems;
    self.managedObjectContext = moc;
    self.processed = NO;
    return self;
}

-(SEL) filterSelectorForName:(NSString *)name {
    return NSSelectorFromString([self.TempoSelectors objectForKey:name]);
}



-(void) processItunesLibrary:(void (^)(MusicLibraryItem * item))beforeUpdatingItem  afterUpdatingItem:( void (^)(MusicLibraryItem * item) ) itemUpdated
{
    NSLog(@"processing itunes library....%d items",self.libraryItems.count);
    __block MusicLibraryBPMs * me = self;
    __block int count = 0;
    for (MusicLibraryItem * mi in self.libraryItems) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            me.currentIndexBeingProcessed = count;
            me.itemBeingProcessed = mi;
        });
        beforeUpdatingItem(mi);
        if (mi.bpm == 0) {
            [self lookupBPMFor:mi whenUpdated:itemUpdated];
        }
        count++;
    }
    self.processed = YES;
}


-(void) lookupBPMFor:(MusicLibraryItem *)item whenUpdated: ( void (^)(MusicLibraryItem *) ) itemUpdated {
    
    
    NSString * artist = [item.mediaItem valueForProperty:MPMediaItemPropertyArtist];
    NSString * title  = [item.mediaItem valueForProperty:MPMediaItemPropertyTitle];
    
    MusicBPMEntry * entry =  [self findBPMEntryInCacheFor:artist andTitle:title];
    if (entry != nil) {
        item.bpm = [entry.bpm doubleValue];
        item.tempoClassificaiton  = [self tempoClassificationForItem:item];
        itemUpdated(item);
    } else {
    
        [self lookupBPMFromEchonest:item whenUpdated:itemUpdated artist:artist song:title];
    }
}



-(void) saveMusicBPMEntryInCache:(MusicLibraryItem *) item
{
    
    NSString * artist = [item.mediaItem valueForProperty:MPMediaItemPropertyArtist];
    NSString * title  = [item.mediaItem valueForProperty:MPMediaItemPropertyTitle];
    
    NSLog(@"Saving song : %@ by %@", title, artist); 
    
    MusicBPMEntry *entry = (MusicBPMEntry *)[NSEntityDescription insertNewObjectForEntityForName:@"MusicBPMEntry" inManagedObjectContext:managedObjectContext];
    entry.artist = artist;
    entry.title = title;
    entry.bpm = [[NSNumber alloc ] initWithDouble:item.bpm];
    NSError *error = nil;
    
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
        NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
        if(detailedErrors != nil && [detailedErrors count] > 0) {
            for(NSError* detailedError in detailedErrors) {
              NSLog(@"  DetailedError: %@", [detailedError userInfo]);
            }
        }
        else {
          NSLog(@"  %@", [error userInfo]);
        }
    }

    NSLog(@"total managed Objects: %d", self.managedObjectContext.registeredObjects.count);
    if (error != nil) {
        NSLog(@"error: %@", error.localizedDescription); 
    }

    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"MusicBPMEntry"];
    NSArray * entityObjs = [self.managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"total entities in store : %d",entityObjs.count);
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
    
    NSString * predicateS = [NSString stringWithFormat:@"(artist like '%@') AND (title like '%@')", artist, title];
    NSLog(@"predicate = %@",predicateS);
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(artist like %@) AND (title like %@)",artist, title];
    
    [request setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"artist" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    NSLog(@"***** found %d entries matching %@ and %@", array.count, artist, title);
   
    if (array == nil)
    {
        NSLog(@" nil array from coredata request, error:", error.localizedDescription);
    }
    
    if (array.count > 0) {
        NSLog(@"Found %d matching musicBPM entries",array.count);
        return  entry = (MusicBPMEntry *) [array objectAtIndex:0]; 
    }

   
    return entry;
}
-(void) lookupBPMFromEchonest:(MusicLibraryItem *)item whenUpdated:( void(^) (MusicLibraryItem *) )itemUpdated artist:(NSString *)theArtist song:(NSString *)theSong {

    ENAPIRequest *request = [ENAPIRequest requestWithEndpoint:@"song/search"];
    
    request.delegate = self;                              // our class implements ENAPIRequestDelegate
    [request setValue:theArtist forParameter:@"artist"];
    [request setValue:theSong forParameter:@"title"];
    [request setValue:@"audio_summary" forParameter:@"bucket"];
    [request setIntegerValue:1 forParameter:@"results"];
    
    NSMutableDictionary * info = [[NSMutableDictionary alloc] init];
    [info setObject:[itemUpdated copy] forKey:@"itemUpdated"];
    void (^itemUpdated2)(MusicLibraryItem *) = [info objectForKey:@"itemUpdated"];
    
    [info setObject:item forKey:@"libraryItem"];
    
    
    request.userInfo = info;
    [NSThread sleepForTimeInterval:0.5];
    [request startSynchronous];
}

- (void)requestFinished:(ENAPIRequest *)request
{
    NSDictionary * userInfo = request.userInfo;
    NSLog(@"%@",request.responseString);

  
    
    if (200 == request.responseStatusCode)
    {
    
        __block ENAPIRequest *req;
        __block MusicLibraryBPMs * me = self;
        dispatch_async( dispatch_queue_create("item saver", NULL), ^{
            
        
        MusicLibraryItem * musicLibraryItem = [req.userInfo objectForKey:@"libraryItem"];
        //TODO: fish out the tempo from the data returned
         //   NSLog(@"%@",[request.requestURL absoluteString]);
        NSArray * songs = [req.response valueForKeyPath:@"response.songs"];
        if (songs.count > 0) {
            
        
            NSDictionary * song = [songs objectAtIndex:0];
            
            NSDictionary * audio_summary = [song objectForKey:@"audio_summary"];
            NSArray * allKeys = [audio_summary allKeys];
            for (NSString * key in allKeys) {
                NSLog(@"Key: %@",key);
            }
            NSNumber *theTempo = [audio_summary objectForKey:@"tempo"];
            double tempo = [[song valueForKeyPath:@"audio_summary.tempo"] doubleValue];
            musicLibraryItem.bpm = tempo;
            NSLog(@"double vluae of tempo = %f",musicLibraryItem.bpm);
            
            NSLog(@"int value of tempo = %d",[[req.response valueForKeyPath:@"audio_summary.tempo"] intValue]);
            
            
            
            [me saveMusicBPMEntryInCache:musicLibraryItem];
            
            
            void (^itemUpdated)(MusicLibraryItem *)  = (void(^)(MusicLibraryItem *))[req.userInfo objectForKey:@"itemUpdated"];
            
            itemUpdated(musicLibraryItem);
    
        }
                 });
    } else {
        NSLog(@"%d", request.responseStatusCode);
    }
                  
}
- (void)requestFailed:(ENAPIRequest *)request
{
    NSLog(@"Request to echonest api failed!");
}

+(NSArray *) getMusicItems
{
    NSLog(@"Getting music items now...");
    MPMediaQuery *playlistQuery = [MPMediaQuery playlistsQuery];
    NSArray * playlists = [playlistQuery collections];
    NSLog(@"Playlist count:%d",playlists.count);
    MPMediaItemCollection *workOutPlaylist;
    for (MPMediaItemCollection * playlist in playlists) {
        NSLog(@"found play list: %@",[playlist valueForProperty:MPMediaPlaylistPropertyName]);
        if ([[playlist valueForProperty:MPMediaPlaylistPropertyName] isEqualToString:@"workoutsongs"]) {
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
 
    
    NSLog(@"found %d workoutItems",workoutItems.count);
    return workoutItems;
    
}
#pragma mark ps
-(void) filterWithMin:(NSInteger)min andMax:(NSInteger)max
{
    NSLog(@"filtering with min:%d and max:%d", min, max);
    
    self.libraryItems = [self doFilter:self.unfilteredItems withMin:min andMax:max];
}

-(NSString *) tempoClassificationForItem:(MusicLibraryItem *)item {
    
    if (item.bpm >=60 && item.bpm <=95) {
        return @"Slow";
    } else if (item.bpm >=96 && item.bpm <=125) {
        return @"Medium";
    } else if (item.bpm >= 125 && item.bpm <=159) {
        return @"Medium Fast";
    } else if (item.bpm >= 160 && item.bpm <= 400) {
        return @"Fast";
    }
}
-(void) slowFilter
{
    [self filterWithMin:60 andMax:95];

}

-(void) mediumFilter
{
    [self filterWithMin:96 andMax:125];
}

-(void) medFastFilter
{
    [self filterWithMin:125 andMax:159];
}

-(void) fastFilter
{
     [self filterWithMin:160 andMax:400];
}

-(NSArray *) doFilter:(NSArray *)list withMin:(NSInteger)min andMax:(NSInteger)max
{
    NSMutableArray * theFilteredItems = [[NSMutableArray alloc] initWithCapacity:[list count]];
    if (!self.processed) {
        [self processItunesLibrary:^(MusicLibraryItem *item) {
            NSLog(@"processing : %@", [item.mediaItem valueForProperty:MPMediaItemPropertyTitle]);
        } afterUpdatingItem:^(MusicLibraryItem *item) {
            NSLog(@"processing : %@", [item.mediaItem valueForProperty:MPMediaItemPropertyTitle]);
        }];
    }
    for (id theObj in list) {
        MusicLibraryItem * theItem = (MusicLibraryItem *) theObj;
        if (theItem.bpm >= min && theItem.bpm <= max ) {
            [theFilteredItems addObject:theItem];
        }
    }
    return theFilteredItems;
}
-(void) unfilter
{
    self.libraryItems = self.unfilteredItems;
}



#pragma mark create workout lists

#define APPROX_TIME @"approxTime"
#define TEMPO @"tempo"
#define DESC @"description"

-(NSArray *) processIntervals:(NSArray *)intervals
{
    NSMutableArray *retList = [[NSMutableArray alloc] init];
    NSLog(@"processing %d intervals", retList.count);
    NSInteger intervalNumber = 0;
    for (NSDictionary * interval in intervals) {
        [retList addObjectsFromArray:[self songsForInterval:interval number:intervalNumber]];
        intervalNumber++;
    }
    NSLog(@"######WORKOUT LIST:######\n");
    [retList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MusicLibraryItem * item = (MusicLibraryItem *) obj;
        NSString * title = [item.mediaItem valueForProperty:MPMediaItemPropertyTitle];
        NSLog(@"%@", title);
        
    }];
    return retList;
}

- (NSArray *) createPyramid:(NSInteger)approxTime {
    
    NSNumber  * sliceNumber = [NSNumber numberWithInt:approxTime/6];
    NSNumber  * peakNumber  = [NSNumber numberWithInt:approxTime/3];
    NSNumber  * warmDownNumber = [NSNumber numberWithInt:5];
   
    
    NSArray * intervals = @[
    @{DESC: @"Start Ascending", APPROX_TIME : sliceNumber,  TEMPO:@"medium"},
    @{DESC: @"Ascecnd", APPROX_TIME : sliceNumber,  TEMPO:@"mediumFast"},
    @{DESC: @"Peak", APPROX_TIME : peakNumber,   TEMPO:@"fast"},
    @{DESC: @"Descend", APPROX_TIME : sliceNumber,  TEMPO: @"mediumFast"},
    @{DESC: @"Back to Bottom", APPROX_TIME : sliceNumber,  TEMPO: @"medium"},
    @{DESC: @"Cool down", APPROX_TIME:warmDownNumber, TEMPO: @"slow"}

    ];
    
    return [self processIntervals:intervals]; 

}

-(NSArray *) createFastToSlow:(NSInteger)approxTime {

    NSNumber *warmupSeconds = [NSNumber numberWithInt:300];
    NSNumber *intervalSeconds = [NSNumber numberWithInt:approxTime/4];
    
    NSArray * intervals = @[
    @{DESC:@"Warmup", APPROX_TIME: warmupSeconds, TEMPO:MEDIUM},
    @{DESC:@"Fast", APPROX_TIME:intervalSeconds, TEMPO:FAST},
    @{DESC:@"Medium Fast", APPROX_TIME:intervalSeconds, TEMPO:MEDIUMFAST},
    @{DESC:@"Medium", APPROX_TIME:intervalSeconds, TEMPO:MEDIUM},
    @{DESC:@"Slow",   APPROX_TIME:intervalSeconds, TEMPO:SLOW}
    ];
    
    return [self processIntervals:intervals]; 

}

-(NSArray *) createSlowToFast:(NSInteger)approxTime {
    NSNumber *intervalSeconds = [NSNumber numberWithInt:approxTime/4];
    NSNumber *warmDownSeconds = [NSNumber numberWithInt:300];
    
    NSArray * intervals = @[
    
    @{DESC:@"Slow", APPROX_TIME:intervalSeconds, TEMPO:SLOW},
    @{DESC:@"Medium", APPROX_TIME:intervalSeconds, TEMPO:MEDIUM},
    @{DESC:@"Faster", APPROX_TIME:intervalSeconds, TEMPO:MEDIUMFAST},
    @{DESC:@"Fast",   APPROX_TIME:intervalSeconds, TEMPO:FAST},
    @{DESC:@"Cool down", APPROX_TIME: warmDownSeconds, TEMPO:SLOW}
    ];
    return [self processIntervals:intervals];
}

-(NSArray *) songsForInterval:(NSDictionary *)interval number:(NSInteger)intervalNumber
{
    NSMutableArray * retList = [[NSMutableArray alloc] initWithCapacity:3];
    SEL theSelector = [self filterSelectorForName:[interval objectForKey:TEMPO]];
    [self performSelector:theSelector withObject:nil];
    NSNumber * intervalSecondsN = [interval objectForKey:APPROX_TIME];
    
    NSInteger intervalSeconds = intervalSecondsN.intValue;
    NSInteger remainingSeconds = intervalSeconds;
    NSArray * shuffledItems = [self.libraryItems shuffle];
    for (MusicLibraryItem * item  in shuffledItems) {
        NSNumber * songSecondsN = [item.mediaItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
        NSInteger songSeconds = songSecondsN.intValue;
       
        if (songSeconds <= intervalSeconds+SLOPSECONDS) {
            MusicLibraryItem * itemToAdd = [item copy];
            itemToAdd.intervalDescription  = [interval objectForKey:DESC];
            itemToAdd.intervalIndex = intervalNumber;
            
            [retList addObject:itemToAdd];
            remainingSeconds -= songSeconds;
        }
        if (remainingSeconds <= 0) {
            break;
        }
        
    }
    [self unfilter];
    /*[retList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MusicLibraryItem *item = (MusicLibraryItem *) obj;
        NSString * title = [item.mediaItem valueForProperty:MPMediaItemPropertyTitle];
        NSLog(@"music library item:%@", title);
    }];*/
    return retList; 
}
@end

@implementation MusicLibraryItem
-(id) initWithMediaItem:(MPMediaItem *)theMediaItem
{
    self.mediaItem = theMediaItem;
    return self;
}

-(id) copyWithZone:(NSZone *)zone
{
    MusicLibraryItem *another = [[MusicLibraryItem alloc] initWithMediaItem:[self.mediaItem copy]];
    another.tempoClassificaiton = [self.tempoClassificaiton copyWithZone:zone];
    another.intervalDescription = [self.intervalDescription copyWithZone:zone];
    another.intervalIndex = self.intervalIndex;
    return another;
}

@end


