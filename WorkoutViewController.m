//
//  WorkoutViewController.m
//  WorkoutMusic
//
//  Created by John La Barge on 11/30/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//
#import "WorkoutList.h"
#import "WorkoutViewController.h"
#import "WorkoutListItem.h"
#import "SongTableCell.h"
#import "SongInstruction.h"
@interface WorkoutViewController ()

@end

@implementation WorkoutViewController

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
    UINib * intervalCell = [UINib  nibWithNibName:@"SongTableCell" bundle:nil];
    [self.songTable registerNib:intervalCell forCellReuseIdentifier:@"songTableCell"];
    
    self.workoutList = [WorkoutList sharedInstance];
    [self.spinner startAnimating];
    self.spinner.hidesWhenStopped = YES;
    __weak typeof(self) me;
    [self.workoutList generateListForWorkout:self.workout afterGenerated:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [me.spinner stopAnimating];
            [me.songTable reloadData];
        });

    }];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.workout.intervals.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.workoutList songInstructionsForInterval:section].count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WorkoutListItem * item  = (WorkoutListItem *)[self.workoutList.workoutListItems objectAtIndex:indexPath.section];
    SongInstruction * instruction = (SongInstruction *) [ item.songInstructions objectAtIndex:indexPath.row];
    
    SongTableCell * cell = (SongTableCell *)[tableView dequeueReusableCellWithIdentifier:@"songTableCell" forIndexPath:indexPath];
    cell.tempoClass.text = item.speedDescription;
    
    MPMediaItemArtwork * artwork = [instruction.musicItem.mediaItem valueForProperty:MPMediaItemPropertyArtwork];
    UIImage *albumArtworkImage = [artwork imageWithSize:CGSizeMake(100.0, 100.0)];
    cell.artworkImage = albumArtworkImage;
    cell.time.text = [NSString stringWithFormat:@"%d", item.workoutInterval.intervalSeconds];
    return cell;

}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Interval %d",section];
}


@end
