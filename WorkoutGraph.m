//
//  WorkoutGraph.m
//  WorkoutGraphic
//
//  Created by La Barge, John on 3/29/13.
//  Copyright (c) 2013 La Barge, John. All rights reserved.
//
//TODO: Doxygen!

#import "WorkoutGraph.h"
#import "WorkoutInterval.h"
#import "Workout.h"
@interface WorkoutGraph ()
@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, strong) UIColor * defaultColor;
@property (nonatomic, strong) UIColor * activeColor;
@property (nonatomic, assign) CGFloat horizontalOffset;
@property (nonatomic, strong) CALayer * activeLayer;
@property (nonatomic, strong) CABasicAnimation * activeLayerAnimation;
@end

@implementation WorkoutGraph

-(void) initProperties
{
    /*
     * hardcoded colors for now
     */
    self.defaultColor = [UIColor colorWithRed:170/255.0 green:214/255.0 blue:250/255.0 alpha:1.0];
    self.activeColor = [UIColor colorWithRed:67/255.0 green:250/255.0 blue:71/255.0 alpha:1.0];
    self.horizontalOffset = 3;
    self.layer.delegate = self;
}

/*
 * originally this represented a list of intervals, now simply representing the whole workout
 */
-(void) setWorkout:(Workout *) workout {
    _workout = workout;
    [self setNeedsDisplay];
}

-(void) setCurrentInterval:(NSInteger)interval
{
    _currentInterval = interval;
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
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self initProperties];
    return self;
    
}

-(void) startAnimate
{
    if (!self.activeLayerAnimation) {
        [self createFadeAnimation];
    }
    if (self.activeLayer.animationKeys.count < 1) {
        [self.activeLayer addAnimation:self.activeLayerAnimation forKey:@"opacity"];
    }
    self.isAnimating = YES;

}

-(void) stopAnimate
{
    [self.activeLayer removeAllAnimations];
    self.isAnimating = NO;
}



-(CGFloat) totalWidth:(CGRect)rect
{
    return(rect.size.width-2*self.horizontalOffset);
}
-(CGFloat) pixelsPerSecond:(CGRect)rect
{
    return [self totalWidth:rect]/self.workout.workoutSeconds;
    
}
-(CGFloat) intervalWidth:(CGRect)rect interval:(WorkoutInterval *)interval {
    CGFloat pixelsPerSecond = [self pixelsPerSecond:rect];
    return (pixelsPerSecond*interval.intervalSeconds);
}

-(void) createFadeAnimation
{
    CABasicAnimation * fadeAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnim.fromValue = @1.0;
    fadeAnim.toValue = @0.0;
    fadeAnim.duration = 0.8;
    self.activeLayerAnimation = fadeAnim;
}

-(CALayer *) createActiveBarLayerAt:(CGFloat)x y:(CGFloat)y Width:(CGFloat)width Height:(CGFloat)height
{
    CALayer * activebarLayer = [CALayer layer];
    activebarLayer.frame = CGRectMake(x, y, width, height);
    activebarLayer.backgroundColor = self.activeColor.CGColor;
    return activebarLayer;
}
-(void) drawLayer:(CALayer *)theLayer inContext:(CGContextRef)context {
    
    if (self.workout && self.workout.intervals && self.workout.intervals.count > 0) {
        [self.activeLayer removeFromSuperlayer];
        CGRect rect = self.layer.frame;
        CGFloat graphicHeight = rect.size.height;
        CGFloat graphicHeightSegment = graphicHeight/4;
        
        NSDictionary * lineHeights = @{
                                       SLOWINTERVAL: @(graphicHeightSegment),
                                       MEDIUMINTERVAL:@(graphicHeightSegment*2),
                                       FASTINTERVAL:@(graphicHeightSegment*3),
                                       VERYFASTINTERVAL: @(graphicHeightSegment*4)};
        
        
        
        
        CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
        CGContextFillRect(context, theLayer.bounds);
        
        CGFloat space = self.horizontalOffset/self.workout.intervals.count;
        __block CGFloat currentXPos =space;
        __block CGFloat activeBarX;
        __block CGFloat activeBarY;
        __block CGFloat activeBarWidth;
        __block CGFloat activeBarHeight;
        __weak typeof(self) weakSelf = self;
        
        [self.workout.intervals enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            WorkoutInterval * interval = (WorkoutInterval *) obj;
            
            NSNumber * lineHeightN = lineHeights[[interval representation]];
            
            CGFloat lineWidth = [weakSelf intervalWidth:rect interval:interval];
            
            createBar(context, currentXPos+space, (rect.size.height - lineHeightN.doubleValue), lineWidth, lineHeightN.doubleValue, weakSelf.defaultColor.CGColor);
            /*
             * capture the active interval
             */
            if (weakSelf.currentInterval == idx) {
                activeBarX = currentXPos;
                activeBarY = rect.size.height - lineHeightN.doubleValue;
                activeBarHeight = lineHeightN.doubleValue;
                activeBarWidth = lineWidth;
            }
            
            currentXPos+=lineWidth+space;
            
        }];

        if (self.active) {

            self.activeLayer = [self createActiveBarLayerAt:activeBarX  y:activeBarY Width:activeBarWidth Height:activeBarHeight];
            [theLayer addSublayer:self.activeLayer];
            /*
             * if we already were animating start animating again.
             */
            if (self.isAnimating) {
                [self startAnimate];
            }
        }
        
        
        
        
    }
}
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
}
void createBar(CGContextRef context, const CGFloat x, const CGFloat y, const CGFloat width, const CGFloat height, const CGColorRef color) {
    
    
    CGContextSetAllowsAntialiasing(context, true);
    CGFloat adjustment = 0.2f;
    
    
    CGRect rectangle = CGRectMake(x,y,width,height);
    
    
    CGContextSetFillColorWithColor(context, getAdjustedColor(color, adjustment));
    CGContextSetStrokeColorWithColor(context, getAdjustedColor(color, adjustment));
    
    CGFloat locations[2] = {0.0,1.0};
    CGGradientRef gradient = makeGradient(color,adjustment, locations);
    
    CGContextSaveGState(context);
    
    CGContextAddRect(context, rectangle);
    CGContextClip(context);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rectangle), CGRectGetMinY(rectangle));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rectangle), CGRectGetMaxY(rectangle));
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    
    CGContextRestoreGState(context);
    
}




CGGradientRef makeGradient(const CGColorRef color, const CGFloat adjustment, const CGFloat * locations)
{
    CGColorRef topGradient = getAdjustedColor(color,adjustment);
    CGColorRef lowGradient = color;
    NSArray * gradientColors = @[(__bridge id)topGradient,(__bridge id)lowGradient];
    
    return CGGradientCreateWithColors(CGColorGetColorSpace(color), (__bridge CFArrayRef)(gradientColors), locations);
    
}


CGColorRef getAdjustedColor(const CGColorRef inColor, const float adjustment) {
    CGFloat * components = (CGFloat *)  CGColorGetComponents(inColor);
    
    CGFloat adjustedComponents[4];
    for (int i= 0; i < 3; i++) {
        adjustedComponents[i] = components[i]+adjustment;
    }
    adjustedComponents[3] = CGColorGetAlpha(inColor);
    
    return CGColorCreate(CGColorGetColorSpace(inColor),adjustedComponents );
}
@end
