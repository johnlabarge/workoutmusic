//
//  workoutmusicViewController.m
//  WorkoutMusic
//
//  Created by La Barge, John on 3/23/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import "PlayerViewController.h"
#import "SongTableCell.h"
#import "TimeUtils.h"

@interface PlayerViewController()

@end

@implementation PlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.intervalLabel.text = @"";
    [self.workoutlist addObserver:self forKeyPath:@"workoutSongs" options:NSKeyValueObservingOptionNew context:nil];
     [self.workoutlist addObserver:self forKeyPath:@"actualWorkoutTime" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"remainingPlaybacktime" options:NSKeyValueObservingOptionNew context:nil];
    self.workoutTimeRemaining.text = [TimeUtils minutesColonSeconds:self.workoutlist.actualWorkoutTime.intValue];
    
	// Do any additional setup after loading the view.
}
-(void)viewWillDisappear:(BOOL)animated
{
    [self.musicPlayerController stop];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [self.musicPlayerController stop];
}

-(void) observeValueForKeyPath:(NSString *)path ofObject:(NSObject *)anObject change: (NSDictionary *) theChange context:(void *)ctx {

    if ([path isEqualToString:@"workoutSongs"]) {
        [self.tableView reloadData];
    } else if([path isEqualToString:@"actualWorkoutTime"]) {
        self.remainingPlaybacktime = [NSNumber numberWithInt:self.workoutlist.actualWorkoutTime.intValue];
        self.workoutTimeRemaining.text = [TimeUtils minutesColonSeconds:self.remainingPlaybacktime.intValue];
        
    } else if ([path isEqualToString:@"remainingPlaybacktime"]) {
        self.workoutTimeRemaining.text = [TimeUtils minutesColonSeconds:self.remainingPlaybacktime.intValue];
    }
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        NSArray * items = self.workoutlist.workoutSongs;
        return [items count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    SongTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SongTableCell" owner:self options:nil];
        cell = (SongTableCell *)[nib objectAtIndex:0];

    }
    
    MusicLibraryItem * mlItem = [self.workoutlist.workoutSongs objectAtIndex:[indexPath indexAtPosition:1]];
    MPMediaItem * song = mlItem.mediaItem;
    
    NSString * titleText = [song valueForProperty:MPMediaItemPropertyTitle];
    if (titleText.length > 20) {
        titleText = [titleText substringToIndex:20];
        titleText = [NSString stringWithFormat:@"%@...",titleText];
    }
    
    cell.title.text = titleText;
    cell.tempoClass.text = mlItem.tempoClassificaiton;
    cell.time.text =  [TimeUtils minutesColonSeconds:[[mlItem.mediaItem valueForProperty:MPMediaItemPropertyPlaybackDuration] intValue]];
    
    // Configure the cell...
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

-(void) playbackSongChanged:(NSNotification *) notification
{
        NSLog(@"now playing item changed!!!");
    if (self.musicPlayerController.indexOfNowPlayingItem < self.playQueueArray.count && self.musicPlayerController.indexOfNowPlayingItem > 0) {
 
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:self.musicPlayerController.indexOfNowPlayingItem inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self recalculatePlaybackTime];


    [self updateIntervalText];
    }
}
-(void) playbackStateChanged:(NSNotification *)notification
{
    NSLog(@"playback state changed--------");
    if (self.musicPlayerController.playbackState == MPMusicPlaybackStatePlaying) {

        [self recalculatePlaybackTime]; 
             self.workoutTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                       target:self
                                                     selector:@selector(onTimer)
                                                     userInfo:nil
                                                      repeats:YES];
        [self updateIntervalText];
        
        
    } else {
        [self.workoutTimer invalidate];
        self.intervalLabel.text = @"";
        
    }
        
        
}
-(void) updateIntervalText
{
    MusicLibraryItem * currentMLitem = (MusicLibraryItem *) [self.workoutlist.workoutSongs objectAtIndex:self.musicPlayerController.indexOfNowPlayingItem];
                                                             ;
    self.intervalLabel.text = [NSString stringWithFormat:@"Interval %d: %@",currentMLitem.intervalIndex+1, currentMLitem.intervalDescription];
}
-(void) recalculatePlaybackTime
{
    
    NSUInteger secondsUpToCurrent =  [self calculateSecondsUpToCurrent];
    NSUInteger actualWorkoutTime = self.workoutlist.actualWorkoutTime.intValue;
    NSUInteger currentPlaybacktime = self.musicPlayerController.currentPlaybackTime;
    
    self.remainingPlaybacktime = [NSNumber numberWithInt:(actualWorkoutTime - secondsUpToCurrent - currentPlaybacktime)];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}
-(IBAction)playMusic
{
    self.musicPlayerController = [MPMusicPlayerController applicationMusicPlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackSongChanged:)
                                                 name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackStateChanged:)
                                                 name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
                                                object:nil];
     
    [self.musicPlayerController setShuffleMode:MPMusicShuffleModeOff];
    [self.musicPlayerController beginGeneratingPlaybackNotifications];
   // [self.musicPlayerController addObserver:self forKeyPath:@"nowPlayingItem" options:NSKeyValueObservingOptionNew context:nil];
    
    NSMutableArray * playQueueArray = [[NSMutableArray alloc] initWithCapacity:self.workoutlist.workoutSongs.count ];
    self.playQueueArray = playQueueArray; 
    for (MusicLibraryItem * item in self.workoutlist.workoutSongs) {
        NSLog(@"queuing songs....\n\n");
        NSLog(@"%@", [item.mediaItem valueForProperty:MPMediaItemPropertyTitle]);
        [playQueueArray addObject:item.mediaItem];
    }
    NSLog(@"done queuing songs...");
    
    MPMediaItemCollection * playQueue = [MPMediaItemCollection collectionWithItems:playQueueArray];
    [self.musicPlayerController setQueueWithItemCollection:playQueue];
    [self.musicPlayerController play];
    
}

-(NSInteger) indexForMediaItem : (MPMediaItem *) item
{
    NSInteger ret = 0;
    for (int i = 0; i < self.playQueueArray.count; i++ ) {
        if ([item isEqual:[self.playQueueArray objectAtIndex:i]]) {
            ret = i;
            break;
        }
    }
    return ret;
}

-(void) onTimer
{
    [self recalculatePlaybackTime];
}

-(IBAction)pauseMusic
{
    [self.musicPlayerController pause];
}

-(IBAction)prev
{
    [self.musicPlayerController skipToPreviousItem];
}
-(IBAction)next
{
    NSLog(@"going to next item....");
    [self.workoutTimer invalidate];
    
    [self.musicPlayerController skipToNextItem];
   
    NSLog(@" next item is : %@", [[self.musicPlayerController nowPlayingItem] valueForProperty:MPMediaItemPropertyTitle]);
}

-(NSUInteger) calculateSecondsUpToCurrent
{
    NSUInteger currentItemIndex = self.musicPlayerController.indexOfNowPlayingItem;
   
    __block NSUInteger totalSeconds = 0;
    [self.playQueueArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if (idx < currentItemIndex) {
            MPMediaItem *item = (MPMediaItem *) obj;
            totalSeconds += [[item valueForProperty:MPMediaItemPropertyPlaybackDuration] intValue];
        } else {
            *stop = YES;
        }
        
    }];
    return totalSeconds;
}




-(void)dealloc
{
    
    [self.workoutlist removeObserver:self forKeyPath:@"workoutSongs"];
    [self.workoutlist removeObserver:self forKeyPath:@"actualWorkoutTime"];
    [self removeObserver:self forKeyPath:@"remainingPlaybacktime"];
}

@end
