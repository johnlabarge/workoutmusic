//
//  TimePickerVCViewController.m
//  WorkoutMusic
//
//  Created by John La Barge on 11/11/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import "TimePickerVCViewController.h"
#import "FXBlurView.h"
#import "ModalTransitioningControllerDelegate.h"

@interface TimePickerVCViewController ()
@property (nonatomic, strong) NSArray * minuteOptions;
@property (nonatomic, strong) NSMutableArray * secondsOptions;
@property (nonatomic, strong) NSMutableArray * timeLabels;
@property (nonatomic, strong) ModalTransitioningControllerDelegate * modalPresenter;
@end

@implementation TimePickerVCViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setup];
        // Custom initialization
    }
    return self;
}
-(id) initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    [self setup];
    return self;
}

 
-(void) setup {
    
    self.minuteOptions = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7", @"8", @"9",@"10"];
    self.secondsOptions = [[NSMutableArray alloc] initWithCapacity:60];

    for (int i=0; i< 60; i++) {
        NSString * secondsOption;
        if (i < 10) {
            secondsOption  = [NSString stringWithFormat:@"0%@",@(i)];
        } else {
            secondsOption  = @(i).stringValue;
        }
        [self.secondsOptions addObject:secondsOption];
    }

        self.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioningDelegate = self;

    
  
}

-(void) setFromRect:(CGRect)fromRect
{
    _fromRect = fromRect;
    self.modalPresenter.fromRect = _fromRect;
}
-(void)viewDidAppear:(BOOL)animated {
    
}
- (IBAction)doneAction:(id)sender {
    self.interval.intervalSeconds = 60*([self.timePicker selectedRowInComponent:0]);
    self.interval.intervalSeconds+= [self.timePicker selectedRowInComponent:1];
    NSLog(@"new interval seconds = %ld", (long)self.interval.intervalSeconds);
    [self dismissViewControllerAnimated:YES completion:nil];

}
-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 60.0;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // self.blurView.frame = [UIApplication sharedApplication].keyWindow.frame;
    //self.view.frame = CGRectMake(self.view.frame.origin.x,self.view.frame.origin.y, self.view.frame.size.width, self.blurView.frame.size.height);
    //self.view.frame = self.blurView.frame;
    
    self.timePicker.showsSelectionIndicator = YES;
   NSInteger minutes = self.interval.intervalSeconds/60;
    NSInteger seconds = self.interval.intervalSeconds-(minutes*60);
    [self.timePicker selectRow:minutes inComponent:0 animated:NO];
    [self.timePicker selectRow:seconds inComponent:1 animated:NO];
    
    
    self.timePicker.delegate = self;
    self.timePicker.dataSource =self;
    self.titleLabel.text = [NSString stringWithFormat:@"%@ %@",self.titleLabel.text, @(self.intervalNumber+1)];
    self.blurView.alpha = 1.0;
    self.blurView.blurRadius = 12;
    // Do any additional setup after loading the view from its nib.
}

-(void) viewWillAppear:(BOOL)animated
{
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.timePicker attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.7 constant:1.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.timePicker attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:1.0]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    
    return [self.timeLabels objectAtIndex:row];
}*/

-(UILabel *) labelFor:(NSString *)text
{
    UILabel * label = [[UILabel alloc] init];
    label.font= [UIFont systemFontOfSize:15.0];
    label.text = text;
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
 //   NSLog(@"number of rows :%lu",(unsigned long)self.timeOptions.count);
  //  NSLog(@"did select row");
   //  self.selectedSeconds = ([self.timePicker selectedRowInComponent:0]+1)*10;
    //[self.blurView removeFromSuperview];
   
    
}
-(void)viewWillLayoutSubviews
{
    
   
}
- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    if (component == 0) {
        return self.minuteOptions[row];
    }
    return self.secondsOptions[row];
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel * label = (UILabel *)view;
    
    if (!label) {
        label = [[UILabel alloc] init];
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:20.0];
    }
    
    if (component == 0) {
        if (row == 0) {
            
            //label.font = [label.font fontWithSize:12.0];
            label.text = [NSString stringWithFormat:@"%@ Min",self.minuteOptions[row]];
        } else {
            label.text =  self.minuteOptions[row];
        }
    } else {
        if (row == 0){
           // label.font = [label.font fontWithSize:12.0];
             label.text = [NSString stringWithFormat:@"%@ Sec",self.minuteOptions[row]];
        } else {
            label.text = self.secondsOptions[row];
        }
    }
    return label;
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return self.minuteOptions.count;
    } else {
        return self.secondsOptions.count;
    }
    
}

 
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40.0;
}

#pragma mark UIViewControllerTransitionDelegate
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

// This is used for percent driven interactive transitions, as well as for container controllers that have companion animations that might need to
// synchronize with the main animation.
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}
// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController * toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController * fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    BOOL presenting = (toViewController == self);
    __weak typeof(self) weakSelf = self;
    if (presenting) {
        
        
        
        //[[transitionContext containerView] addSubview:fromViewController.view];
        
        fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        self.blurView.frame = self.fromRect;
        [[transitionContext containerView] addSubview:self.blurView];
        [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:0.25 initialSpringVelocity:4.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                weakSelf.blurView.frame = CGRectMake(0,fromViewController.view.frame.size.height*.5,fromViewController.view.bounds.size.width, fromViewController.view.bounds.size.height*.4);
            
        } completion:^(BOOL finished) {
            
            [transitionContext completeTransition:YES];
            [weakSelf.blurView addSubview: weakSelf.view];
        }];
   
        
    } else {
        [weakSelf.view removeFromSuperview];
        [UIView animateWithDuration:0.25 animations:^{
            
            weakSelf.blurView.frame = weakSelf.fromRect;
            toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
        } completion:^(BOOL finished) {
            [weakSelf.blurView removeFromSuperview];
            [transitionContext completeTransition:YES];
        }];
        
    }
}
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self;
}
@end
