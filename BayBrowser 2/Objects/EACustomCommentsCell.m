//
//  EACustomCommentsCell.m
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/13/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import "EACustomCommentsCell.h"

@implementation EACustomCommentsCell

#pragma mark - EACustomCommentsCell
- (id)init {
	if (self = [super init]) {
		//setup labels
		_commentText = [[UILabel alloc] init];
		_authorLabel = [[UILabel alloc] init];
		_times = [[UILabel alloc] init];

		//customize labels
		[_commentText setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
		[_commentText setText:@"COMMENT TEXT"];
		[_commentText setBackgroundColor:[UIColor clearColor]];
		[_commentText setLineBreakMode:NSLineBreakByWordWrapping]; //allows multiline

		[_authorLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:10]];
		[_authorLabel setText:@"AUTHOR"];
		[_authorLabel setBackgroundColor:[UIColor clearColor]];

		[_times setFont:[UIFont fontWithName:@"HelveticaNeue" size:10]];
		[_times setText:@"TIMES"];
		[_times setBackgroundColor:[UIColor clearColor]];

		//add labels to cell
		[[self contentView] addSubview:_commentText];
		[[self contentView] addSubview:_authorLabel];
		[[self contentView] addSubview:_times];
	}

	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];

	//position labels
	[_commentText setFrame:CGRectMake(15, 5, [[self contentView] frame].size.width - 20, [[self contentView] bounds].size.height - 25)];
	[_authorLabel setFrame:CGRectMake(15, [_commentText bounds].size.height + 7, 70, 21)];
	[_times setFrame:CGRectMake(120, [_commentText bounds].size.height + 7, 100, 21)];
}

@end
