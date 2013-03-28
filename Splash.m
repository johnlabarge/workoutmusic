//
//  Splash.m
//  roshambo
//
//  Created by La Barge, John on 2/7/13.
//  Copyright (c) 2013 La Barge, John. All rights reserved.
//

#import "Splash.h"

@interface Splash ()

@end

@implementation Splash
@synthesize image;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
        [super viewDidLoad];
	
       
  
}
- (void)viewDidUnload
{
    [super viewDidUnload];
   }
-(void) afterSplash
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"workoutmusic" bundle:nil];
    [self performSegueWithIdentifier:@"splashOut" sender:self];

    /*UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"workoutmusic" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
    WOMusicAppDelegate *  appDelegate = [UIApplication sharedApplication].delegate;
    NSLog(@" afterSplash...");
    [appDelegate.transitionController performSelectorOnMainThread:@selector(transitionToViewController:) withObject:vc waitUntilDone:NO];*/
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
