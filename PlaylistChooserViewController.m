//
//  PlaylistChooserViewController.m
//  SongJockey
//
//  Created by John La Barge on 1/19/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import "PlaylistChooserViewController.h"
#import "SJPlaylists.h"

@interface PlaylistChooserViewController ()

@end

@implementation PlaylistChooserViewController

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

    self.okButton.enabled = NO;
#if TARGET_IPHONE_SIMULATOR
    self.okButton.enabled = YES;
#endif

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark UIPickerViewDataSource

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [SJPlaylists availablePlaylists].count ;
}
#pragma mark UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[SJPlaylists availablePlaylists] objectAtIndex:row];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if ([SJPlaylists availablePlaylists].count > row) {
        self.selectedPlaylist = [[SJPlaylists availablePlaylists] objectAtIndex:row];
        self.okButton.enabled = YES;
    }
}
@end
