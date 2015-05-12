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
#import "WOMMediaReclassifiedViewController.h"


@interface MusicViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (readonly) MusicLibraryBPMs * library;

@property (readonly) WOMusicAppDelegate * app;
@property (nonatomic, strong) NSMutableArray * sectionHeaders;
@property (nonatomic, strong) NSMutableArray * expandedSections;
@property (nonatomic, strong) NSArray  * songList;
@property (nonatomic, assign) BOOL doNoPlaylistAlert;
@property (nonatomic, assign) BOOL doICloudAlert;
@property (nonatomic, assign) BOOL doOldDRMAlert;
@property (nonatomic, strong) NSIndexPath * reclassifyingIndex;
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
     self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
   // self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];
    self.tableView.contentInset = UIEdgeInsetsMake(-50, 0, 0, 0);
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
        self.songList = [self listForCatgory];
        MusicLibraryItem * item = note.userInfo[@"musicItem"];
        NSInteger row = [note.userInfo[@"info"][@"row"] integerValue];
        if (![self.songList containsObject:item]) {
            [self presentReclassificationAlert:item newClassification:note.userInfo[@"newIntensity"] row:row];
        }
    }];
    

}

-(void) viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

-(void) presentReclassificationAlert:(MusicLibraryItem *)item newClassification:(NSString *)newClass row:(NSInteger)row
{
//    WOMMediaReclassifiedViewController * mediaReclassifiedAlert = [[WOMMediaReclassifiedViewController alloc] init];
  WOMMediaReclassifiedViewController * mediaReclassifiedAlert = [[WOMMediaReclassifiedViewController alloc] initWithNibName:@"WOMMediaReclassifiedViewControllert" bundle:[NSBundle mainBundle]];
//   
    
    mediaReclassifiedAlert.classification = ((NSNumber *)newClass).integerValue;
    mediaReclassifiedAlert.musicItem = item;
    mediaReclassifiedAlert.transitioningDelegate = self;
    mediaReclassifiedAlert.modalPresentationStyle = UIModalPresentationCustom;
   
    self.reclassifyingIndex = [NSIndexPath indexPathForRow:row inSection:0];
    
    [self presentViewController:mediaReclassifiedAlert animated:YES completion:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:^{
                [self.tableView reloadData];
                
            }];
        });
    }
    ];
    //  [mediaReclassifiedAlert show:self.view];
   // NSLog(@" frame= %@", @(mediaReclassifiedAlert.frame.size.height));
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
    
    list = [list sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        MusicLibraryItem * item = (MusicLibraryItem *)obj1;
        MusicLibraryItem * item2 = (MusicLibraryItem *)obj2;
        return [item.title compare:item2.title];
        
    }];
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
    itemCell.row = indexPath.row;
    
    return itemCell;
    
}



- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";//[Tempo tempoToIntensity:[Tempo speedDescription:section]];
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;

}

#pragma mark - UIViewControllerTransitioningDelegate


- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning



#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 1;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    // Uncomment this line if you want to poke around at what Apple is doing a bit more.
    //    NSLog(@"context class is %@", [transitionContext class]);
    
    NSIndexPath *selected = self.reclassifyingIndex;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:selected];
    
    UIView *container = transitionContext.containerView;
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = fromVC.view; //[transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = toVC.view; //[transitionContext viewForKey:UITransitionContextToViewKey];
    UIView * containerView = [transitionContext containerView];
    CGRect beginFrame = [container convertRect:cell.bounds fromView:cell];
    
    
    CGRect endFrame = CGRectMake(beginFrame.origin.x+beginFrame.size.width, beginFrame.origin.y, beginFrame.size.width, beginFrame.size.height);
    
    if (toVC.isBeingPresented) {
        toView.alpha = 0.0;
        toView.frame = beginFrame;
        [containerView addSubview:toView];
        [UIView animateWithDuration:0.5 animations:^{
            toView.alpha = 1.0;
            [self.tableView deleteRowsAtIndexPaths:@[selected] withRowAnimation:UITableViewRowAnimationNone];
        } completion:^(BOOL finished) {
            
            [transitionContext completeTransition:YES];
            
        }];
    } else {
        [UIView animateWithDuration:0.75 animations:^{
           fromView.frame = endFrame;
            
        } completion:^(BOOL finished) {
            if (finished) {
                [fromView removeFromSuperview];
                [transitionContext completeTransition:YES];
            }
        }];
    }

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
