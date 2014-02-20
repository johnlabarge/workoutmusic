//
//  SecondsPickerVCViewController.m
//  WorkoutMusic
//
//  Created by La Barge, John on 11/6/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import "SecondsPickerVCViewController.h"

@interface SecondsPickerVCViewController ()
@property (nonatomic,strong) NSArray *secondsArray;


@end

@implementation SecondsPickerVCViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    NSMutableArray *secondsArray;
    for (int i=0; i < 60; i++) {
        [secondsArray addObject:[NSString stringWithFormat:@"%d", (i+1)*10]];
    }
    self.secondsArray = secondsArray;
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
