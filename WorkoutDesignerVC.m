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
@property (nonatomic, strong) UIAlertView * alert;
@end

@implementation WorkoutDesignerVC



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) viewWillAppear:(BOOL)animated
{
    [self listenForModelChanges];
    [self update];
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
  
    if (self.model == nil) {
        [self newWorkout];
    }
    self.nameField.text = self.model.name;

    
    
    //[self.model addObserver:self forKeyPath:@"intervals" options:NSKeyValueObservingOptionNew context:nil];
    //[self.model addObserver:self forKeyPath:@"workoutSeconds" options:NSKeyValueObservingOptionNew context:nil];
    
    

    
    
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (IBAction)newWorkoutAction:(id)sender {
    [self newWorkout];
}

-(void) newWorkout
{
    if ((self.model == nil) || (!self.model.changed) || (self.model.name)) {
        self.model = [[Workout alloc] init];
        [self listenForModelChanges];
        [self update];
    }
    else {
       self.alert =  [[UIAlertView alloc] initWithTitle:@"Lose changes" message:@"Creating a new workout without naming this one will lose changes to existing workout. Continue?" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"Continue", nil];
        [self.alert show];
    }
}
#pragma mark UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"alert view dismissed with button %ld", (long)buttonIndex);
    if (buttonIndex) {
        self.model = [[Workout alloc] init];
        [self listenForModelChanges];
        [self update];
    }
}

-(void) listenForModelChanges
{
    self.workoutGraph.workout = self.model;
    __weak typeof(self) weakSelf = self;
    [self.model addChangeAction:^(Workout *changedWorkout) {
        [weakSelf update];
    }];
}

-(void) update
{
    self.workoutTimeLabel.text = [NSString stringWithFormat:@"%ld minutes",self.model.workoutSeconds/60];
    if (self.model.name) {
        self.nameField.text = self.model.name;
    } else {
        self.nameField.text = nil;
    }
    
    [self.intervalsTable reloadData];
    [self.workoutGraph reloadData];
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
    [self.intervalsTable reloadData];

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
    BOOL consecutive = [self selectedIndexesAreConsecutive];
    if (consecutive) {
        NSUInteger location = ((NSIndexPath *) self.selectedIndexes[0]).row;
        NSUInteger length = self.selectedIndexes.count;
        [self.model repeatIntervalsInRange:NSMakeRange(location,length)];
    }
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
