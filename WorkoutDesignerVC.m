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

@interface WorkoutDesignerVC ()
@property WorkoutInterval * selectedInterval;
@property CGPoint originalCenter;
@property NSIndexPath * selectedIndexPath;
@property IntervalCell * selectedCell;
@property UITextField * editingField;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
        UINib * intervalCell = [UINib  nibWithNibName:@"intervalcell" bundle:nil];
    [self.intervalsTable registerNib:intervalCell forCellReuseIdentifier:@"IntervalCell"];
    [self.navigationController setToolbarHidden:false animated:YES];
    /*
      TODO handle editing an existing 
     */
    self.model  = [[Workout alloc] init];
    self.nameField.text = self.model.name;
    [[self.model.intervals objectAtIndex:0] addObserver:self forKeyPath:@"speed"  options:NSKeyValueObservingOptionNew context:NULL];
    
    
    [self.model addObserver:self forKeyPath:@"intervals" options:NSKeyValueObservingOptionNew context:nil];
    [self.model addObserver:self forKeyPath:@"workoutSeconds" options:NSKeyValueObservingOptionNew context:nil];
    
    self.workoutGraph.workout = self.model;
    
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if (self.editingField == self.nameField) {
        NSLog(@"changing name....to %@",self.nameField.text);
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

    cell.timePicker.dataSource = self;
    cell.timePicker.delegate = self;
    [cell.timePicker reloadAllComponents];
    cell.seconds = interval.intervalSeconds;
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    IntervalCell * cell = (IntervalCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    self.selectedInterval = cell.workoutInterval;
}

-(void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    IntervalCell * cell = (IntervalCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    self.selectedInterval = cell.workoutInterval;
    self.selectedIndexPath = indexPath;
    self.selectedCell = cell;
    
}
- (IBAction)deleteInterval:(id)sender {
    NSLog(@"deleting Interval.."); 
    [self.model deleteInterval:self.selectedInterval];
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

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    NSLog(@"number of ComponentsInPickerView");
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSLog(@"numberOfRowsInComponent");
    return 60;
}



- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    NSLog(@"titleForRow");
    
    NSInteger seconds = (row+1)*10;
    NSInteger minutes = seconds/60;
    NSInteger leftOverSeconds = seconds-(minutes*60);
    
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:15.0];
    label.text  = [NSString stringWithFormat:@"%d min %ds", minutes, leftOverSeconds];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    WorkoutIntervalPicker * wop = (WorkoutIntervalPicker *)pickerView;
    wop.interval.intervalSeconds = [wop selectedRowInComponent:0];
}

@end
