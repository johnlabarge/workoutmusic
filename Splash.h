//
//  Splash.h
//  roshambo
//
//  Created by La Barge, John on 2/7/13.
//  Copyright (c) 2013 La Barge, John. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WOMusicAppDelegate.h"

@interface Splash : UIViewController
@property  (nonatomic, strong) IBOutlet UIImageView * image;
-(void) afterSplash;
@end
