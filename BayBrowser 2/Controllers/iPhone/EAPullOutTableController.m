//
//  EAPullOutTableController.m
//  EAPullOutMenu
//
//  Created by Ethan Arbuckle on 2/18/14.
//  Copyright (c) 2014 Ethan Arbuckle. All rights reserved.
//

#import "EAPullOutTableController.h"

@interface EAPullOutTableController ()

@end

@implementation EAPullOutTableController

- (id)init {
	self = [super init];

	if (self) {
		//array that holds all active controllers
		_viewControllers = [[NSMutableArray alloc] init];


		//main navigation controller
		_navigationController = [[UINavigationController alloc] init];

		//create the side table off screen
		_sideTable = [[UITableView alloc] initWithFrame:CGRectMake(-210, 64, 210, [[self view] bounds].size.height - 64)];
		[_sideTable setBackgroundColor:[UIColor blackColor]];
		[_sideTable setAlpha:.5];
		[_sideTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
		[_sideTable setDelegate:self];
		[_sideTable setDataSource:self];
		[_sideTable setScrollsToTop:NO];
		[_sideTable setShowsVerticalScrollIndicator:NO];

		//create blur view that sits behind the table
		_blurView = [[EADynamicBlur alloc] initWithFrame:CGRectMake(-210, 64, 210, [[self view] bounds].size.height - 64)];
		[_blurView setBlurEdges:NO];

		//only add blur on a device, simulator lags too much with it
#if !(TARGET_IPHONE_SIMULATOR)
		[[_navigationController view] addSubview:_blurView];
#endif
		[[_navigationController view] addSubview:_sideTable]; //add the table

		//add navigation controller
		[[self view] addSubview:[_navigationController view]];

		//create and add main posts view
		[_viewControllers addObject:[[EAMainPostsController alloc] init]];
		[[_viewControllers objectAtIndex:0] setTitle:@"All"];

		//cycle through and create a controller for each object
		NSArray *titles = [[NSArray alloc] initWithObjects:@"Audio", @"Video", @"Applications", @"Games", @"Other", nil];
		NSArray *schemes = [[NSArray alloc] initWithObjects:@"/browse/100", @"/browse/200", @"/browse/300", @"/browse/400", @"/browse/600", nil];
		for (NSString *controller in titles) {
			EADynamicPostsController *dynamicController = [[EADynamicPostsController alloc] initWithScheme:[schemes objectAtIndex:[titles indexOfObject:controller]]];
			[dynamicController setTitle:controller];
			[_viewControllers addObject:dynamicController];
		}

		[_viewControllers addObject:[[EATorrentDownloadManager alloc] init]];
		[[_viewControllers objectAtIndex:6] setTitle:@"Active"];

		//start file browser in downloads path
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *downloadsFolder = [NSString stringWithFormat:@"%@/Downloads", documentsDirectory];
		[_viewControllers addObject:[[EAFileBrowser alloc] initWithPath:downloadsFolder]];

		[_viewControllers addObject:[[EASettingsController alloc] init]];
		[[_viewControllers objectAtIndex:8] setTitle:@"Settings"];

		//start on the first controller
		[_navigationController setViewControllers:[NSArray arrayWithObject:[_viewControllers objectAtIndex:0]]];

		//add slide out button
		UIBarButtonItem *navBar = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"iconSlide.png"] style:UIBarButtonItemStyleDone target:self action:@selector(tappedShowHide)];

		[[[_navigationController navigationBar] topItem] setLeftBarButtonItem:navBar];

		[[_navigationController navigationBar] setTranslucent:NO];

		//pan gesture that slides the table in and out
		UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
		[[_navigationController view] addGestureRecognizer:pan];

		//double tap the nav bar to open side menu
		UITapGestureRecognizer *sideViewer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedShowHide)];
		[sideViewer setNumberOfTapsRequired:2];
		[[_navigationController navigationBar] addGestureRecognizer:sideViewer];
	}
	return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0)
		return 6;
	if (section == 1)
		return 2;
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [[UITableViewCell alloc] init];
	[cell setBackgroundColor:[UIColor clearColor]];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];

	if ([indexPath section] == 0) {
		//pick from titles in array
		NSArray *titles = [[NSArray alloc] initWithObjects:@"All", @"Audio", @"Video", @"Applications", @"Games", @"Other", nil];
		[[cell textLabel] setText:[titles objectAtIndex:[indexPath row]]];
		[[cell textLabel] setTextColor:[UIColor whiteColor]];
		[[cell textLabel] setBackgroundColor:[UIColor clearColor]];
	}

	if ([indexPath section] == 1) {
		NSArray *titles = [[NSArray alloc] initWithObjects:@"Active", @"File Browser", nil];
		[[cell textLabel] setText:[titles objectAtIndex:[indexPath row]]];
		[[cell textLabel] setTextColor:[UIColor whiteColor]];
		[[cell textLabel] setBackgroundColor:[UIColor clearColor]];
	}

	if ([indexPath section] == 2) {
		[[cell textLabel] setText:@"Settings"];
		[[cell textLabel] setTextColor:[UIColor whiteColor]];
		[[cell textLabel] setBackgroundColor:[UIColor clearColor]];
	}

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath section] == 0) {
		//indexpath row is viewcontroller at that index
		[_navigationController setViewControllers:[NSArray arrayWithObject:[_viewControllers objectAtIndex:[indexPath row]]]];
	}

	if ([indexPath section] == 1) {
		//row + 6 is viewcontroller
		[_navigationController setViewControllers:[NSArray arrayWithObject:[_viewControllers objectAtIndex:[indexPath row] + 6]]];
	}

	if ([indexPath section] == 2)
		[_navigationController setViewControllers:[NSArray arrayWithObject:[_viewControllers objectAtIndex:[indexPath row] + 8]]];

	//Aadd slide out menu + double tap
	UIBarButtonItem *navBar = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"iconSlide.png"] style:UIBarButtonItemStyleDone target:self action:@selector(tappedShowHide)];
	[[[_navigationController navigationBar] topItem] setLeftBarButtonItem:navBar];

	UITapGestureRecognizer *sideViewer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedShowHide)];
	[sideViewer setNumberOfTapsRequired:2];
	[[_navigationController navigationBar] addGestureRecognizer:sideViewer];

	[self hideTable];
}

