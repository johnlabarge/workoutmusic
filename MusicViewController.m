//
//  MusicViewController.m
//  WorkoutMusic
//
//  Created by John La Barge on 4/1/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import "MusicViewController.h"
#import "MusicLibraryBPMs.h" 
#import "MusicItemCell.h"
#import "WorkoutMusicSettings.h"

@interface MusicViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *changePlayListButton;
@property (weak, nonatomic) IBOutlet UILabel *playListTitle;
@property (weak, nonatomic) IBOutlet UIButton *changePlaylistButton;
@property (strong, nonatomic) UIAlertView * alert;
@property (readonly) MusicLibraryBPMs * library;
@property (nonatomic, assign) BOOL doNoPlaylistAlert;
@property (nonatomic, assign) BOOL doICloudAlert;
@property (nonatomic, assign) BOOL doOldDRMAlert;
@end

@implementation MusicViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(MusicLibraryBPMs *) library
{
    return [MusicLibraryBPMs currentInstance:nil];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    UINib * intervalCell = [UINib  nibWithNibName:@"MusicItemCell" bundle:nil];
    [self.tableView registerNib:intervalCell forCellReuseIdentifier:@"musicItemCell"];
    [self.tableView setRowHeight:132.0];
  /*  dispatch_async(
                   dispatch_queue_create("sortq", NULL) , ^{
                       [[MusicLibraryBPMs currentInstance:nil] sortByClassification];
                   });*/
        NSString * playListTitle = @"none selected!";
    NSLog(@"library processed status=%d",self.library.processed);
    
    if (self.library.processed) {
        playListTitle = [WorkoutMusicSettings workoutSongsPlaylist];
    } else {
        self.doNoPlaylistAlert = YES;
    }
    
    if (self.library.processed && self.library.didContainICloudItems) {
        self.doICloudAlert = YES;
    }
    
    [self.changePlayListButton setTitle:playListTitle forState:UIControlStateNormal];

    NSLog(@"#######\n viewDidLoad Complete \n#######");
}

-(void) viewDidAppear:(BOOL)animated
{
    if (self.doNoPlaylistAlert) {
        self.alert = [[UIAlertView alloc] initWithTitle:@"No playlist selected." message:@"Please choose a playlist that contains the songs you want to listen to during your workouts." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    } else if (self.doICloudAlert) {
        self.alert = [[UIAlertView alloc] initWithTitle:@"Cloud Items need to be downloaded" message:@"Apps cannot play music from iTunes Match/iCloud.  To use these songs in your workout playlists, go back to the Music application, select the playlist you are using for workout songs and touch \"Download All\"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    } else if (self.doOldDRMAlert) {
        self.alert = [[UIAlertView alloc] initWithTitle:@"Songs with Old DRM protection." message:@"Songs with Old DRM protection cannot be played by the WorkoutDJ.  Contact Apple to update these items and remove their DRM protection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    }
    [self.alert show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    MusicLibraryBPMs * library = [MusicLibraryBPMs currentInstance:nil];
    NSArray * list = (NSArray *)library.classifiedItems[[Tempo speedDescription:section]];
    return list.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"cell for row at indexPath");
    MusicLibraryBPMs * library = [MusicLibraryBPMs currentInstance:nil];
    
    NSString * itemType = [Tempo speedDescription:indexPath.section];
    
    
    MusicLibraryItem * item = library.classifiedItems[itemType][indexPath.row];
    

    
    MusicItemCell * itemCell = (MusicItemCell *)[tableView dequeueReusableCellWithIdentifier:@"musicItemCell" forIndexPath:indexPath];
    
    itemCell.musicItem = item;
    
    return itemCell;
    
}

-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    self.alert = nil;
    self.doNoPlaylistAlert = NO;
    self.doICloudAlert = NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [Tempo tempoToIntensity:[Tempo speedDescription:section]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
        PlaylistChooserViewController * playlistChooser = (PlaylistChooserViewController *) segue.destinationViewController;
        playlistChooser.delegate = self;
        
}
-(void)optionChosen:(NSObject *)option
{
    NSString * playListName = (NSString *)option;
    [WorkoutMusicSettings setWorkoutSongsPlaylist:playListName];
}
@end
