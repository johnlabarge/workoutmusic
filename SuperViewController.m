//
//  SuperViewController.m
//  WorkoutMusic
//
//  Created by La Barge, John on 3/23/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import "SuperViewController.h"

@interface SuperViewController ()

@end

@implementation SuperViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
   
    __block SuperViewController * me = self;
    NSBundle * bundle = (nibBundleOrNil == nil? [NSBundle mainBundle] : nibBundleOrNil);
     fromNib = ^(NSString * name) { NSArray *nib = [bundle
                                loadNibNamed:name
                                              owner:me
                                options:nil];
        return [nib objectAtIndex:0];
    };
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(WorkoutList *) workoutlist
{
    return self.app.workout;
}

-(MusicLibraryBPMs *) musicBPMLibrary
{
    return self.app.musicBPMLibrary;
}
-(WOMusicAppDelegate *) app
{
    return [UIApplication sharedApplication].delegate;
}




@end
