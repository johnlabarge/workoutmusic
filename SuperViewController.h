//
//  SuperViewController.h
//  WorkoutMusic
//
//  Created by La Barge, John on 3/23/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WOMusicAppDelegate.h"
#import "WorkoutLIst.h"
#import "MusicLibraryBPMs.h"

typedef  NSString * (^getobjwithname)(NSString * name);

@interface SuperViewController : UIViewController {
    getobjwithname fromNib;
}

@property (readonly, weak) WOMusicAppDelegate * app;
@property (readonly, weak) WorkoutList * workoutlist;
@property (readonly, weak) MusicLibraryBPMs * musicBPMLibrary; 
@end
