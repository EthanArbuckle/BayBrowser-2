//
//  EADynamicPostsController.m
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/18/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import "EADynamicPostsController.h"

@implementation EADynamicPostsController

#pragma mark - UIViewController
- (id)initWithScheme:(NSString *)pScheme {
	//set scheme (/browse/xxx)

	_scheme = pScheme;
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	//setup the tableview
	EACustomPostsTableView *tableView;

	//if frame is provided (for ipad panes)
	if (_isPad) {
		tableView = [[EACustomPostsTableView alloc] initWithFrame:CGRectMake(0, 44, 300, [[self view] bounds].size.height)];
		[tableView setIsPad:YES];

		[[self view] setFrame:CGRectMake(0, 0, 300, self.view.bounds.size.height)];

		UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
		[navBar layer].zPosition = 5;
		[navBar setTranslucent:NO];
		UINavigationItem *title = [UINavigationItem alloc];
		[title setTitle:_titleForNavigationBar];
		[navBar pushNavigationItem:title animated:NO];

		[[self view] addSubview:navBar];
	}
	else
		tableView = [[EACustomPostsTableView alloc] initWithFrame:[[self view] bounds]];

	__weak EACustomPostsTableView *tableView_ = tableView;

	//add search bar/sort by
	[tableView addHeader];

	//add more footer
	[tableView addFooter];

	//append on to url for 'sort by'
	[[tableView urlInformation] setObject:_scheme forKey:@"scheme"];

	//set posts to load first
	[tableView setInitialPostsBlock: ^{
	    [[tableView_ pirateAPI] scrapeInformationFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@/0/7/0", SETTINGS_BASE_URL, _scheme]] isPageOne:YES];
	}];

	//this lets it grab out nav controller
	[tableView setParent:self];

	//start loading first posts
	[tableView start];
	[[self view] addSubview:tableView];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[[self navigationController] setToolbarHidden:YES];
}

- (void)viewDidPinch:(UIPinchGestureRecognizer *)pinch {
	if ([pinch state] == UIGestureRecognizerStateChanged) {
		if ([pinch scale] >= 0.75 && [pinch scale] <= 1.2) {
			[self resizeByFactor:[pinch scale]];
			[[self view] setAlpha:[pinch scale]];
		}

		if ([pinch scale] < 0.70) {
			[[Delegate rootStackController] removeControllerAtIndex:[[[Delegate rootStackController] viewControllers] indexOfObject:self]];
		}
	}

	if ([pinch state] == UIGestureRecognizerStateEnded) {
		[UIView animateWithDuration:.2 animations: ^{
		    [[self view] setTransform:CGAffineTransformIdentity];
		    [[self view] setAlpha:1];
		}];
	}
}

- (void)resizeByFactor:(CGFloat)factor {
	CGAffineTransform transform = CGAffineTransformMakeScale(factor, factor);
	self.view.transform = transform;
}

@end
