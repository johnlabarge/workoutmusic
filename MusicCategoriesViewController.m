//
//  MusicCategoriesViewController.m
//  WorkoutMusic
//
//  Created by John La Barge on 6/7/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import "MusicCategoriesViewController.h"
#import "Tempo.h"
#import "MusiccategoryCell.h"
#import "MusicViewController.h"
#import "WorkoutMusicSettings.h" 
#import "WOMusicAppDelegate.h"
@interface MusicCategoriesViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIAlertView * alert;
@property (nonatomic, assign) BOOL doNoPlaylistAlert;
@property (nonatomic, assign) BOOL doICloudAlert;
@property (nonatomic, assign) BOOL doOldDRMAlert;
@property (weak, nonatomic) IBOutlet UILabel *iCloudLabel;
@property (nonatomic, weak) UIButton * changePlayListButton;
@property (readonly) MusicLibraryBPMs * library;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@end

@implementation MusicCategoriesViewController

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
    self.navigationItem.title = @"Music Manager";
    NSString * playListTitle = @"none selected!";
    NSLog(@"library processed status=%d",self.library.processed);
    if (self.library.didContainICloudItems) {
        self.iCloudLabel.hidden = NO;
    } else {
        self.iCloudLabel.hidden = YES;
    }
    if (self.library.processed) {
        playListTitle = [WorkoutMusicSettings workoutSongsPlaylist];
    } else {
        self.doNoPlaylistAlert = YES;
    }
    
    if (self.library.processed && self.library.didContainICloudItems) {
        self.doICloudAlert = YES;
    }
    
    [self.playListButton setTitle:playListTitle forState:UIControlStateNormal];
    self.totalNumberSongsLabel.text = [NSString stringWithFormat:@"WorkoutDJ is using %lu songs from playlist:",self.library.libraryItems.count];
 
    
    self.numberOverriddenLabel.text = [NSString stringWithFormat:@"%lu",self.library.numberOfOverriddenItems];
    self.numberCantDetermine.text  = [NSString stringWithFormat:@"%lu",self.library.numberNotFound];
     self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView.bounds.size.height/5;
}


-(NSInteger) countForIntensity:(NSInteger)classNum
{
    return ((NSArray *)self.library.classifiedItems[[Tempo speedDescription:classNum]]).count;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * speedDescriptions = [Tempo speedDescriptions];
    __block NSInteger count = 1;
    [speedDescriptions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray * itemsArray = (NSArray *) self.library.classifiedItems[obj];
        if (itemsArray.count > 0) {
            count++;
        }
        
    }];
    return count;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"musicCategoryTableCell"];
    MusicCategoryCell * mccell = (MusicCategoryCell *) cell;
    if (indexPath.row == 0) {
        mccell.categoryText = @"All Songs";
        mccell.count  = self.library.libraryItems.count;
        MPMediaItemArtwork * art = [[WorkoutList sharedInstance] firstArtworkForCategory:nil];
        mccell.firstArtworkImage.image = [art imageWithSize:CGSizeMake(50.0,50.0)];
        
    } else {
        NSString * intensity = [Tempo intensities][indexPath.row - 1];
        mccell.categoryText = intensity;
        mccell.count = [self countForIntensity:indexPath.row-1];
        MPMediaItemArtwork * art  = [[WorkoutList sharedInstance] firstArtworkForCategory:[Tempo classifications][indexPath.row-1]];
        mccell.firstArtworkImage.image = [art imageWithSize:CGSizeMake(50.0,50.0)];
    }
    return mccell;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"musicCategorySegue"]) {
        MusicViewController * mvc = (MusicViewController *) segue.destinationViewController;
        mvc.category = self.category;
    } else {
        PlaylistChooserViewController * playlistChooser = (PlaylistChooserViewController *) segue.destinationViewController;
     
    }
}

- (IBAction)unwindFromPlayListChooser:(UIStoryboardSegue *)segue {
    PlaylistChooserViewController * playListChooser = segue.sourceViewController;
    [WorkoutMusicSettings setWorkoutSongsPlaylist:playListChooser.selectedPlaylist ];
}
-(void) viewDidAppear:(BOOL)animated
{
    if (self.doNoPlaylistAlert) {
        [self performSegueWithIdentifier:@"choosePlaylist" sender:self];
    } else if (self.doICloudAlert) {
        self.alert = [[UIAlertView alloc] initWithTitle:@"Cloud Items need to be downloaded" message:@"Apps cannot play music from iTunes Match/iCloud.  To use these songs in your workout playlists, go back to the Music application, select the playlist you are using for workout songs and touch \"Download All\"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    } else if (self.doOldDRMAlert) {
        self.alert = [[UIAlertView alloc] initWithTitle:@"Songs with Old DRM protection." message:@"Songs with Old DRM protection cannot be played by the WorkoutDJ.  Contact Apple to update these items and remove their DRM protection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    }
    self.tableViewHeightConstraint.constant = self.tableView.contentSize.height;
    
    [self.alert show];
}

-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    self.alert = nil;
    self.doNoPlaylistAlert = NO;
    self.doICloudAlert = NO;
}

-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        self.category = @"All Songs";
        
    } else {
        self.category = [Tempo intensities][indexPath.row - 1];
    }
    [self performSegueWithIdentifier:@"musicCategorySegue" sender:self];
}



-(WOMusicAppDelegate *)app {
    return (WOMusicAppDelegate *)[UIApplication sharedApplication].delegate;
}

-(MusicLibraryBPMs *) library
{
    return [MusicLibraryBPMs currentInstance:nil];
}
- (IBAction)reProcess:(id)sender {
    [self.app reprocessSongs];
}

-(UIImage *) firstArtworkImageForCategory
{
    
}


@end
