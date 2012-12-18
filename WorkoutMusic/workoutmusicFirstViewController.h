//
//  workoutmusicFirstViewController.h
//  WorkoutMusic
//
//  Created by John La Barge on 11/12/12.
//  Copyright (c) 2012 John La Barge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicLibraryTableVC.h"

@interface workoutmusicFirstViewController : UIViewController {
   
    IBOutlet MusicLibraryTableVC * songListTableController;

}
@property (nonatomic, retain) IBOutlet MusicLibraryTableVC * songListTableController;
@end
