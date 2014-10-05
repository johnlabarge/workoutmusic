//
//  UIView+Util.h
//  AppleDemo1
//
//  Created by John La Barge on 7/5/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 * utilities to help make autolayout a little less verbose. Not quite to the level of masonry, but more understandable.
 */
@interface UIView (Util)
-(UIView *) addSubviewInCenter:(UIView *)view;
-(UIView *) addSubviewCenterX:(UIView *)view;
-(UIView *) addSubviewCenterY:(UIView *)view;
/**
 *
 * add constraints to expand a subview to the edges of this view.
 * @param subview - must be a subview of this UIView
 * @return - An array of constraints of the form @[leadingConstraint,trailingConstraint]
 */
-(NSArray *) expandToWidth:(UIView *)subView;

/**
 * add constraints to expand a subview to the vertical edges of this view
 * @param subview - must be a subview of this UIView
 * @return - An array of constraints of the form @[topConstraint,bottomConstraint]
 *
 */
-(NSArray *) expandToHeight:(UIView *)subView;
/**
 * adds a subview (without any constraints) and returns its reference.
 * convenient for one liner constructor-assignments.
 *
 */
-(id)add:(UIView *)subview;
/**
 * adds layout constraint at a proportion of the height of this view.
 */
-(NSLayoutConstraint *)layoutView:(UIView *)view atHeightProportion:(CGFloat)heightProportion;

-(NSLayoutConstraint *)layoutView:(UIView *)view atWidthProportion:(CGFloat)widthProportion; 
/**
 * adds layout constraint that puts a view under another at a distance, distance.
 */
-(NSLayoutConstraint *)layoutView:(UIView *)view underView:(UIView *)upperView atDistance:(CGFloat)distance;

/**
 * adds a layout constraint for view to have a specific constant width. 
 */
-(NSLayoutConstraint *)layoutView:(UIView *)view atWidth:(CGFloat)widthConstant;

/**
 * adds a layout constraint that constrains a view to a height proportion and width that is the aspectRation prorportion of the height. */
-(NSArray *)layoutView:(UIView *)view atHeightProportion:(CGFloat)heightProportion withAspectRatio:(CGFloat)aspect;
/**
 * set the leading space for a subview
 */
-(NSLayoutConstraint *)layoutView:(UIView *)view leading:(CGFloat)leadingSpace;
/**
 * set the trailing space for a subview
 */
-(NSLayoutConstraint *)layoutView:(UIView *)view trailing:(CGFloat)trailingSpace;
/*
 *  set the bottom space to self of this subview
 */
-(NSLayoutConstraint *)layoutView:(UIView *)view bottom:(CGFloat)bottomSpace;
/*
 * set the top space to self of this subview
 */
-(NSLayoutConstraint *)layoutView:(UIView *)view top:(CGFloat)topSpace;

-(NSLayoutConstraint *)trailingSpaceFrom:(UIView *)subView1 toView:(UIView *)subView2 equals:(CGFloat)space;
@end
