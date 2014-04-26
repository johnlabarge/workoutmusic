//
//  WorkoutGraph.m
//  WorkoutGraphic
//
//  Created by La Barge, John on 3/29/13.
//  Copyright (c) 2013 La Barge, John. All rights reserved.
//

#import "WorkoutGraph.h"
#import "WorkoutInterval.h"
#import "Workout.h"
@interface WorkoutGraph ()
@property (nonatomic, assign) NSInteger animateInterval;
@property (nonatomic, assign) NSTimer * animateTimer;
@property (nonatomic, strong) UIColor * defaultColor;
@property (nonatomic, strong) UIColor * activeColor;
@end

@implementation WorkoutGraph

-(void) initProperties
{
    self.defaultColor = [UIColor colorWithRed:170/255.0 green:214/255.0 blue:250/255.0 alpha:1.0];
    self.activeColor = [UIColor colorWithRed:67/255.0 green:250/255.0 blue:71/255.0 alpha:1.0];
}
-(void) setWorkout:(Workout *) workout {
    _workout = workout;
    self.intervals = workout.intervals;
    
}
-(void) setIntervals:(NSArray *) array {
    NSLog(@"setting intervals to array of size %d",array.count);
    _intervals = array;
    [self setNeedsDisplay];
}


-(void) reloadData
{
    [self setNeedsDisplay]; 
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initProperties];
        // Initialization code
        
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self initProperties];
    return self;
    
}

CGColorRef getAdjustedColor(CGColorRef inColor, float adjustment) {
    CGFloat * components = (CGFloat *)  CGColorGetComponents(inColor);
 
    CGFloat adjustedComponents[4];
    for (int i= 0; i < 3; i++) {
        adjustedComponents[i] = components[i]+adjustment;
    }
    adjustedComponents[3] = CGColorGetAlpha(inColor);
    
    return CGColorCreate(CGColorGetColorSpace(inColor),adjustedComponents );
}


void createBar2(CGContextRef context, CGFloat x, CGFloat y, CGFloat width, CGFloat height, CGColorRef color)
{

}

void createBar(CGContextRef context, CGFloat x,CGFloat y,CGFloat width, CGFloat height, CGColorRef color) {
    
   
    //create left edge
    CGContextSetAllowsAntialiasing(context, true); 
    CGFloat adjustment = 0.2f;
    CGFloat edgeWidth = 0;
    CGColorRef topGradient = getAdjustedColor(color, 0.15f);
    CGColorRef lowGradient = color;
    
    edgeWidth = (CGFloat)ceil( edgeWidth * 100.0 ) / 100.0;
    
    CGFloat barWidth = width - 2*edgeWidth;
    CGFloat barHeight = height - 1*edgeWidth;
    
    
     CGRect middleRectangle = CGRectMake(x+edgeWidth,y+edgeWidth,barWidth,barHeight);

    
    CGContextSetFillColorWithColor(context, getAdjustedColor(color, adjustment));
    CGContextSetStrokeColorWithColor(context, getAdjustedColor(color, adjustment)); 

    
    NSArray * gradientColors = @[(__bridge id)topGradient,(__bridge id)lowGradient];
    CGFloat locations[2] = {0.0,1.0}; 
    CGGradientRef gradient = CGGradientCreateWithColors(CGColorGetColorSpace(color), (__bridge CFArrayRef)(gradientColors), locations);
    
    CGContextSaveGState(context);

    CGContextAddRect(context, middleRectangle);
    CGContextClip(context);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(middleRectangle), CGRectGetMinY(middleRectangle));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(middleRectangle), CGRectGetMaxY(middleRectangle));
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    
    CGContextRestoreGState(context);


    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, x+edgeWidth+barWidth,y+edgeWidth);
    CGContextAddLineToPoint(context, x+edgeWidth+barWidth, y-0.5);
    CGContextAddLineToPoint(context, x+edgeWidth+barWidth+edgeWidth+0.5, y-0.5);
    CGContextAddLineToPoint(context, x+edgeWidth+barWidth,y+edgeWidth);
    CGContextClosePath(context);
    CGContextFillPath(context);
    CGContextStrokePath(context);
    
    CGColorRef rightEdgeColor = getAdjustedColor(color,0-adjustment);
    CGContextSetFillColorWithColor(context, rightEdgeColor);
    CGContextSetStrokeColorWithColor(context, rightEdgeColor);

    CGContextBeginPath(context);
    CGContextMoveToPoint(context, x+edgeWidth+barWidth,y+edgeWidth);
    CGContextAddLineToPoint(context, x+edgeWidth+barWidth+edgeWidth+0.5, y+edgeWidth);
    CGContextAddLineToPoint(context, x+edgeWidth+barWidth+edgeWidth+0.5, y-0.5);
    CGContextAddLineToPoint(context, x+edgeWidth+barWidth, y+edgeWidth);
    
    CGContextClosePath(context);
    CGContextFillPath(context);
    CGContextSetLineWidth(context, 1.2f);

   CGContextStrokePath(context);

    



}

