//
//  ViewController.m
//  WorkoutInterval
//
//  Created by John La Barge on 10/12/13.
//
//

#import "WorkoutDesignerVC.h"
#import "Workout.h" 
#import "WorkoutInterval.h"
#import "IntervalCell.h"
#import "WorkoutIntervalPicker.h"
#import "TimePickerVCViewController.h"

@interface WorkoutDesignerVC ()
@property WorkoutInterval * selectedInterval;
@property CGPoint originalCenter;
@property NSIndexPath * selectedIndexPath;
@property IntervalCell * selectedCell;
@property UITextField * editingField;
@property TimePickerVCViewController * presentedTimePicker;
@property (nonatomic, strong) NSMutableArray * selectedIndexes;
@end

@implementation WorkoutDesignerVC



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    self.intervalsTable.allowsMultipleSelection = YES;
    
    self.selectedIndexes = [[NSMutableArray alloc] initWithCapacity:10];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
        UINib * intervalCell = [UINib  nibWithNibName:@"intervalcell" bundle:nil];
    [self.intervalsTable registerNib:intervalCell forCellReuseIdentifier:@"IntervalCell"];
    [self.navigationController setToolbarHidden:false animated:YES];
    /*
      TODO handle editing an existing 
     */
    if (self.model == nil) {
        self.model  = [[Workout alloc] init];
    }
    self.nameField.text = self.model.name;
    [[self.model.intervals objectAtIndex:0] addObserver:self forKeyPath:@"speed"  options:NSKeyValueObservingOptionNew context:NULL];
    
    
    [self.model addObserver:self forKeyPath:@"intervals" options:NSKeyValueObservingOptionNew context:nil];
    [self.model addObserver:self forKeyPath:@"workoutSeconds" options:NSKeyValueObservingOptionNew context:nil];
    __weak typeof(self) weakSelf = self;
    [self.model addChangeAction:^(Workout *changedWorkout) {
        [weakSelf.intervalsTable reloadData];
    }];
    self.workoutGraph.workout = self.model;
    
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if (self.editingField == self.nameField) {
        self.model.name = textField.text;
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.editingField = textField;
    
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.model.intervals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    IntervalCell *cell = (IntervalCell *)[tableView dequeueReusableCellWithIdentifier:@"IntervalCell" forIndexPath:indexPath];
    
    
   WorkoutInterval * interval = (WorkoutInterval *)[self.model.intervals objectAtIndex:[indexPath indexAtPosition:1]];
    
    cell.workoutInterval = interval;
    cell.timeLabel.seconds = interval.intervalSeconds;
    cell.parent = self;
    

    
    
    //cell.timePicker.hidden = YES;
    
    return cell;
}

- (IBAction)addInterval:(id)sender {

    WorkoutInterval * interval = [self.model newInterval];
    [interval addObserver:self forKeyPath:@"speed" options:NSKeyValueObservingOptionNew context:NULL];
    [self.intervalsTable reloadData];

}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.model) {
        if ([keyPath isEqualToString:@"workoutSeconds"]) {
            self.workoutTimeLabel.text = [NSString stringWithFormat:@"%d minutes",self.model.workoutSeconds/60];
            [self.workoutGraph reloadData];
        }
        else if ([keyPath isEqualToString:@"intervals"]) {
            [self.intervalsTable reloadData];
            [self.workoutGraph reloadData];
        }
    }  else {
        [self.workoutGraph reloadData];
    }
}

