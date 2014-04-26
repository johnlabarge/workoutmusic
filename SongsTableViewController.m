//
//  SongsTableViewController.m
//  WorkoutMusic
//
//  Created by John La Barge on 2/27/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import "SongsTableViewController.h"
#import "IntervalSectionCell.h"
#import "SongjockeySong.h"
#import "WorkoutList.h"
#import "SongTableCell.h"

@interface SongsTableViewController ()

@end

@implementation SongsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];


    UINib * intervalCell = [UINib  nibWithNibName:@"SongTableCell" bundle:nil];
    [self.tableView registerNib:intervalCell forCellReuseIdentifier:@"songTableCell"];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    UINib * headerCell = [UINib nibWithNibName:@"IntervalSectionCell" bundle:nil];
    [self.tableView registerNib:headerCell
         forCellReuseIdentifier:@"sectionCell"];

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
    
    NSInteger songCount = [self.workoutList numberOfSongsPerInterval:section];
    NSLog(@"%d songs for interval %d", songCount, section);
    return songCount+1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WorkoutListItem * item  = (WorkoutListItem *)[self.workoutList.workoutListItems objectAtIndex:indexPath.section];
    UITableViewCell * cell;
    
    if (indexPath.row == 0) {
        IntervalSectionCell * sectionCell = (IntervalSectionCell *) [tableView dequeueReusableCellWithIdentifier:@"sectionCell" forIndexPath:indexPath];
        sectionCell.title.text = [tableView.dataSource tableView:tableView titleForHeaderInSection:indexPath.section];
        cell = sectionCell;
        
    } else {
        NSLog(@"getting song cell");
        SongJockeySong * song = (SongJockeySong *) [item.songs objectAtIndex:indexPath.row-1];
        
        SongTableCell * songCell = (SongTableCell *)[tableView dequeueReusableCellWithIdentifier:@"songTableCell" forIndexPath:indexPath];
        songCell.tempoClass.text = item.speedDescription;
        
        MPMediaItemArtwork * artwork = [song.mediaItem valueForProperty:MPMediaItemPropertyArtwork];
        UIImage *albumArtworkImage = [artwork imageWithSize:CGSizeMake(100.0, 100.0)];
        songCell.artworkImage = albumArtworkImage;
        songCell.time.text = [NSString stringWithFormat:@"%d", item.workoutInterval.intervalSeconds];
        cell = songCell;
    }
    return cell;
    
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Interval %d - %@",section, [Tempo speedDescription:((WorkoutInterval *)[self.workout.intervals objectAtIndex:section]).speed]];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 40.0f;
    }
    return 100.0f;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
