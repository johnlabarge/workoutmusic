//
//  MusicLibraryTableVC.m
//  WorkoutMusic
//
//  Created by John La Barge on 11/29/12.
//  Copyright (c) 2012 John La Barge. All rights reserved.
//

#import "MusicLibraryTableVC.h"


@interface MusicLibraryTableVC ()

@end

@implementation MusicLibraryTableVC

+(NSArray *) getMusicItems
{
    NSLog(@"Getting music items now..."); 
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    NSLog(@"Logging items from a generic query...");
    NSArray *itemsFromGenericQuery = [everything items];
    for (MPMediaItem *song in itemsFromGenericQuery) {
        NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
        NSLog (@"%@", songTitle);
    }
    return itemsFromGenericQuery;

}



- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    
       
    
    
    return self;
}

- (void) updateMusic
{
    NSManagedObjectContext * moc = [(WOMusicAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    self.library = [[MusicLibraryBPMs alloc] initWithManagedObjectContext:moc];
    [self.library processItunesLibrary:^(MusicLibraryItem *item) {
        NSLog(@"processing item: %@", [item.mediaItem valueForProperty:MPMediaItemPropertyTitle]);
    } afterUpdatingItem:^(MusicLibraryItem *item) {
        NSLog(@"processing item:%@", [item.mediaItem valueForProperty:MPMediaItemPropertyTitle]);
    }];
    [self.library addObserver:self forKeyPath:@"libraryItems" options:0 context:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateMusic]; 
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewDidAppear:(BOOL)animated
{
    /*[[[UIAlertView alloc]
       initWithTitle:@"Music Library Table"
       message:@"This is the Music Library Table"
       delegate:self
       cancelButtonTitle:@"Ok"
      otherButtonTitles: nil] show];
      NSLog(@"Here isa log statement....");*/

}

- (void)observeValueForKeyPath:(NSString *)path ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"observed change..");
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        NSArray * items = self.library.libraryItems;
        return [items count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    SongTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SongTableCell" owner:self options:nil];
    	cell = (SongTableCell *)[nib objectAtIndex:0];
    }
    
    MusicLibraryItem * mlItem = [self.library.libraryItems objectAtIndex:[indexPath indexAtPosition:1]];
    MPMediaItem * song = mlItem.mediaItem;
    
    NSString * titleText = [song valueForProperty:MPMediaItemPropertyTitle];
    if (titleText.length > 15) {
        titleText = [titleText substringToIndex:15];
        titleText = [NSString stringWithFormat:@"%@...",titleText];
    }
   
    cell.title.text = titleText;
  //  cell.bpm.text = [NSString stringWithFormat:@"%d", (int) mlItem.bpm];
    // Configure the cell...
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}



@end
