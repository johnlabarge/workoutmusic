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

- (void)viewDidLoad
{
    [super viewDidLoad];
    UINib * intervalCell = [UINib  nibWithNibName:@"MusicItemCell" bundle:nil];
    [self.tableView registerNib:intervalCell forCellReuseIdentifier:@"musicItemCell"];
    [self.tableView setRowHeight:132.0];
    [[MusicLibraryBPMs currentInstance:nil] sortByClassification];
    [self.changePlayListButton setTitle:[WorkoutMusicSettings workoutSongsPlaylist] forState:UIControlStateNormal];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [MusicLibraryBPMs currentInstance:nil].sortedItems.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MusicLibraryBPMs * library = [MusicLibraryBPMs currentInstance:nil];
    
    MusicLibraryItem * item = library.sortedItems[indexPath.row];
    

    
    MusicItemCell * itemCell = (MusicItemCell *)[tableView dequeueReusableCellWithIdentifier:@"musicItemCell" forIndexPath:indexPath];
    
    itemCell.musicItem = item;
    
    return itemCell;
    
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
