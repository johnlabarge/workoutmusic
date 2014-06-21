//
//  WOMSelectionBox.m
//  WorkoutMusic
//
//  Created by John La Barge on 6/11/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import "WOMSelectionBox.h"
@interface WOMSelectionBox()
@property (weak, nonatomic) IBOutlet UIView *innerView;

@end
@implementation WOMSelectionBox


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeCustomView];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeCustomView];
    }
    return self;
}



-(void) initializeCustomView {
    NSArray * screens = [[NSBundle mainBundle] loadNibNamed:@"WOMSelectionBox" owner:self options:nil];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:[screens objectAtIndex:0]];
    self.innerView.layer.delegate = self;
    
}

- (IBAction)doSelect:(id)sender {
    
    self.selectedState = !self.selectedState;
    [self.innerView.layer setNeedsDisplay];
    [self.selectDelegate selectionStateChanged:self.selectedState sender:self];
}

-(void) select
{
    self.selectedState = YES;
    [self.innerView.layer setNeedsDisplay];
}

-(void) unselect
{
    self.selectedState = NO;
    [self.innerView.layer setNeedsDisplay];
}

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context{
    if(self.selectedState) {
             CGContextMoveToPoint(context, 0.0, 0.0);
             CGContextSetStrokeColor(context, CGColorGetComponents([UIColor blackColor].CGColor));
             CGContextSetLineWidth(context, 1.0);
             CGContextAddLineToPoint(context,self.innerView.bounds.size.width,self.innerView.bounds.size.height);
             CGContextStrokePath(context);
             CGContextMoveToPoint(context, self.innerView.bounds.size.width, 0.0);
             CGContextAddLineToPoint(context,0.0,self.innerView.bounds.size.height);
             CGContextStrokePath(context);
    } else {
        CGContextSetFillColor(context, CGColorGetComponents([UIColor clearColor].CGColor));
        CGContextFillRect(context, self.innerView.bounds);
    }
}

@end
