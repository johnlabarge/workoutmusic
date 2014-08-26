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
#import "TimePickerVCViewController.h"
#import "ModalTransitioningControllerDelegate.h"
#import "UIView+Util.h"
#import "NSIndexPath+Equality.h"

@interface WorkoutDesignerVC ()
@property WorkoutInterval * selectedInterval;
@property CGPoint originalCenter;
@property NSIndexPath * selectedIndexPath;
@property IntervalCell * selectedCell;
@property UITextField * editingField;
@property TimePickerVCViewController * presentedTimePicker;
@property (nonatomic, strong) NSMutableArray * selectedIndexes;
@property (nonatomic, strong) UIAlertView * alert;
@property (weak, nonatomic) IBOutlet UILabel *repeatLabel;
@property (strong,nonatomic) id <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning> modalPresenter;
@property (nonatomic, assign) BOOL doDeselect; 
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
    
   // self.selectedIndexes = [[NSMutableArray alloc] initWithCapacity:10];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
        UINib * intervalCell = [UINib  nibWithNibName:@"intervalcell" bundle:nil];
    [self.intervalsTable registerNib:intervalCell forCellReuseIdentifier:@"IntervalCell"];
    self.modalPresentationStyle = UIModalPresentationFormSheet;
  
    
    if (self.model == nil) {
        [self newWorkout];
    }
    self.nameField.text = self.model.name;
    self.intervalsTable.rowHeight = 70.0;
    [self hideRepeat:YES];
    
    UIView * footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    UIButton * button =  [footer add:[[UIButton alloc] init]];
    footer.userInteractionEnabled = YES;
    [footer expandToWidth:button];
    [footer expandToHeight:button];
    footer.backgroundColor = [UIColor blackColor];
    [button setImage:[UIImage imageNamed:@"add_interval"] forState:UIControlStateNormal];
    button.titleLabel.textColor = [UIColor blackColor];
 
    button.userInteractionEnabled = YES;
    [button addTarget:self action:@selector(addInterval:) forControlEvents:UIControlEventTouchUpInside];
 
    
    
    self.intervalsTable.tableFooterView = footer;
    
    
    self.modalPresenter = [[ModalTransitioningControllerDelegate alloc] init];
 
}
-(void) hideRepeat:(BOOL)yesOrNo
{
    self.repeatButton.hidden = yesOrNo;
    self.repeatLabel.hidden = yesOrNo;
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
    self.workoutTimeLabel.text = [NSString stringWithFormat:@"%d minutes",self.model.workoutSeconds/60];
    if (self.model.name) {
        self.nameField.text = self.model.name;
    } else {
        self.nameField.text = nil;
    }
    [self.model recalculate];
    [self updateStateForSelection];
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
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}
-(void) keyboardDidShow:(NSNotification *)note;
{
    self.originalCenter = self.view.center;
    if (!self.nameField.isEditing) {
        CGRect myRect = [self.selectedCell convertRect:self.selectedCell.frame toView:nil];
        NSLog(@"%2.f", myRect.origin.y);
        self.view.center = CGPointMake(self.originalCenter.x, self.originalCenter.y - 180);
        [self.intervalsTable scrollToRowAtIndexPath:self.selectedIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        [self.intervalsTable setUserInteractionEnabled:NO];
        [self setCellInteraction:NO];
    }
}
-(void) keyboardDidHide:(NSNotification *)note;
{
    self.view.center = self.originalCenter;
    [self.intervalsTable setUserInteractionEnabled:YES];
    [self setCellInteraction:YES];
}
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
    cell.parentTable = self.intervalsTable; 
    
   WorkoutInterval * interval = (WorkoutInterval *)[self.model.intervals objectAtIndex:[indexPath indexAtPosition:1]];
    
    cell.workoutInterval = interval;
    cell.timeLabel.seconds = interval.intervalSeconds;
    cell.parent = self;


    if ([self selectedIndexesAreConsecutive] && indexPath.row == [self lastSelectedIndex]) {
        cell.repeatButton.hidden = NO;
        [cell.repeatButton addTarget:self action:@selector(repeatIntervals:)                     forControlEvents:UIControlEventTouchUpInside];
    } else {
        [cell.repeatButton removeTarget:self action:@selector(repeatIntervals:) forControlEvents:UIControlEventTouchUpInside];
        cell.repeatButton.hidden = YES;
    }
    return cell;
}
- (IBAction)addInterval:(id)sender {

    [self.model newInterval];
    [self deselectAllRows];

}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(editingStyle == UITableViewCellEditingStyleDelete){
        NSIndexSet * indexes = [[NSIndexSet alloc] initWithIndex:indexPath.row];
        [self.model  removeIntervalsAtIndexes:indexes];
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
    
    [self.intervalsTable reloadData];

    [self.selectedIndexes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSIndexPath *index = (NSIndexPath *)obj;
        [self.intervalsTable selectRowAtIndexPath:index animated:NO scrollPosition:UITableViewScrollPositionNone];
        UITableViewCell * cell = [self.intervalsTable cellForRowAtIndexPath:index];
        cell.highlighted = YES;
        NSLog(@"selecting row :%@ ", @(index.row));
    }];


}
-(BOOL) selectedIndexesAreConsecutive
{
    __block NSIndexPath * previousIndexPath = nil;
    __block BOOL answer = !(self.selectedIndexes == nil);
    [self.selectedIndexes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSIndexPath * nextIndexPath = obj;
        if (previousIndexPath) {
            if ((nextIndexPath.row - previousIndexPath.row) > 1)  {
                answer = NO;
                *stop = YES;
            }
        }
        previousIndexPath = nextIndexPath;
        
    }];
    return answer; 
}

