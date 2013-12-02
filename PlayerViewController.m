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
@property (nonatomic, assign) CGRect retractedSongsFrame;
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
    self.retractSongsImage    =  [UIImage imageNamed:@"retractSongs.png"];
    self.expandSongsImage = [UIImage imageNamed:@"expandSongs.png"];
    self.retractedSongsFrame = self.songsView.frame;

    [self setupAppMusicPlayer];
    self.intervalLabel.text = @"";
    [self.workoutlist addObserver:self forKeyPath:@"workoutSongs" options:NSKeyValueObservingOptionNew context:nil];
     [self.workoutlist addObserver:self forKeyPath:@"actualWorkoutTime" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"remainingPlaybacktime" options:NSKeyValueObservingOptionNew context:nil];
    self.workoutTimeRemaining.text = [TimeUtils minutesColonSeconds:self.workoutlist.actualWorkoutTime.intValue];
    
    self.workoutGraph.currentInterval = 0;
    self.workoutGraph.intervals = self.workoutlist.intervals;
    [self.view addSubview:self.tableView];
    /*[self showSongsExpanded];
    [self showSongsRetracted]; */
   // self.buttonBar.frame = CGRectMake(self.buttonBar.frame.origin.x, self.buttonBar.frame.origin.y, self.buttonBar.frame.size.width, 80);

    
    self.songsExpanded = NO;
    
   
	// Do any additional setup after loading the view.
}

-(void) layoutTableView
{
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //[self.tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    CGRect tableFrame = self.songsTableContainer.frame;
    tableFrame.origin.x =0;
    tableFrame.origin.y=0;
    self.tableView.frame = tableFrame;
    
    [self.songsTableContainer addSubview:self.tableView];
    [self.songsTableContainer bringSubviewToFront:self.tableView];
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.scrollEnabled = YES;
    [self.tableView reloadData];
    
    NSLog(@"TABLE VIEW FRAME: %.2f %.2f %.2f %.2f", tableFrame.origin.x, tableFrame.origin.y, tableFrame.size.width, tableFrame.size.height);

}

-(void) viewDidAppear:(BOOL)animated
{
     [self updateWorkoutView];
}
#define EXPAND 188
-(void) showSongsExpanded
{
    NSLog(@"show songs");
     // [self.view bringSubviewToFront:self.songsView];
    [UIView animateWithDuration:0.25f  animations: ^{
      
        
       // self.songsTableContainer.frame= CGRectMake(0, 110+self.showSongsButton.frame.size.height, 320, 330-self.showSongsButton.frame.size.height);
      
    
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25f animations:^{
            CGRect songsViewFrame = self.songsView.frame;
            songsViewFrame.size.height +=EXPAND;
            songsViewFrame.origin.y -=EXPAND;

            
            
            self.songsView.frame = songsViewFrame;
            
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.0f animations:^{
                CGRect tableFrame = self.songsTableContainer.frame;
                tableFrame.size.height += self.retractedSongsFrame.size.height+EXPAND;
                tableFrame.origin.y=self.buttonBar.frame.origin.y + 80;
                self.songsTableContainer.frame = tableFrame;
                self.tableView.frame = CGRectMake(0, 0, self.songsTableContainer.frame.size.width, self.songsTableContainer.frame.size.height);
        
            } completion:^(BOOL finished) {
                if (finished)
                    [self.showSongsButton setImage:self.retractSongsImage forState:UIControlStateNormal];
  
            }];
            if (finished) {
              [self.showSongsButton setImage:self.retractSongsImage forState:UIControlStateNormal];
                NSLog(@" frame: %.2f %.2f %.2f %.2f", self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height);
            [self.tableView reloadData];
            }
        }];
        
        self.songsExpanded = YES;
     }];
     [self.songsView.superview bringSubviewToFront:self.songsView];
}
-(void) showSongsRetracted
{
    // [self.musicControlBar.superview bringSubviewToFront:self.musicControlBar];
     NSLog(@" frame: %.2f %.2f %.2f %.2f", self.songsView.frame.origin.x, self.songsView.frame.origin.y, self.songsView.frame.size.width, self.songsView.frame.size.height);
    [UIView animateWithDuration:0.1 animations:^{
       
 
    
    } completion:^(BOOL finished) {

            [UIView animateWithDuration:0.25 animations:^{
                       self.songsView.frame = self.retractedSongsFrame;
               

            }completion:^(BOOL finished) {
                if (finished) {
                [self.workoutGraph.superview bringSubviewToFront:self.workoutGraph];
                     [self.showSongsButton setImage:self.expandSongsImage forState:UIControlStateNormal];
                self.songsExpanded = NO;
                }
            }];
            
    }];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.musicPlayerController stop];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [self.musicPlayerController stop];
}

