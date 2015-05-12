//
//  BackgroundSlider.m
//  backgroundSlider
//
//  Created by John La Barge on 5/31/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import "BackgroundSlider.h"
@interface BackgroundSlider()
@end
@implementation BackgroundSlider

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}


-(id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self setup];
    return self;
    
}



-(void) setup {
    
     
    self.coverImageSize = CGSizeMake(1.0, 10.0);
    self.revealImageSize = CGSizeMake(1.0, 10.0);
    //self.backgroundColor = [UIColor orangeColor];
    self.coverColor = [UIColor whiteColor];
    self.revealColor = [UIColor clearColor];
    self.gradientColors = @[(id)[UIColor yellowColor].CGColor, (id)[UIColor orangeColor].CGColor, (id)[UIColor redColor].CGColor];

}

-(void) createCoverImage
{
    UIGraphicsBeginImageContext(self.coverImageSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, self.coverColor.CGColor);
    CGContextFillRect(context, CGRectMake(0,0,self.coverImageSize.width,self.coverImageSize.height));
    self.coverImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

-(void) createRevealImage
{
    UIGraphicsBeginImageContext(self.coverImageSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, self.revealColor.CGColor);
    CGContextFillRect(context, CGRectMake(0,0,self.revealImageSize.width,self.revealImageSize.height));
    self.revealImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

-(void) createGradientLayer
{
    
    
    
  //  CGRect imageRect = CGRectMake(self.bounds.origin.x,self.bounds.origin.y+2.5,self.bounds.size.width,self.bounds.size.height-5.0);

    NSArray * locations = @[@0.0, @0.5, @1.0];
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    CAGradientLayer *backgroundLayer = [CAGradientLayer layer];
    backgroundLayer.startPoint = CGPointMake(0.0, 0.5);
    backgroundLayer.endPoint = CGPointMake(1.0, 0.5); 
    backgroundLayer.colors = self.gradientColors;
    backgroundLayer.locations = locations;
    
 
    
    backgroundLayer.frame = CGRectMake(3.0,CGRectGetMidY(self.bounds)-2.5,self.frame.size.width-6.0,8.0);
     [self.layer insertSublayer:backgroundLayer atIndex:0];
    if (self.maskLayer) {
        [self.layer insertSublayer:self.maskLayer atIndex:1];
    }
 
}
-(void) layoutSubviews
{
    [super layoutSubviews];
    [self createGradientLayer];
}


-(void)willMoveToSuperview:(UIView *)newSuperview
{

     [super willMoveToSuperview:newSuperview];
    [self createCoverImage];
    [self createRevealImage];

    [self setMinimumTrackImage:self.revealImage forState:UIControlStateNormal];
    [self setMaximumTrackImage:self.coverImage forState:UIControlStateNormal];
}



@end
