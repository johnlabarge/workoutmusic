//
//  TimeLabel.m
//  WorkoutMusic
//
//  Created by John La Barge on 11/11/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import "TimeLabel.h"
@interface TimeLabel()
@property (nonatomic, strong) NSDateFormatter * myDateFormatter;

@end

@implementation TimeLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self setup];
    return self;
}
-(void) setup
{
    self.myDateFormatter = [[NSDateFormatter alloc] init];
    [self.myDateFormatter setDateFormat:@"mm:ss"];
    
   
}

-(void) setSeconds:(NSInteger) seconds
{
    NSLog(@"set seconds to: %@",@(seconds));
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger minutes = _seconds/60;
    comps.minute = minutes;
    comps.second = seconds;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *periodDate = [calendar dateFromComponents:comps];

    self.text = [self.myDateFormatter stringFromDate:periodDate];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