-(void) startAnimate
{
    [self stopAnimate];
    self.animateTimer =  [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(animate) userInfo:nil repeats:YES];
}

-(void) stopAnimate
{
    [self.animateTimer invalidate];
    self.animateTimer=  nil;
}

-(void) animate
{
    self.animateInterval = (self.animateInterval == 1?0:1);
    [self setNeedsDisplay];
}


-(CGFloat) totalWidth:(CGRect)rect
{
     return(rect.size.width-6);
}
-(CGFloat) pixelsPerSecond:(CGRect)rect
{
    return [self totalWidth:rect]/self.workout.workoutSeconds;

}
-(CGFloat) intervalWidth:(CGRect)rect interval:(WorkoutInterval *)interval {
    CGFloat pixelsPerSecond = [self pixelsPerSecond:rect];
        return (pixelsPerSecond* interval.intervalSeconds);
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    
    if (self.intervals && self.intervals.count > 0) {
        CGContextRef context = UIGraphicsGetCurrentContext();
       
        CGFloat graphicHeight = rect.size.height;
        CGFloat graphicHeightSegment = graphicHeight/4;
        
        NSDictionary * lineHeights = @{
    SLOWINTERVAL: [NSNumber numberWithFloat:graphicHeightSegment],
    MEDIUMINTERVAL:[NSNumber numberWithFloat:graphicHeightSegment*2],
    FASTINTERVAL:[NSNumber numberWithFloat:graphicHeightSegment*3],
    VERYFASTINTERVAL: [NSNumber numberWithFloat:graphicHeightSegment*4]};
        
      

        int hoff = 3;
        int voff = 3;
          
        CGContextSetFillColorWithColor(context, getAdjustedColor(self.backgroundColor.CGColor, 0.05f));
        CGContextFillRect(context, rect);
        //self.backgroundColor =  self.view.backgroundColor;
        __block WorkoutGraph * me = self;
        CGFloat space = self.frame.size.width/45;
        space = 0.0;
        __block NSInteger currentXPos =hoff;
        
        [self.intervals enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
   
            WorkoutInterval * interval = (WorkoutInterval *) obj;
           
            NSNumber * lineHeightN = [lineHeights objectForKey:[interval representation]];
            
            CGFloat lineWidth = [self intervalWidth:rect interval:interval];
            
            if (!self.active || me.currentInterval != idx) {
                 createBar(context, currentXPos+space, (rect.size.height - lineHeightN.floatValue)+voff, lineWidth, lineHeightN.floatValue+voff, self.defaultColor.CGColor);
            } else {
                if (me.animateInterval == 0) {
                    CGColorRef activeColor = self.activeColor.CGColor;
                    
                    
                    createBar(context, currentXPos+space, (rect.size.height - lineHeightN.floatValue)+voff, lineWidth, lineHeightN.floatValue+voff, activeColor);
                }
            }
           
            currentXPos+=lineWidth;
            
        }];
        
        
    }
    
    
}

@end
