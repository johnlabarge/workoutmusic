//
//  UIView+Util.m
//  AppleDemo1
//
//  Created by John La Barge on 7/5/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import "UIView+Util.h"

@implementation UIView (Util)


-(NSDictionary *) prepareAndAddSubview:(UIView *)view
{
    UIView * superview = self;
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:view];
    return NSDictionaryOfVariableBindings(superview, view);
}
-(UIView *) addSubviewInCenter:(UIView *)view  {
    NSDictionary * viewDict = [self prepareAndAddSubview:view];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[superview]-(<=1)-[view]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:viewDict]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[superview]-(<=1)-[view]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewDict]];
    return view;
}
-(UIView *) addSubviewCenterX:(UIView *)view {
    NSDictionary * viewDict = [self prepareAndAddSubview:view];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[superview]-(<=1)-[view]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:viewDict]];
    return view;

}

-(UIView *) addSubviewCenterY:(UIView *)view {
    NSDictionary * viewDict = [self prepareAndAddSubview:view];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[superview]-(<=1)-[view]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewDict]];
    return view;
}

-(id)add:(UIView *)subview {
    subview.translatesAutoresizingMaskIntoConstraints = NO; 
    [self addSubview:subview];
    
    return subview; 
}

-(NSArray *) expandToHeight:(UIView *)subView
{
    NSArray * retArray =  @[
                            [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
                            [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeBottom relatedBy: NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0 ]
                            ];
    [self addConstraints:retArray];
    return retArray;
}

-(NSArray *)expandToWidth:(UIView *)subView
{
    NSArray * retArray = @[
                           [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0],
                           [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]
                           ];
    [self addConstraints:retArray];
    return retArray;
}

-(NSLayoutConstraint *)layoutView:(UIView *)view atHeightProportion:(CGFloat)heightProportion
{
    NSLayoutConstraint * heightConstraint =  [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:heightProportion constant:1.0];
    [self addConstraint:heightConstraint];
    return heightConstraint;
}
-(NSLayoutConstraint *)layoutView:(UIView *)view underView:(UIView *)upperView atDistance:(CGFloat)distance {
    NSLayoutConstraint * topConstraint =  [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:upperView  attribute:NSLayoutAttributeBottom multiplier:1.0 constant:distance];
    [self addConstraint:topConstraint];
    return topConstraint;

}
-(NSLayoutConstraint *)layoutView:(UIView *)view atWidth:(CGFloat)widthConstant
{
    NSLayoutConstraint * widthConstraint =  [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:widthConstant];
    return widthConstraint;
}
-(NSArray *)layoutView:(UIView *)view atHeightProportion:(CGFloat)heightProportion withAspectRatio:(CGFloat)aspect
{
    NSLayoutConstraint *constraint2 = [self layoutView:view atHeightProportion:heightProportion];

    NSLayoutConstraint *constraint1 = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeHeight multiplier:aspect constant:0.0];
       NSArray * theConstraints  = @[constraint2,constraint1];
    [self addConstraints:theConstraints];
    
    return theConstraints;
}
-(NSLayoutConstraint *)layoutView:(UIView *)view leading:(CGFloat)leadingSpace
{
    NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:leadingSpace];
    [self addConstraint:constraint];
    
    return constraint;
}
-(NSLayoutConstraint *)layoutView:(UIView *)view trailing:(CGFloat)trailingSpace
{
    NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:trailingSpace];
    [self addConstraint:constraint];
    
    return constraint;
}
-(NSLayoutConstraint *)layoutView:(UIView *)view top:(CGFloat)topSpace
{
    NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:topSpace];
    [self addConstraint:constraint];
    
    return constraint;
}
-(NSLayoutConstraint *)layoutView:(UIView *)view bottom:(CGFloat)bottomSpace
{
    NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:bottomSpace];
    [self addConstraint:constraint];
    
    return constraint;
}
@end
