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
#import "WOMMediaReclassifiedView.h" 


@interface MusicViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (readonly) MusicLibraryBPMs * library;

@property (readonly) WOMusicAppDelegate * app;
@property (nonatomic, strong) NSMutableArray * sectionHeaders;
@property (nonatomic, strong) NSMutableArray * expandedSections;
@property (nonatomic, weak) NSArray  * songList;
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
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.tableView setSeparatorColor:[UIColor grayColor]];
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@ Intensity",  self.category];
    UINib * intervalCell = [UINib  nibWithNibName:@"MusicItemCell" bundle:nil];
    //UINib * tempoHeader = [UINib nibWithNibName:@"TempoSectionHeader" bundle:nil];
    [self.tableView registerClass:[TempoSectionHeader class] forHeaderFooterViewReuseIdentifier:@"TempoHeader"];

    [self.tableView registerNib:intervalCell forCellReuseIdentifier:@"musicItemCell"];
    [self.tableView setRowHeight:140.0];
  /*  dispatch_async(
                   dispatch_queue_create("sortq", NULL) , ^{
                       [[MusicLibraryBPMs currentInstance:nil] sortByClassification];
                   });*/

    [self registerForRecatagorizedNotification];
  
    
    NSLog(@"#######\n viewDidLoad Complete \n#######");
}
-(void) setCategory:(NSString *)category
{
    _category = category;
    self.songList = [self listForCatgory];
}

-(void) registerForRecatagorizedNotification
{
    __weak typeof(self) weakSelf = self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"reclassified_media" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [weakSelf.tableView reloadData];
        MusicLibraryItem * item = note.userInfo[@"musicItem"];
        if (![self.songList containsObject:item]) {
            [self presentReclassificationAlert:item newClassification:note.userInfo[@"newIntensity"]];
        }
    }];
    

}

-(void) presentReclassificationAlert:(MusicLibraryItem *)item newClassification:(NSString *)newClass
{
    WOMMediaReclassifiedView * mediaReclassifiedAlert = [[WOMMediaReclassifiedView alloc] init];
    
    mediaReclassifiedAlert.classification = ((NSNumber *)newClass).integerValue;
    mediaReclassifiedAlert.musicItem = item;
    [mediaReclassifiedAlert show:self.view];
}
/*-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    TempoSectionHeader * header = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"TempoHeader"];
    header.sectionNumber = section;
    if ([self.category rangeOfString:@"All"].location != NSNotFound) {
        header.sectionNameLabel.text = @"All Songs";
    } else {
        header.sectionNameLabel.text = [NSString stringWithFormat:@"%@ Intensity",  self.category];
    }
    //header.sectionNameLabel.text = [Tempo speedDescription:section];
    return header;
}*/




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSArray *) listForCatgory
{
    NSArray * list;
    if ([self.category rangeOfString:@"All"].location != NSNotFound) {
        list = self.library.libraryItems;
    } else {
        NSInteger index = [[Tempo intensities] indexOfObject:self.category];
        NSString * speed  = [Tempo speedDescriptions][index];
        list = self.library.classifiedItems[speed];
    }
    return list;
}
#pragma mark UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.songList.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MusicLibraryItem * item = self.songList[indexPath.row];
    
    MusicItemCell * itemCell = (MusicItemCell *)[tableView dequeueReusableCellWithIdentifier:@"musicItemCell" forIndexPath:indexPath];
    
    itemCell.musicItem = item;
    
    return itemCell;
    
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



@end