-(void) updateStateForSelection
{
    self.selectedIndexes = [[self.intervalsTable indexPathsForSelectedRows] mutableCopy];
    [self.selectedIndexes sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSIndexPath * a = obj1;
        NSIndexPath * b = obj2;
        return [a compare:b];
    }];
     self.repeatButton.enabled = [self selectedIndexesAreConsecutive];
    

}
-(BOOL) selectedIndexesAreConsecutive
{
    __weak NSIndexPath * previousIndexPath = nil;
    __block BOOL answer = YES;
    [self.selectedIndexes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSIndexPath * nextIndexPath = obj;
        if (previousIndexPath) {
            if ((nextIndexPath.row - previousIndexPath.row) > 1)  {
                answer = NO;
                *stop = YES;
            }
        }
        
    }];
    return answer; 
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexes = [[self.intervalsTable indexPathsForSelectedRows] mutableCopy];
     [self.selectedIndexes sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSIndexPath * a = obj1;
        NSIndexPath * b = obj2;
        return [a compare:b];
    }];

   
}
- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    [tableView reloadData];
    return indexPath;
}
-(void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [self updateStateForSelection];
    
}

- (IBAction)deleteIntervals:(id)sender {
    NSLog(@"deleting Intervals");
    
    [self.selectedIndexes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSIndexPath * index = (NSIndexPath *)obj;
        [self.model.intervals removeObjectAtIndex:index.row];
    }];
    [self.intervalsTable reloadData];
    [self.workoutGraph reloadData];
    

}
- (IBAction)repeatIntervals:(id)sender {
    __block NSIndexPath * lastIntervalIndex;
     [self.selectedIndexes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
         
         NSIndexPath * indexPath = obj;
         if (lastIntervalIndex && lastIntervalIndex.row  < indexPath.row) {
             lastIntervalIndex = indexPath;
         }
    }];
    
    
    NSArray * copiesOfSelectedIntervals = [self copiesOfSelectedIntervals];
    /*
      TODO encapsulate in model
     */
    
    
    if ([self selectedIndexesAreConsecutive]) {
        [self.selectedIndexes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSIndexPath * indexPath = obj;
            [self.model.intervals insertObject:copiesOfSelectedIntervals[idx] atIndex:idx+indexPath.row];
        }];
    }
 
    [self.model save];
    [self.intervalsTable reloadData];
    [self.workoutGraph reloadData];
}

-(NSArray *) copiesOfSelectedIntervals
{
    __weak NSMutableArray * intervals = self.model.intervals;
    NSMutableArray * copies = [[NSMutableArray alloc] initWithCapacity:self.selectedIndexes.count];
    __weak NSArray *sortedSelectedIndexes = self.selectedIndexes;
     [sortedSelectedIndexes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
         NSIndexPath * index = obj;
         [copies addObject:[intervals[index.row] copy]];
     }];
     return copies;
}
-(void) keyboardDidShow:(NSNotification *)note;
{
    self.originalCenter = self.view.center;
    if (!self.nameField.isEditing) {
        CGRect myRect = [self.selectedCell convertRect:self.selectedCell.frame toView:nil];
        NSLog(@"%2.f", myRect.origin.y);
        self.view.center = CGPointMake(self.originalCenter.x, self.originalCenter.y - 180);
        [self.intervalsTable scrollToRowAtIndexPath:self.selectedIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
   // [self.intervalsTable setContentOffset:CGPointMake(0,100.0)];
}
-(void) keyboardDidHide:(NSNotification *)note;
{
    self.view.center = self.originalCenter;
    //[self.intervalsTable setContentOffset:CGPointMake(0,0.0)];
}

-(void) presentTimePickerForInterval:(WorkoutInterval *)interval
{
    TimePickerVCViewController * timePicker = [[TimePickerVCViewController alloc] initWithNibName:@"TimePickerVCViewController" bundle:nil];
    timePicker.interval = interval;
    timePicker.selectedSeconds  = interval.intervalSeconds;
    self.presentedTimePicker = timePicker;
    self.presentedTimePicker.view.frame = CGRectMake(0,200,320,250);
    self.presentedTimePicker.view.backgroundColor = [UIColor clearColor];
    timePicker.blurView.blurRadius = 15.0; 
    [self.view addSubview:timePicker.blurView];
    
    [self.view addSubview:self.presentedTimePicker.view];
}

 

@end
