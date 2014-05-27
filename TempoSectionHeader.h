//
//  TempoSectionHeader.h
//  WorkoutMusic
//
//  Created by John La Barge on 5/26/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableSectionExpansionDelegate.h"
@interface TempoSectionHeader : UITableViewHeaderFooterView
@property (weak, nonatomic) IBOutlet UILabel *sectionNameLabel;
@property (weak, nonatomic) id<TableSectionExpansionDelegate> expansionDelegate;
@property (nonatomic, assign) NSUInteger sectionNumber;
@property (nonatomic, weak) IBOutlet UIButton * expansionButton;
@property (nonatomic, assign) BOOL expansionState;
@end
