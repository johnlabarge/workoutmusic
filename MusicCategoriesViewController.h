//
//  MusicCategoriesViewController.h
//  WorkoutMusic
//
//  Created by John La Barge on 6/7/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OptionDelegate.h"

@interface MusicCategoriesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, OptionDelegate>
@property (weak, nonatomic) IBOutlet UILabel *numberMediumIntensityLabel;
@property (nonatomic, strong) NSString * category; 
@property (weak, nonatomic) IBOutlet UILabel *numberLowIntensityLabel;
@property (weak, nonatomic) IBOutlet UIButton *playListButton;
@property (weak, nonatomic) IBOutlet UILabel *numberHighIntensityLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberVeryHighIntensityLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberUnknownLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOverriddenLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalNumberSongsLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberCantDetermine;

@end
