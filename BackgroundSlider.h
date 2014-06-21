//
//  BackgroundSlider.h
//  backgroundSlider
//
//  Created by John La Barge on 5/31/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BackgroundSlider : UISlider
@property (nonatomic, strong) UIColor * coverColor;
@property (nonatomic, strong) UIColor * revealColor;
@property (nonatomic, strong) UIImage * coverImage;
@property (nonatomic, strong) UIImage * revealImage;
@property (nonatomic, assign) CGSize coverImageSize;
@property (nonatomic, assign) CGSize revealImageSize;
@property (nonatomic, strong) UIImage * backgroundImage;
@property (nonatomic, strong) NSArray * gradientColors;
@property (nonatomic, strong) CALayer * maskLayer;

@end
