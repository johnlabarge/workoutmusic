//
//  Splash.h
//  roshambo
//
//  Created by La Barge, John on 2/7/13.
//  Copyright (c) 2013 La Barge, John. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WOMusicAppDelegate.h"
#import "SuperViewController.h"

@interface Splash : SuperViewController
@property  (nonatomic, strong) IBOutlet UIImageView * image;
@property (nonatomic, strong) IBOutlet  UILabel * currentlyProcessing;
@property (nonatomic, strong) IBOutlet  UIProgressView *progressView; 
-(void) afterSplash;
@end
