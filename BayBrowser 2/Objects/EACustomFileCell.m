//
//  EACustomFileCell.m
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/30/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import "EACustomFileCell.h"

@implementation EACustomFileCell

#pragma mark - EACustomFileCell
- (id)init {
	if (self = [super init]) {
		//create the stuff
		_fileName = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, [self bounds].size.width - 10, 20)];
		[_fileName setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14]];

		_sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, [self bounds].size.width - 100, 20)];
		[_sizeLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:10]];

		_dateLabel = [[UILabel alloc] initWithFrame:CGRectMake([self bounds].size.width - 105, 30, 100, 20)];
		[_dateLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:10]];
		[_dateLabel setTextAlignment:NSTextAlignmentLeft];

		[[self contentView] addSubview:_fileName];
		[[self contentView] addSubview:_sizeLabel];
		[[self contentView] addSubview:_dateLabel];
	}

	return self;
}

@end
