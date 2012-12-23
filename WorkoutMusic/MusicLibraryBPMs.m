//
//  MusicLibraryBPMs.m
//  WorkoutMusic
//
//  Created by John La Barge on 11/15/12.
//  Copyright (c) 2012 John La Barge. All rights reserved.
//

#import "MusicLibraryBPMs.h"

@interface MusicLibraryBPMs()
-(void) lookupBPMFor:(MusicLibraryItem *)item whenUpdated:(void(^)(void))itemUpdated;
-(MusicBPMEntry *) findBPMEntryInCacheFor:(NSString *)artist andTitle:(NSString *)title;
-(void) saveMusicBPMEntryInCache:(NSString *)artist andTitle:(NSString *)title;
@end
@implementation MusicLibraryBPMs
@synthesize libraryItems;
@synthesize unfilteredItems;
@synthesize managedObjectContext;

-(id) initWithManagedObjectContext:(NSManagedObjectContext *)moc
{
    
    [ENAPI initWithApiKey:@"4N3RGRQDQPUETU3BV"];
    NSArray * mpItems = [MusicLibraryBPMs getMusicItems];
    
    self.libraryItems = [[NSMutableArray alloc] initWithCapacity:mpItems.count];
    
    NSMutableArray * mutLibraryItems = (NSMutableArray *) self.libraryItems;
    for (MPMediaItem * item in mpItems)
    {
        
        [mutLibraryItems addObject:[[MusicLibraryItem alloc] initWithMediaItem:item]];
    }
    self.unfilteredItems = libraryItems;
    self.managedObjectContext = moc;
    return self;
}


-(void) filterWithMin:(NSInteger)min andMax:(NSInteger)max
{
    NSLog(@"filtering with min:%d and max:%d", min, max);
    
    self.libraryItems = [self doFilter:self.unfilteredItems withMin:min andMax:max];
}

-(NSArray *) doFilter:(NSArray *)list withMin:(NSInteger)min andMax:(NSInteger)max
{
    
    NSMutableArray * theFilteredItems = [[NSMutableArray alloc] initWithCapacity:[list count]];
    
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

-(void) processItunesLibrary:( void (^)(void) ) itemUpdated
{
    NSLog(@"processing itunes library....%d items",self.libraryItems.count);
    for (MusicLibraryItem * mi in self.libraryItems) {
        if (mi.bpm == 0) {
            [self lookupBPMFor:mi whenUpdated:itemUpdated];
        }
    }
}


-(void) lookupBPMFor:(MusicLibraryItem *)item whenUpdated: ( void ( ^ ) (void ) ) itemUpdated {
    
    NSString * artist = [item.mediaItem valueForProperty:MPMediaItemPropertyArtist];
    NSString * title  = [item.mediaItem valueForProperty:MPMediaItemPropertyTitle];
    
    MusicBPMEntry * entry =  [self findBPMEntryInCacheFor:artist andTitle:title];
    if (entry != nil) {
        item.bpm = [entry.bpm doubleValue];
        itemUpdated();
    } else {
    
        [self lookupBPMFromEchonest:item whenUpdated:itemUpdated artist:artist song:title];
    
    }

 
    

}


-(void) saveMusicBPMEntryInCache:(NSString *)artist andTitle:(NSString *)title andBPM:(double)bpm
{
    MusicBPMEntry *entry = (MusicBPMEntry *)[NSEntityDescription insertNewObjectForEntityForName:@"MusicBPMEntry" inManagedObjectContext:managedObjectContext];
    entry.bpm = [[NSNumber alloc ] initWithDouble:bpm];
}

-(MusicBPMEntry *) findBPMEntryInCacheFor:(NSString *)artist andTitle:(NSString *)title
{
    MusicBPMEntry * entry = nil;
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"MusicBPMEntry" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"(artist LIKE[c] '%@') AND (title LIKE[c] '%@')", artist, title];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"artist" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
   
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
-(void) lookupBPMFromEchonest:(MusicLibraryItem *)item whenUpdated:( void(^) (void) )itemUpdated artist:(NSString *)theArtist song:(NSString *)theSong {

    ENAPIRequest *request = [ENAPIRequest requestWithEndpoint:@"song/search"];
    
    request.delegate = self;                              // our class implements ENAPIRequestDelegate
    [request setValue:theArtist forParameter:@"artist"];
    [request setValue:theSong forParameter:@"title"];
    [request setValue:@"audio_summary" forParameter:@"bucket"];
    [request setIntegerValue:1 forParameter:@"results"];
    
    NSMutableDictionary * info = [[NSMutableDictionary alloc] init];
    [info setObject:[itemUpdated copy] forKey:@"itemUpdated"];
    void (^itemUpdated2)(void) = [info objectForKey:@"itemUpdated"];
    
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
        MusicLibraryItem * musicLibraryItem = [request.userInfo objectForKey:@"libraryItem"];
        //TODO: fish out the tempo from the data returned
         //   NSLog(@"%@",[request.requestURL absoluteString]);
        NSArray * songs = [request.response valueForKeyPath:@"response.songs"];
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
            
            NSLog(@"int value of tempo = %d",[[request.response valueForKeyPath:@"audio_summary.tempo"] intValue]);
            
            void (^itemUpdated)(void)  = (void(^)(void))[request.userInfo objectForKey:@"itemUpdated"];
            itemUpdated();
    
        }
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

@end

@implementation MusicLibraryItem
@synthesize mediaItem;
@synthesize bpm;
-(id) initWithMediaItem:(MPMediaItem *)theMediaItem
{
    self.mediaItem = theMediaItem;
    return self;
}

@end


