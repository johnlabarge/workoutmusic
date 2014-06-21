//
//  WOMMediaReclassifiedView.m
//  WorkoutMusic
//
//  Created by John La Barge on 6/8/14.
//  Copyright (c) 2014 John La Barge. All rights reserved.
//

#import "WOMMediaReclassifiedView.h"
@interface WOMMediaReclassifiedView()
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewTitle;
@property (weak, nonatomic) IBOutlet UIImageView *artImageView;
@property (nonatomic, strong) NSLayoutConstraint * offScreenLayout;
@property (nonatomic, strong) NSLayoutConstraint * onScreenLayout;

@end
@implementation WOMMediaReclassifiedView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeCustomView];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeCustomView];
    }
    return self;
}

-(void) initializeCustomView {
    NSArray * screens = [[NSBundle mainBundle] loadNibNamed:@"WOMMediaReclassifiedAlert" owner:self options:nil];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self addSubview:[screens objectAtIndex:0]];

    
    
 
}
-(void) setMusicItem:(MusicLibraryItem *)musicItem {
    _musicItem = musicItem;
    self.artistLabel.text = musicItem.artist;
    self.titleLabel.text  = musicItem.title;
    self.artImageView.image = [musicItem.artwork imageWithSize:CGSizeMake(60,60)];
}

-(void) show:(UIView *)superView
{
    __weak typeof(self) weakSelf = self;
  //  CGRect superFrame = superView.frame;
  //  float startY = superFrame.origin.y+superFrame.size.height+1;
  //  float finishY = startY-149;
 //   self.frame = CGRectMake(0.0, startY, 320, 100);
       self.viewTitle.text = [NSString stringWithFormat:@"Reclassified as %@",[Tempo intensities][self.classification]];
    
    [superView addSubview:self];
    
    self.offScreenLayout = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:100];
    self.onScreenLayout = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-149.0];
    [superView addConstraint:self.offScreenLayout];
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:10.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [superView setNeedsLayout];
        
    } completion:^(BOOL finished) {
        
  /*  [UIView animateWithDuration:0.5 animations:^{
        [superView setNeedsLayout];
    } completion:^(BOOL finished) { */
        if (finished) {
            [superView removeConstraint:self.offScreenLayout];
            [superView addConstraint:self.onScreenLayout];
            [UIView animateWithDuration:1.0 animations:^{
                
                [superView layoutIfNeeded];
            } completion:^(BOOL finished) {

                if (finished) {
                   [superView removeConstraint:self.onScreenLayout];
                   [superView addConstraint:self.offScreenLayout];

                    [UIView animateWithDuration:3.0 animations:^{
                        self.alpha = 0.0;
                        [superView layoutIfNeeded];
                    } completion:^(BOOL finished) {
                        
                        if (finished) {
                            [self removeFromSuperview];
                        }
                    }];
                    
                }
            }];
        }
    }];
    

  /* [UIView animateWithDuration:0.75 animations:^{
        
        weakSelf.frame = newFrame;
        
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:5.0 animations:^{
                
                //weakSelf.alpha = 0.0;
                
            } completion:^(BOOL finished) {
                if (finished) {
                   // [weakSelf removeFromSuperview];
                }
            }];

        }
    }];*/
}
-(BOOL) translatesAutoresizingMaskIntoConstraints{return NO;}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