-(void) updateWorkoutView {
    
    [self layoutTableView];
    self.workoutGraph.intervals = self.workoutlist.intervals;
    self.remainingPlaybacktime = [NSNumber numberWithInt:self.workoutlist.actualWorkoutTime.intValue];
    self.workoutTimeRemaining.text = [TimeUtils minutesColonSeconds:self.remainingPlaybacktime.intValue];

}

-(void) observeValueForKeyPath:(NSString *)path ofObject:(NSObject *)anObject change: (NSDictionary *) theChange context:(void *)ctx {

    if ([path isEqualToString:@"workoutSongs"]) {
        
        [self updateWorkoutView];
    } else if([path isEqualToString:@"actualWorkoutTime"]) {
        self.remainingPlaybacktime = [NSNumber numberWithInt:self.workoutlist.actualWorkoutTime.intValue];
        self.workoutTimeRemaining.text = [TimeUtils minutesColonSeconds:self.remainingPlaybacktime.intValue];
        
    } else if ([path isEqualToString:@"remainingPlaybacktime"]) {
        self.workoutTimeRemaining.text = [TimeUtils minutesColonSeconds:self.remainingPlaybacktime.intValue];
    }
    
    
}
-(IBAction) showSongs:(id)sender
{
    NSLog(@"show songs....");
    
    if (self.songsExpanded) {
        
        NSLog(@"retract songs");
        [self showSongsRetracted];
    } else {
        [self showSongsExpanded];
    }
 
       
    
   // CGRect newTableViewBounds =
    
   // self.tableView.bounds = [self.view.bounds];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        NSArray * items = self.workoutlist.workoutListItems;
        return [items count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    NSLog(@"\n\n####### cellForRow: %d\n#######",[indexPath indexAtPosition:1]);
    SongTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SongTableCell" owner:self options:nil];
        cell = (SongTableCell *)[nib objectAtIndex:0];

    }
    
    MusicLibraryItem * mlItem = [self.workoutlist.workoutListItems objectAtIndex:[indexPath indexAtPosition:1]];
    MPMediaItem * song = mlItem.mediaItem;
    
    NSString * titleText = [song valueForProperty:MPMediaItemPropertyTitle];
    if (titleText.length > 20) {
        titleText = [titleText substringToIndex:20];
        titleText = [NSString stringWithFormat:@"%@...",titleText];
    }
    
    cell.title.text = titleText;
    cell.tempoClass.text = mlItem.tempoClassificaiton;
    cell.time.text =  [TimeUtils minutesColonSeconds:[[mlItem.mediaItem valueForProperty:MPMediaItemPropertyPlaybackDuration] intValue]];
     MPMediaItemArtwork * artwork = [song valueForProperty:MPMediaItemPropertyArtwork];
     UIImage *albumArtworkImage = [artwork imageWithSize:CGSizeMake(100.0, 100.0)];
    cell.artworkImage = albumArtworkImage;
    cell.backgroundColor = [UIColor blackColor];
    // Configure the cell...
    
    return cell;
}



#pragma mark - Table view delegate

-(void) playbackSongChanged:(NSNotification *) notification
{
        
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
        [self.workoutGraph startAnimate];
        
        
    } else {
        [self.workoutTimer invalidate];
        self.intervalLabel.text = @"";
        [self.workoutGraph stopAnimate];
        
    }
        
        
}
-(void) updateIntervalText
{
    MusicLibraryItem * currentMLitem = (MusicLibraryItem *) [self.workoutlist.workoutListItems objectAtIndex:self.musicPlayerController.indexOfNowPlayingItem];
                                                             ;
   /* self.intervalLabel.text = [NSString stringWithFormat:@"Interval %d: %@",currentMLitem.intervalIndex+1, currentMLitem.intervalDescription];*/
    self.workoutGraph.currentInterval = currentMLitem.intervalIndex;
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

-(void) setupAppMusicPlayer
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
 
}
-(IBAction)playMusic
{
         
  
   // [self.musicPlayerController addObserver:self forKeyPath:@"nowPlayingItem" options:NSKeyValueObservingOptionNew context:nil];
    
    NSMutableArray * playQueueArray = [[NSMutableArray alloc] initWithCapacity:self.workoutlist.workoutListItems.count ];
    self.playQueueArray = playQueueArray; 
    for (MusicLibraryItem * item in self.workoutlist.workoutListItems) {
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
