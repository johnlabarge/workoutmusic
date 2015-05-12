//
//  WOMMediaReclassifiedView.h
//  WorkoutMusic
//
//  Created by John La Barge on 6/8/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicLibraryBPMs.h"
@interface WOMMediaReclassifiedViewController : UIViewController
@property (nonatomic, assign) NSInteger classification;
@property (nonatomic, strong) MusicLibraryItem *musicItem;
-(void) show:(UIView *)superView;
@end
