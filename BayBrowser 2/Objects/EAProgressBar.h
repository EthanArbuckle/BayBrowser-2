//
//  EAProgressBar.h
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/14/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EAProgressBar : UIView

- (EAProgressBar *)initWithFrame:(CGRect)frame;
- (void)setProgress:(float)progress;
- (void)hide;
- (void)show;

@property (nonatomic, retain) UILabel *percentLabel;

@end
