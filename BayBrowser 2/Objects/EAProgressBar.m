//
//  EAProgressBar.m
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/14/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import "EAProgressBar.h"

@implementation EAProgressBar

#pragma mark - EAProgressBar
- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self setBackgroundColor:[UIColor clearColor]];
		[self setFrame:CGRectMake(104, 0, 100, 20)];
		_percentLabel = [[UILabel alloc] initWithFrame:[self bounds]];
		[_percentLabel setText:@""];
		[_percentLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
		[_percentLabel setBackgroundColor:[UIColor clearColor]];
        [_percentLabel setTextColor:[UIColor whiteColor]];
		[self addSubview:_percentLabel];
        [_percentLabel setAlpha:1];
	}
    
	return self;
}

- (void)setProgress:(float)progress {
    if (progress <= 1)
        [_percentLabel setText:[NSString stringWithFormat:@"%.0f%%", progress*100]];
}

- (void)hide {
    [UIView animateWithDuration:1 animations: ^{
        [_percentLabel setAlpha:0];
    }];
}

- (void)show {
    if (SETTINGS_PROGRESS_ENABLED) //only show if enabled
        [_percentLabel setAlpha:1];
}

@end
