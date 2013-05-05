//
//  WorkoutGraph.m
//  WorkoutGraphic
//
//  Created by La Barge, John on 3/29/13.
//  Copyright (c) 2013 La Barge, John. All rights reserved.
//

#import "WorkoutGraph.h"
#import "MusicLibraryBPMs.h"

@interface WorkoutGraph ()
@property (nonatomic, assign) NSInteger animateInterval;
@property (nonatomic, assign) NSTimer * animateTimer;
@end

@implementation WorkoutGraph

-(void) setIntervals:(NSArray *) array {
    NSLog(@"setting intervals to array of size %d",array.count);
    _intervals = array;
    [self setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return self;
    
}

CGColorRef getAdjustedColor(CGColorRef inColor, float adjustment) {
    CGFloat * components = (CGFloat *)  CGColorGetComponents(inColor);
 
    float adjustedComponents[4];
    for (int i= 0; i < 3; i++) {
        adjustedComponents[i] = components[i]+adjustment;
    }
    adjustedComponents[3] = CGColorGetAlpha(inColor);
    return CGColorCreate(CGColorGetColorSpace(inColor),adjustedComponents );
}


void createBar(CGContextRef context, CGFloat x,CGFloat y,CGFloat width, CGFloat height, CGColorRef color) {
    
   
    //create left edge
    CGContextSetAllowsAntialiasing(context, true); 
    CGFloat adjustment = 0.2f;
    CGFloat edgeWidth = width*0.1;
    CGColorRef topGradient = getAdjustedColor(color, 0.15f);
    CGColorRef lowGradient = color;
    
    edgeWidth = (CGFloat)ceil( edgeWidth * 100.0 ) / 100.0;
    
    CGFloat barWidth = width - 2*edgeWidth;
    CGFloat barHeight = height - 1*edgeWidth;
    
    
    CGRect leftEdgeRectangle = CGRectMake(x,y, edgeWidth,barHeight+edgeWidth);
    CGRect middleRectangle = CGRectMake(x+edgeWidth,y+edgeWidth,barWidth,barHeight);
    CGRect topRectangle = CGRectMake(x+edgeWidth,y,barWidth, edgeWidth);
    CGRect rightEdgeRectangle = CGRectMake(x+edgeWidth+barWidth, y+edgeWidth, edgeWidth, barHeight);
    
    CGContextSetFillColorWithColor(context, getAdjustedColor(color, adjustment));
    CGContextSetStrokeColorWithColor(context, getAdjustedColor(color, adjustment)); 
    CGContextFillRect(context,leftEdgeRectangle);
    CGContextStrokeRect(context, leftEdgeRectangle);
    
   // CGContextSetFillColorWithColor(context, color);
   // CGContextStrokeRect(context, middleRectangle);
    
    NSArray * gradientColors = @[(__bridge id)topGradient,(__bridge id)lowGradient];
    CGFloat locations[2] = {0.0,1.0}; 
    CGGradientRef gradient = CGGradientCreateWithColors(CGColorGetColorSpace(color), (__bridge CFArrayRef)(gradientColors), locations);
    
    CGContextSaveGState(context);
    //CGContextAddEllipseInRect(context, middleRectangle);
    CGContextAddRect(context, middleRectangle);
    CGContextClip(context);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(middleRectangle), CGRectGetMinY(middleRectangle));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(middleRectangle), CGRectGetMaxY(middleRectangle));
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    
    CGContextRestoreGState(context);

    
    //CGContextDrawLinearGradient(context, gradient, CGPointMake(x+edgeWidth,y+edgeWidth), CGPointMake(x+edgeWidth+barWidth,barHeight),  kCGGradientDrawsAfterEndLocation);
  //  CGContextSetFillColorWithColor(context, middleGradient);
    
    CGColorRef topEdgeColor = getAdjustedColor(color, adjustment);
    CGContextSetFillColorWithColor(context, topEdgeColor);
    CGContextSetStrokeColorWithColor(context, topEdgeColor);
    
    CGContextFillRect(context, topRectangle);
    CGContextStrokeRect(context, topRectangle);
    
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
    CGContextStrokeRect(context,rightEdgeRectangle);
    CGContextFillRect(context, rightEdgeRectangle);
    
    // rightEdgeColor = getAdjustedColor(color,0-2*adjustment);
   // CGContextSetFillColorWithColor(context, color);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, x+edgeWidth+barWidth,y+edgeWidth);
    CGContextAddLineToPoint(context, x+edgeWidth+barWidth+edgeWidth+0.5, y+edgeWidth);
    CGContextAddLineToPoint(context, x+edgeWidth+barWidth+edgeWidth+0.5, y-0.5);
    CGContextAddLineToPoint(context, x+edgeWidth+barWidth, y+edgeWidth);
    
    CGContextClosePath(context);
    CGContextFillPath(context);
    CGContextSetLineWidth(context, 1.2f);
   //CGContextSetStrokeColorWithColor(context, color);
   CGContextStrokePath(context);
   // CGContextFillRect(context,rightEdgeRectangle);
    /*CGContextMoveToPoint(context, 0, 0);
    
    CGContextAddLineToPoint(context, 0, 50);
    CGContextAddLineToPoint(context, 50, 0);
    CGContextAddLineToPoint(context, 0,0);*/

   // CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
   //CGContextStrokePath(context);
    
    



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

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (self.intervals && self.intervals.count > 0) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGFloat edgeWidth = 10.0; 
        CGFloat lineWidth = (rect.size.width-6)/self.intervals.count;
        CGFloat graphicHeight = rect.size.height;
        CGFloat graphicHeightSegment = graphicHeight/4;
        
        NSDictionary * lineHeights = @{
    SLOW: [NSNumber numberWithFloat:graphicHeightSegment],
    MEDIUM:[NSNumber numberWithFloat:graphicHeightSegment*2],
    MEDIUMFAST:[NSNumber numberWithFloat:graphicHeightSegment*3],
    FAST: [NSNumber numberWithFloat:graphicHeightSegment*4]};
        
      

        int hoff = 3;
        int voff = 3;
          
        CGContextSetFillColorWithColor(context, getAdjustedColor([UIColor blackColor].CGColor, 0.05f));
        CGContextFillRect(context, rect);
        self.backgroundColor = [UIColor blackColor];
        __block WorkoutGraph * me = self;
        CGFloat space = self.frame.size.width/45;
        space = 0.0;
        [self.intervals enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            CGColorRef theColor = [UIColor lightGrayColor].CGColor;
            NSDictionary * interval = (NSDictionary *) obj;
            NSNumber * lineHeightN = [lineHeights objectForKey:[interval objectForKey:TEMPO]];
            if (me.currentInterval != idx) {
           
                 createBar(context, idx*(lineWidth+space)+hoff, (rect.size.height - lineHeightN.floatValue)+voff, lineWidth, lineHeightN.floatValue+voff, theColor);
            } else {
                if (me.animateInterval == 0) {
                    theColor = [UIColor orangeColor].CGColor;
                    createBar(context, idx*(lineWidth+space)+hoff, (rect.size.height - lineHeightN.floatValue)+voff, lineWidth, lineHeightN.floatValue+voff, theColor);
                }
            }
           
                       
           
            
            
            
        }];
        
        
    }
    
    
}

@end
