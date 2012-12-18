//
//  workoutmusicSecondViewController.h
//  WorkoutMusic
//
//  Created by John La Barge on 11/12/12.
//  Copyright (c) 2012 John La Barge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicLibraryTableVC.h"

@interface  CategorizedVC : UIViewController {
    MusicLibraryTableVC * musicLibraryTableVC;
    UISegmentedControl * categoryControl;
    UITableView * tableView; 
    MPMusicPlayerController *musicPlayerController;
}
-(IBAction) categoryChanged;
-(IBAction) playMusic;
-(IBAction) pauseMusic;
-(IBAction) prev;
-(IBAction) next;
@property (nonatomic, retain) IBOutlet MusicLibraryTableVC * musicLibraryTableVC;
@property (nonatomic, retain) IBOutlet UISegmentedControl  * categoryControl;
@property (nonatomic, retain) IBOutlet UITableView * musicTableView;
@property (nonatomic, retain) MPMusicPlayerController * musicPlayerController;

@end