- (void)tappedShowHide {
	//determine whether to open or close menu
	if (!_isOpen)
		[self showTable];
	else
		[self hideTable];
}

- (void)showTable {
	//hide all toolbars, they sit on top of table
	[_navigationController setToolbarHidden:YES animated:YES];

	//animate table and blur view out onto the screen
	[UIView animateWithDuration:.3 animations: ^{
	    [_sideTable setFrame:CGRectMake(0, 64, 210, [[self view] bounds].size.height - 64)];
	    [_blurView setFrame:CGRectMake(0, 64, 210, [[self view] bounds].size.height - 64)];
	    [[[_navigationController visibleViewController] view] setUserInteractionEnabled:NO];
	} completion: ^(BOOL finished) {
	    _isOpen = YES;
	}];
}

- (void)hideTable {
	//animate table and blur off the screen
	[UIView animateWithDuration:.3 animations: ^{
	    [_sideTable setFrame:CGRectMake(-210, 64, 210, [[self view] bounds].size.height - 64)];
	    [_blurView setFrame:CGRectMake(-210, 64, 210, [[self view] bounds].size.height - 64)];
	    [[[_navigationController visibleViewController] view] setUserInteractionEnabled:YES];
	} completion: ^(BOOL finished) {
	    _isOpen = NO;

	    //only show toolbar if the current view is the file browser
	    if ([[_navigationController topViewController] isKindOfClass:[EAFileBrowser class]])
			[_navigationController setToolbarHidden:NO animated:YES];
	}];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0)
		return @"Browse";
	if (section == 1)
		return @"Downloads";
	return @"BayBrowser 2.0.7";
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	//detect taps outside the table, close table
	if (_isOpen)
		[self hideTable];
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
	if (!_isOpen) return; //only if open

	if ([pan state] == UIGestureRecognizerStateBegan || [pan state] == UIGestureRecognizerStateChanged) {
		CGPoint translation = [pan translationInView:_sideTable];

		if ([_sideTable center].x <= 105) {
			CGFloat newX = [_sideTable center].x + translation.x;

			if (newX > 103.0)
				newX = 105;

			[_sideTable setCenter:CGPointMake(newX, [[self view] center].y + 32)];
			[_blurView setCenter:[_sideTable center]];
			[pan setTranslation:CGPointZero inView:_sideTable];
		}
	}

	if ([pan state] == UIGestureRecognizerStateEnded) {
		if ([_sideTable center].x < 33 || [pan velocityInView:_sideTable].x <= -500)
			[self hideTable];
		else
			[self showTable];
	}
}

@end
