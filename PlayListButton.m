//
//  PlayListButton.m
//  WorkoutMusic
//
//  Created by John La Barge on 2/1/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import "PlayListButton.h"
@interface PlayListButton()
@property (nonatomic, weak) CALayer *rootLayer;
@property (nonatomic, weak) CALayer *labelLayer;

@end
@implementation PlayListButton
-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
   /* self.customView = [[UIView alloc] init];
    
    UIImage *bgImage = [UIImage imageNamed:@"playlisticon"];
   */
    self.rootLayer = self.customView.layer;
   /* self.rootLayer.contents = (id) bgImage.CGImage;
    */
    self.labelLayer = [CALayer layer];
    
    self.labelLayer.frame = self.rootLayer.frame;
    [self.rootLayer addSublayer:self.labelLayer];
    
    self.labelLayer.delegate = self;
    
    
    
    return self;
}

-(void) drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    NSLog(@"draw layer");
    if (layer == self.labelLayer) {
        CGContextSetFillColorWithColor(ctx, [[UIColor darkTextColor] CGColor]);
        UIGraphicsPushContext(ctx);
    
        [self.playListName drawAtPoint:CGPointMake(0.0f, 10.0f) forWidth:200.0f withFont:[UIFont systemFontOfSize:15.0] lineBreakMode:NSLineBreakByTruncatingTail ];
                                 
    }
}
@end
