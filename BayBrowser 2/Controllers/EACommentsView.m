//
//  EACommentsView.m
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/13/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import "EACommentsView.h"

@implementation EACommentsView

#pragma mark - UIViewController
- (id)initWithTorrentID:(NSString *)torrentID andFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	[self setBackgroundColor:[UIColor whiteColor]];

	//setup api and grab comment info
	EAPirateBayAPI *api = [[EAPirateBayAPI alloc] init];
	[api setDelegate:self];
	[api getCommentInformationFromTorrentWithID:torrentID];

	//setup table
	_commentsTable = [[UITableView alloc] initWithFrame:CGRectMake(5, 0, [self frame].size.width - 10, [self frame].size.height + 60)];
	[_commentsTable setDataSource:self];
	[_commentsTable setDelegate:self];

	return self;
}

#pragma mark - UITableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	//calculate size based on text height
	NSString *title = [[_commentInformation objectForKey:@"comments"] objectAtIndex:[indexPath row]];
	CGSize textSize = [title sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0f] constrainedToSize:CGSizeMake([self bounds].size.width - 30, 20000) lineBreakMode:NSLineBreakByWordWrapping];

	return textSize.height + 25;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//number of comments
	return [[_commentInformation objectForKey:@"comments"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//create cell
	EACustomCommentsCell *cell = (EACustomCommentsCell *)[tableView dequeueReusableCellWithIdentifier:@"EACustomCommentsCell"];
	if (cell == nil)
		cell = [[EACustomCommentsCell alloc] init];

	//set comment label text
	[[cell commentText] setText:[[_commentInformation objectForKey:@"comments"] objectAtIndex:[indexPath row]]];
	[[cell commentText] setNumberOfLines:0];
	[[cell commentText] sizeToFit];

	//setup author label text
	[[cell authorLabel] setText:[[_commentInformation objectForKey:@"usernames"] objectAtIndex:[indexPath row]]];

	//setup time label text
	[[cell times] setText:[[_commentInformation objectForKey:@"times"] objectAtIndex:[indexPath row]]];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - EAPirateBayAPI delegate
- (void)recieveResultsFromAPI:(NSDictionary *)results {
	_commentInformation = results;
	if ([[_commentInformation objectForKey:@"comments"] count] < 1) {
		//if no comments, add No Comments label
		UILabel *noComments = [[UILabel alloc] initWithFrame:CGRectMake(([self bounds].size.width / 2) - 50, 130, 100, 20)];
		[noComments setFont:[[EAThemeManager sharedManager] fontForCellMainLabel]];
		[noComments setTextColor:[[EAThemeManager sharedManager] colorForCellMainLabel]];
		[noComments setText:@"No Comments!"];
		[noComments setTextAlignment:NSTextAlignmentCenter];
		[noComments setBackgroundColor:[UIColor clearColor]];
		[self addSubview:noComments];
		[_commentsTable removeFromSuperview];
	}
	else {
		//or add tableview
		[_commentsTable reloadData];
		[self addSubview:_commentsTable];
	}
}

- (void)failedToRecieveResultsWithError:(NSError *)error {
	NSLog(@"failed with error: %@", error);
}

- (void)recieveResultsFromAPIForNextPage:(NSDictionary *)results {
}

- (void)recieveProgressFromAPI:(float)prog {
}

@end
