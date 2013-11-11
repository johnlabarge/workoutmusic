//
//  Solution.m
//  WorkoutMusic
//
//  Created by La Barge, John on 11/7/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import "Solution.h"

@implementation Solution



@end
#define MAX_AREA 2147483647L

@interface JRect: NSObject

@property (nonatomic, strong) NSArray * top_right;
@property (nonatomic, strong) NSArray * bottom_left;
@property (readonly) NSInteger left;
@property (readonly) NSInteger right;
@property (readonly) NSInteger bottom;
@property (readonly) NSInteger top;

-(id) initWithTopRight:(NSArray *)tr andBottomLeft:(NSArray *)br;
-(BOOL)overlaps:(JRect *)otherRect;
@end

@implementation JRect
-(id) initWithTopRight:(NSArray *)tr andBottomLeft:(NSArray *)bl;
{
    self = [super init];
    
    self.top_right = tr;
    self.bottom_left =bl;
    
    NSAssert(self.right > self.left, @"invalid rectangle, right should be greater than left.");
    NSAssert(self.top > self.bottom, @"invalid rectangle, top should be greater than bottom.");
    
    return self;
}

-(NSInteger) left
{
    return [(NSNumber *)[self.bottom_left objectAtIndex:0] integerValue];
}

-(NSInteger) top
{
    return [(NSNumber *)[self.top_right objectAtIndex:1] integerValue];
}

-(NSInteger) bottom
{
    return [(NSNumber *)[self.bottom_left objectAtIndex:1] integerValue];
}
-(NSInteger)right
{
    return [(NSNumber *)[self.top_right objectAtIndex:0] integerValue];
}


-(BOOL) overlaps:(JRect *)other
{
     BOOL portionFromRight = (other.right > self.left &&
                              self.right > other.left);
     BOOL portionFromLeft = (other.left > self.right && other.right > other.left);
    
     BOOL xIntersection = portionFromRight || portionFromLeft;
    
     BOOL portionFromTop = (other.bottom >= self.bottom  && other.top > self.bottom);
     BOOL portionFromBottom = (self.bottom >= other.bottom && self.top > other.bottom);
    
     BOOL yIntersection = (portionFromTop || portionFromBottom);
    
     return xIntersection && yIntersection;
    
}

-(NSInteger ) area
{
    NSInteger result = 0;
    long areaLong = (self.top-self.bottom)*(self.right-self.left);
    
    if (areaLong > MAX_AREA) {
        result = -1;
    } else {
        result = (NSInteger) areaLong;
    }
    return result;
}

-(BOOL) inside:(JRect *)other
{
   return  (self.top <= other.top && self.right <= other.right)
    && (self.left >= other.left && self.bottom >= other.bottom);
}

-(NSInteger)intersectionArea:(JRect *)other
{
    NSInteger result = 0;
    if ([self overlaps:other]) {
        if ([self inside:other]) {
            result = [self area];
        } else if ([other inside:self])  {
            result = [other area];
        } else {
            NSInteger width;
            NSInteger height;
            width = abs(self.right - other.right);
            height = abs(self.top - self.bottom);
            long tempResult = width*height;
            if (tempResult > MAX_AREA) {
                result = -1;
            } else {
                result = (NSInteger)tempResult;
            }
            
        }
    }
    return result;
}
@end
int solution(int blx1, int bly1, int trx1, int try1, int blx2, int bly2, int trx2, int try2) {
    NSArray * topRight1 = @[[NSNumber numberWithInt:trx1], [NSNumber numberWithInt:try1]];
    NSArray * bottomLeft1 = @[ [NSNumber numberWithInt:blx1], [NSNumber numberWithInt:bly1]];
    NSArray * topRight2 = @[[NSNumber numberWithInt:trx2], [NSNumber numberWithInt:try2]];
    NSArray * bottomLeft2 =@[[NSNumber numberWithInt:blx2], [NSNumber numberWithInt:bly2]];
    
    JRect * jrect1 = [[JRect alloc] initWithTopRight:topRight1 andBottomLeft:bottomLeft1];
    JRect * jrect2 = [[JRect alloc] initWithTopRight:topRight2 andBottomLeft:bottomLeft2];
    
    return [jrect1 intersectionArea:jrect2];
}