-(BOOL) isSelected:(NSIndexPath *)path
{
    return [self.selectedIndexes containsObject:path];
}
-(NSMutableArray *) selectedIndexes
{
    if (!_selectedIndexes)
        _selectedIndexes = [[self.intervalsTable indexPathsForSelectedRows] mutableCopy];
    return _selectedIndexes;
}

-(NSInteger) lastSelectedIndex
{
    __block NSInteger maxRow = -1;
    [self.selectedIndexes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSIndexPath * path = (NSIndexPath *)obj;
        if (path.row > maxRow) {
            maxRow = path.row;
        }
    }];
    return maxRow;
}



-(void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"did unhighlight...");
}

-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"did highlight");
}

/*- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"should highlight");
    return [[tableView indexPathsForSelectedRows] containsObject:indexPath];
}*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    if (self.doDeselect) {
      [tableView deselectRowAtIndexPath:indexPath animated:YES];
        self.doDeselect = NO;
        NSLog(@"deselecting");
    } else {
       [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        NSLog(@"selecting");
    }
    

    [self updateStateForSelection];
}
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView.indexPathsForSelectedRows containsObject:indexPath]) {
        self.doDeselect = YES;
    }
    return indexPath; 
}
-(void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    [self updateStateForSelection];
    
}

- (IBAction)deleteIntervals:(id)sender {
    
    NSMutableIndexSet * indexSet = [[NSMutableIndexSet alloc] init];
    
    [self.selectedIndexes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSIndexPath * index = (NSIndexPath *)obj;
        [indexSet addIndex:index.row];
        [self.intervalsTable deselectRowAtIndexPath:index animated:NO];

    }];
    [self.model  removeIntervalsAtIndexes:indexSet];
    [self deselectAllRows];
    
}

-(void) deselectAllRows
{
    [[self.intervalsTable indexPathsForSelectedRows]  enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSIndexPath * indexPath = (NSIndexPath *)obj;
        [self.intervalsTable deselectRowAtIndexPath:indexPath animated:NO];
        
    }];
    [self.selectedIndexes removeAllObjects];
}
- (IBAction)repeatIntervals:(id)sender {
    BOOL consecutive = [self selectedIndexesAreConsecutive];
    
    if (consecutive && self.selectedIndexes.count  > 0) {
        NSUInteger location = ((NSIndexPath *) self.selectedIndexes[0]).row;
        NSUInteger length = self.selectedIndexes.count;
        [self.model repeatIntervalsInRange:NSMakeRange(location,length)];
    }
    
}
-(void) setCellInteraction:(BOOL) allowed
{
    [self.intervalsTable.visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UITableViewCell * cell = (UITableViewCell *)obj;
        cell.userInteractionEnabled = allowed;
    }];
         
    
}

-(void) deSelectIndexPath:(NSIndexPath *)indexPath
{
    //[self.selectedIndexes removeObject:indexPath];
    [self.intervalsTable deselectRowAtIndexPath:indexPath animated:NO];
    [self updateStateForSelection];
}

-(void) selectIndexPath:(NSIndexPath *)indexPath
{
    
    [self.intervalsTable selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    //[self.selectedIndexes addObject:indexPath];
    
    [self updateStateForSelection];
}


-(void) presentTimePickerForInterval:(WorkoutInterval *)interval intervalCell:(IntervalCell *)cell
{
    TimePickerVCViewController * timePicker = [[TimePickerVCViewController alloc] initWithNibName:@"TimePickerVCViewController" bundle:nil];
    
    timePicker.interval = interval;
    NSIndexPath * cellIndex = [self.intervalsTable indexPathForCell:cell];
    [self.intervalsTable scrollToRowAtIndexPath:cellIndex atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    NSInteger row = [self.model.intervals indexOfObject:interval];
    
    CGRect rect = [self.intervalsTable rectForRowAtIndexPath: [NSIndexPath indexPathForRow:row inSection:0]];
    timePicker.selectedSeconds  = interval.intervalSeconds;
    timePicker.viewLabel = cell.timeLabel;
    self.presentedTimePicker = timePicker;
    
    timePicker.fromRect = CGRectMake(self.intervalsTable.frame.origin.x+rect.origin.x, [[UIApplication sharedApplication] keyWindow].frame.size.height+50,320,48);
  
    timePicker.intervalNumber = row;
     
    [self presentViewController:timePicker animated:YES completion:^{
        
        
    }]; 
 
}


 




@end
