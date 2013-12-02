//
//  MusicLibraryBPMs.m
//  WorkoutMusicSlow//
//  Created by John La Barge on 11/15/12.
//  Copyright (c) 2012 John La Barge. All rights reserved.
//

#import "MusicLibraryBPMs.h"
#import "WorkoutMusicSettings.h"


@interface MusicLibraryBPMs()
-(void) lookupBPMFor:(MusicLibraryItem *)item whenUpdated: ( void (^)(MusicLibraryItem *) ) itemUpdated;
-(MusicBPMEntry *) findBPMEntryInCacheFor:(NSString *)artist andTitle:(NSString *)title;
-(void) saveMusicBPMEntryInCache:(MusicLibraryItem *) item;
@property (nonatomic, assign) BOOL processed;
@property (nonatomic, strong) NSArray * filters;
@end
@implementation MusicLibraryBPMs
@synthesize libraryItems;
@synthesize unfilteredItems;
@synthesize managedObjectContext;

-(id) initWithManagedObjectContext:(NSManagedObjectContext *)moc
{
    

    
    
    self.filters = @[ @[@60, @95],  //SLOW
                      @[@96, @125], //MEDIUM
                      @[@126,@159], //FAST
                      @[@160, @500] ]; //VERYFAST
       
 
    
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
    
        __block ENAPIRequest *req = request;
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
                double tempo = [[song valueForKeyPath:@"audio_summary.tempo"] doubleValue];
                musicLibraryItem.bpm = tempo;
                musicLibraryItem.tempoClassificaiton  = [self tempoClassificationForItem:musicLibraryItem];
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
 
    
    NSLog(@"found %d workoutItems",workoutItems.count);
    return workoutItems;
    
}
#pragma mark filtering
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
        NSLog(@"/** filtering items : \n\n %@ - %d", [theItem.mediaItem valueForProperty:MPMediaItemPropertyTitle], (int) theItem.bpm );
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

-(void) applyFilter:(NSInteger)speed
{
    NSArray * range = [self.filters objectAtIndex:speed];
    [self filterWithMin:[[range objectAtIndex:0] intValue] andMax:[[range objectAtIndex:1] intValue]];
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

#pragma mark create workout lists




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
    another.bpm = self.bpm;
    return another;
}
-(NSInteger) durationInSeconds
{
    NSNumber * songSecondsN = [self.mediaItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
    return  songSecondsN.intValue;
}
@end


