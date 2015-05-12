//
//  WOMMediaReclassifiedView.m
//  WorkoutMusic
//
//  Created by John La Barge on 6/8/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import "WOMMediaReclassifiedViewController.h"
#import "WOMusicAppDelegate.h"
@interface WOMMediaReclassifiedViewController()
@property (strong, nonatomic) IBOutlet UILabel *artistLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *viewTitle;
@property (strong, nonatomic) IBOutlet UIImageView *artImageView;
@property (nonatomic, strong) NSLayoutConstraint * offScreenLayout;
@property (nonatomic, strong) NSLayoutConstraint * onScreenLayout;

@end
@implementation WOMMediaReclassifiedViewController


-(void)viewDidLoad {
    self.artistLabel.text = self.musicItem.artist;
    self.titleLabel.text = @"poo";
    self.titleLabel.text  = self.musicItem.title;
    self.artImageView.image = [self.musicItem.artwork imageWithSize:CGSizeMake(60,60)];
    self.viewTitle.text = [NSString stringWithFormat:@"Reclassified as %@",[Tempo intensities][self.classification]];
    
    
}
@end
