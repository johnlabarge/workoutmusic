//
//  workoutmusicViewController.h
//  WorkoutMusic
//
//  Created by La Barge, John on 4/1/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"

@interface ListPickerViewController: SuperViewController
@property (nonatomic, strong) IBOutlet UIPickerView * playListPicker;
@property (nonatomic, strong) IBOutlet UITableView * tableView;
@property (nonatomic, strong) IBOutlet UIProgressView * progressView;
@end
