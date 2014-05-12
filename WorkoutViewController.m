//
//  WorkoutViewController.m
//  WorkoutMusic
//
//  Created by John La Barge on 11/30/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//
#import "WorkoutList.h"
#import "WorkoutViewController.h"
#import "WorkoutListItem.h"
#import "SongTableCell.h"
#import "SongInstruction.h"
#import "INtervalSectionCell.h"
#import "SongJockeyPlayer.h"
#import "SJConstants.h"
@interface WorkoutViewController ()
@property (nonatomic, strong) NSDictionary * constraintMap;
@property (nonatomic, strong) NSArray  * landscapeConstraints;

@property (nonatomic, strong) SongJockeyPlayer * sjPlayer;

@property (nonatomic, assign) BOOL paused;


@end

@implementation WorkoutViewController

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
    self.paused = YES;
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

    UINib * intervalCell = [UINib  nibWithNibName:@"SongTableCell" bundle:nil];
    [self.songTable registerNib:intervalCell forCellReuseIdentifier:@"songTableCell"];
   /* self.songTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
   self.songTableContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
 */   UINib * headerCell = [UINib nibWithNibName:@"IntervalSectionCell" bundle:nil];
    [self.songTable registerNib:headerCell
         forCellReuseIdentifier:@"sectionCell"];
    self.songTable.separatorColor = [UIColor clearColor];
//self.songTable.superview.backgroundColor = [UIColor blueColor];
    self.songTable.contentInset = UIEdgeInsetsZero;
    [self.songTable setHidden:YES];
        // Do any additional setup after loading the view.
    
    
    self.graph.workout = self.workout;
    self.graph.active = YES;
    
    self.workoutList = [WorkoutList sharedInstance];
    [self.spinner startAnimating];
    self.spinner.hidesWhenStopped = YES;
    __weak typeof(self) me = self;
    
    [self.workoutList generateListForWorkout:self.workout afterGenerated:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [me.spinner stopAnimating];
            [me.songTable reloadData];
            SJPlaylist * list = [me.workoutList toSJPlaylist];
            [list eachSong:^(SongJockeySong *song, NSUInteger index, BOOL *stop) {
                NSLog(@"list %lu: %@ %@", (unsigned long)index, song.songTitle,(song.isICloudItem ? @"icloud" : @"non-icloud"));
                
            }];
            
            me.sjPlayer = [[SongJockeyPlayer alloc] initWithSJPlaylist:[me.workoutList toSJPlaylist]];
            [[NSNotificationCenter defaultCenter] addObserverForName:kSJTimerNotice object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                [me timeTick];
            }];
            [[NSNotificationCenter defaultCenter] addObserverForName:kSJPlayingNotice object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                [me makePlaying];
            }];
            [[NSNotificationCenter defaultCenter] addObserverForName:kSJPausedNotice object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                [me makePaused];
            }];
            [me.spinner removeFromSuperview];
            [me.songTable setHidden:NO];
        });
        
    }];

 
}
 
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.workout.intervals.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSInteger songCount = [self.workoutList numberOfSongsPerInterval:section];
   // NSLog(@"%d songs for interval %d", songCount, section);
    return songCount+1;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WorkoutListItem * item  = (WorkoutListItem *)[self.workoutList.workoutListItems objectAtIndex:indexPath.section];
    UITableViewCell * cell;
    
    if (indexPath.row == 0) {
        IntervalSectionCell * sectionCell = (IntervalSectionCell *) [tableView dequeueReusableCellWithIdentifier:@"sectionCell" forIndexPath:indexPath];
        sectionCell.title.text = [tableView.dataSource tableView:tableView titleForHeaderInSection:indexPath.section];
        cell = sectionCell;

    } else {
        SongJockeySong * song = (SongJockeySong *) [item.songs objectAtIndex:indexPath.row-1];
        song.userInfo[@"table_index_path"] = indexPath;
        
        NSInteger playListIndex = [self.workoutList playListIndex:item andSong:song];
        
        
        SongTableCell * songCell = (SongTableCell *)[tableView dequeueReusableCellWithIdentifier:@"songTableCell" forIndexPath:indexPath];
        songCell.tempoClass.text = item.speedDescription;
        
            MPMediaItemArtwork * artwork = [song.mediaItem valueForProperty:MPMediaItemPropertyArtwork];
        UIImage *albumArtworkImage = [artwork imageWithSize:CGSizeMake(85.0, 85.0)];
        songCell.artworkImage = albumArtworkImage;
        /*TODO : fix this */
        songCell.description = [NSString stringWithFormat:@"%@ - %@",song.songArtist, song.songTitle];
        songCell.descriptionLabel.text = songCell.description;
        songCell.bpmLabel.text = [NSString stringWithFormat:@"%.2f",((NSNumber *)song.userInfo[@"bpm"]).doubleValue];
        if (playListIndex != self.sjPlayer.currentIndex) {
            songCell.backgroundColor = [UIColor whiteColor];
            songCell.time.text = [NSString stringWithFormat:@"%d", (int) song.seconds];

        } else {
            songCell.backgroundColor  = [UIColor orangeColor];
            NSInteger seconds = (self.sjPlayer.remainingSeconds > 0 ? self.sjPlayer.remainingSeconds : song.seconds);
            songCell.time.text = [NSString stringWithFormat:@"%d", (int) seconds];
        }

        cell = songCell;
    }
    return cell;

}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Interval %ld - %@",(long)section, [Tempo speedDescription:((WorkoutInterval *)[self.workout.intervals objectAtIndex:section]).speed]];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 25.0f;
    }
    return 65.0f;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
  /*if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
      
     // [self.view addConstraints:self.landscapeConstraints];
     

    } else if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        
      //  [self.view removeConstraints:self.landscapeConstraints];
        
    }
    [self.songTable reloadData];
    [self.songTable setNeedsLayout];*/
    
}
-(void) makePlaying
{
    [self.playPause setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    [self.graph startAnimate];
    self.paused = NO;
}

-(void) makePaused
{
    [self.playPause setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [self.graph stopAnimate];
    self.paused = YES;
}

                                
-(void) timeTick
{
    
    
    [self.songTable reloadData];
    
    [self.songTable scrollToRowAtIndexPath:self.sjPlayer.currentSong.userInfo[@"table_index_path"] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    WorkoutInterval * interval = (WorkoutInterval *)self.sjPlayer.currentSong.userInfo[@"workoutInterval"];
    
    
    self.graph.currentInterval = interval.position;
}
- (IBAction)back:(id)sender {
    [self.sjPlayer previous];
}
- (IBAction)play:(id)sender {
    if (self.paused) {
        [self.sjPlayer play];
    } else {
        [self.sjPlayer pause];
    }
}

- (IBAction)forward:(id)sender {
    [self.sjPlayer next];
}


@end
