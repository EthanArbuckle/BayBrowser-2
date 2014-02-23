//
//  EADescriptionView.m
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/13/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import "EADescriptionView.h"
#import "EAiPhoneDelegate.h"

@implementation EADescriptionView

#pragma mark - UIViewController
- (id)initWithTorrent:(NSDictionary *)passedTorrent andFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
    
	[self setBackgroundColor:[UIColor whiteColor]];
    
    //set instance var as passed
	_passed = passedTorrent;
    
	//make progress spinner + activate status bar progress
	UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[spinner setFrame:CGRectMake(([self bounds].size.width / 2) - 50, 100, 100, 20)];
	[spinner startAnimating];
	[self addSubview:spinner];
    
	//create api and pull description
	EAPirateBayAPI *api = [[EAPirateBayAPI alloc] init];
	[api setDelegate:self];
	[api getDetailsAboutTorrentWithID:[passedTorrent objectForKey:@"id"]];
    
    
	return self;
}

#pragma mark - EAPirateBayAPI delegate
- (void)recieveResultsFromAPI:(NSDictionary *)results {
    
    //hide status label
	[[Delegate universalProgressIndicator] hide];
    
	//add description textview with text
	UITextView *descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(5, 52, [self frame].size.width - 10, [self frame].size.height - 57)];
	[descriptionTextView setFont:[[EAThemeManager sharedManager] fontForCellMainLabel]];
	[descriptionTextView setTextColor:[[EAThemeManager sharedManager] colorForCellMainLabel]];
	[descriptionTextView setText:[results objectForKey:@"description"]];
	[descriptionTextView setEditable:NO];
	[descriptionTextView setDataDetectorTypes:UIDataDetectorTypeLink];
	[self addSubview:descriptionTextView];
    
	//add torrent title label
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, [self frame].size.width - 10, 20)];
	[titleLabel setFont:[[EAThemeManager sharedManager] fontForCellDetailLabel]];
	[titleLabel setTextColor:[[EAThemeManager sharedManager] colorForCellMainLabel]];
	[titleLabel setText:[NSString stringWithFormat:@"Title: %@", [_passed objectForKey:@"title"]]];
	[self addSubview:titleLabel];
    
	//add torrent size label
	UILabel *sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 11, [self frame].size.width - 10, 20)];
	[sizeLabel setFont:[[EAThemeManager sharedManager] fontForCellDetailLabel]];
	[sizeLabel setTextColor:[[EAThemeManager sharedManager] colorForCellMainLabel]];
	[sizeLabel setText:[NSString stringWithFormat:@"Size: %@", [_passed objectForKey:@"size"]]];
	[self addSubview:sizeLabel];
    
	//add seeders/leechers label
	UILabel *seedersLeechersLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 22, [self frame].size.width - 10, 20)];
	[seedersLeechersLabel setFont:[[EAThemeManager sharedManager] fontForCellDetailLabel]];
	[seedersLeechersLabel setTextColor:[[EAThemeManager sharedManager] colorForCellMainLabel]];
	[seedersLeechersLabel setText:[NSString stringWithFormat:@"SE: %@ - LE: %@", [_passed objectForKey:@"seeders"], [_passed objectForKey:@"leechers"]]];
	[self addSubview:seedersLeechersLabel];
    
	//add uploaded label
	UILabel *uploadedLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 33, [self frame].size.width - 10, 20)];
	[uploadedLabel setFont:[[EAThemeManager sharedManager] fontForCellDetailLabel]];
	[uploadedLabel setTextColor:[[EAThemeManager sharedManager] colorForCellMainLabel]];
	[uploadedLabel setText:[NSString stringWithFormat:@"Uploaded: %@", [_passed objectForKey:@"date"]]];
	[self addSubview:uploadedLabel];
}

- (void)failedToRecieveResultsWithError:(NSError *)error {
	NSLog(@"failed with error: %@", error);
}

- (void)recieveResultsFromAPIForNextPage:(NSDictionary *)results {
}

- (void)recieveProgressFromAPI:(float)prog {
    
    //update statusbar progress
	[[Delegate universalProgressIndicator] show];
	[[Delegate universalProgressIndicator] setProgress:prog];
}

@end
