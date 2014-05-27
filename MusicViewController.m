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
#import "WOMusicAppDelegate.h"
#import "TempoSectionHeader.h"


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
@property (readonly) WOMusicAppDelegate * app;
@property (nonatomic, strong) NSMutableArray * sectionHeaders;
@property (nonatomic, strong) NSMutableArray * expandedSections;
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
    [self initExpandedSections];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    UINib * intervalCell = [UINib  nibWithNibName:@"MusicItemCell" bundle:nil];
    //UINib * tempoHeader = [UINib nibWithNibName:@"TempoSectionHeader" bundle:nil];
    [self.tableView registerClass:[TempoSectionHeader class] forHeaderFooterViewReuseIdentifier:@"TempoHeader"];

    [self.tableView registerNib:intervalCell forCellReuseIdentifier:@"musicItemCell"];
    [self.tableView setRowHeight:140.0];
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
    typeof(self) weakSelf = self;
    [self.changePlayListButton setTitle:playListTitle forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"reclassified_media" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [weakSelf.app.workout reloadLibrary];
        MusicLibraryItem * item = note.userInfo[@"musicItem"];
        NSInteger newIntensity = ((NSNumber *)note.userInfo[@"newIntensity"]).integerValue;
        NSString * itemType = [Tempo speedDescription:newIntensity];
        
        NSArray * sectionArray = weakSelf.library.classifiedItems[itemType];
        NSUInteger row = [sectionArray indexOfObject:item];
    
        NSIndexPath * scrollTo = [NSIndexPath indexPathForRow:row inSection:newIntensity];
        __block UITableViewCell * cell;
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           
                           
                           UIColor * oldBackground  = cell.contentView.backgroundColor;

                           [UIView animateWithDuration:0.5 animations:^{
                               
                               BOOL expanded = ((NSNumber *) weakSelf.expandedSections[scrollTo.section]).boolValue;
                               if (!expanded) {
                                   [self expandSection:scrollTo.section];
                               } else {
                                 [weakSelf.tableView reloadData];
                               }
                               [weakSelf.tableView scrollToRowAtIndexPath:scrollTo atScrollPosition:UITableViewScrollPositionMiddle animated:NO];

                               
                           } completion:^(BOOL finished) {
                               if (finished) {
                                   cell = [weakSelf.tableView cellForRowAtIndexPath:scrollTo];
                                   [UIView animateWithDuration:0.5 animations:^{
                                   
                                       cell.contentView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:204/255.0 blue:51/255.0 alpha:1.0];
                                   
                                   } completion:^(BOOL finished) {
                                       [UIView animateWithDuration:1.0 animations:^{
                                           cell.contentView.backgroundColor = oldBackground;
                                           
                                       } completion:^(BOOL finished) {
                                           
                                       }];
                                   }];
                               }
                               
                               
                           }];
                       });
                       
                           
    }];
    

    NSLog(@"#######\n viewDidLoad Complete \n#######");
}
-(void) initExpandedSections
{
    self.expandedSections = [[NSMutableArray alloc] initWithCapacity:[Tempo speedDescriptions].count];
    
    for (NSUInteger i = 0; i < [Tempo speedDescriptions].count; i++) {
        self.expandedSections[i] = [NSNumber numberWithBool:NO];
    }
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
-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    TempoSectionHeader * header = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"TempoHeader"];
    header.sectionNumber = section;
    header.expansionDelegate = self;
    header.sectionNameLabel.text = [NSString stringWithFormat:@"%@ Intensity", [Tempo tempoToIntensity:[Tempo speedDescription:section]]];
    BOOL expansionState = ((NSNumber *)self.expandedSections[section]).boolValue;
    header.expansionState = expansionState; 
    //header.sectionNameLabel.text = [Tempo speedDescription:section];
    return header;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [Tempo speedDescriptions].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger result = 0;
    BOOL expanded =  ((NSNumber *)self.expandedSections[section]).boolValue;
    if (expanded) {
        MusicLibraryBPMs * library = [MusicLibraryBPMs currentInstance:nil];
        NSArray * list = (NSArray *)library.classifiedItems[[Tempo speedDescription:section]];
    
        result  = list.count;
    }
    return result;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
    return @"";//[Tempo tempoToIntensity:[Tempo speedDescription:section]];
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
-(void)expandSection:(NSUInteger)sectionNum
{
    if (sectionNum < [Tempo speedDescriptions].count) {
        self.expandedSections[sectionNum] = [NSNumber numberWithBool:YES];
    }
    [self.tableView reloadData];
    NSInteger rowsForSection = [self.tableView numberOfRowsInSection:sectionNum];
    if (rowsForSection > 0 ) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionNum] atScrollPosition: UITableViewScrollPositionTop animated:YES];
    }
}
-(void)contractSection:(NSUInteger)sectionNum
{
    self.expandedSections[sectionNum] = [NSNumber numberWithBool:NO];
    [self.tableView reloadData];
}
-(void)optionChosen:(NSObject *)option
{
    NSString * playListName = (NSString *)option;
    [WorkoutMusicSettings setWorkoutSongsPlaylist:playListName];
}

-(WOMusicAppDelegate *)app {
    return (WOMusicAppDelegate *)[UIApplication sharedApplication].delegate;
}
- (IBAction)reProcess:(id)sender {
    [self.app reprocessSongs];
}

@end
