//
//  EATorrentDetailController.m
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/12/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import "EATorrentDetailController.h"

@implementation EATorrentDetailController

#pragma mark - UIViewController
- (void)viewDidLoad {
	[super viewDidLoad];

	[[self view] setBackgroundColor:[UIColor whiteColor]];

	if (_isPad) { //ipads custom frame
		[[self view] setFrame:CGRectMake(0, 0, 500, [[UIScreen mainScreen] bounds].size.height)];

		//create navigation bar
		UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, [[self view] bounds].size.width, 44)];
		[navBar setTranslucent:NO];
		UINavigationItem *title = [UINavigationItem alloc];
		[title setTitle:[_torrentDictionary objectForKey:@"title"]];
		[navBar pushNavigationItem:title animated:NO];

		if (SETTINGS_CAN_DOWNLOAD) {
			UIBarButtonItem *downButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(downloadPrompt)];
			[[navBar topItem] setRightBarButtonItem:downButton];
		}

		[[self view] addSubview:navBar];
	}

	//setup view picker segmentcontrol
	_viewPickerSegment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Description", @"Images", @"Comments", nil]];
	[_viewPickerSegment setFrame:CGRectMake(([[self view] bounds].size.width / 2) - 125, 10, 250, 30)];
	if (_isPad)
		[_viewPickerSegment setFrame:CGRectMake(([[self view] bounds].size.width / 2) - 125, 54, 250, 30)];
	[_viewPickerSegment setSegmentedControlStyle:UISegmentedControlStylePlain];
	[_viewPickerSegment addTarget:self action:@selector(didChangeSegmentControl:) forControlEvents:UIControlEventValueChanged];
	[_viewPickerSegment setSelectedSegmentIndex:0];
	[[self view] addSubview:_viewPickerSegment];

	//add description view
	CGRect defaultFrame = CGRectMake(0, [_viewPickerSegment frame].origin.y + 35, [[self view] frame].size.width, [[self view] frame].size.height - 110);

	_descriptionView = [[EADescriptionView alloc] initWithTorrent:_torrentDictionary andFrame:defaultFrame];
	[[self view] addSubview:_descriptionView];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	//add download button
	if (SETTINGS_CAN_DOWNLOAD) {
		UIBarButtonItem *downButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(downloadPrompt)];
		[[self navigationItem] setRightBarButtonItem:downButton];
	}
}

- (void)replaceCurrentViewWith:(UIView *)viewToAdd {
	//get subview to remove
	UIView *subToRemove;

	for (UIView *sub in[[self view] subviews]) {
		if (![sub isKindOfClass:[UISegmentedControl class]]) //dont want to remove the segmentcontrol
			subToRemove = sub;
	}

	//animate alpha fade out on old view before removing it, animate alpha fade in on new
	[UIView animateWithDuration:.2 animations: ^(void) {
	    [subToRemove setAlpha:0]; //animate it out
	} completion: ^(BOOL finished) {
	    [subToRemove removeFromSuperview]; //once you cant see it, remove it
	    [viewToAdd setAlpha:0]; //set next view to invisible
	    [[self view] addSubview:viewToAdd]; //add it to this view
	    [UIView animateWithDuration:.2 animations: ^(void) {
	        [viewToAdd setAlpha:1]; //animate it in
		}];
	}];
}

- (void)downloadPrompt {
	//present download actionsheet
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Download", nil];
	[actionSheet showInView:[self view]];
}

#pragma mark - ActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[[Delegate torrentController] addTorrentFromManget:[_torrentDictionary objectForKey:@"magnet"]];
	}
}

#pragma mark - UISegmentControl delegate
- (void)didChangeSegmentControl:(UISegmentedControl *)sender {
	//segmentcontrol tapped, get new index
	int index = [sender selectedSegmentIndex];

	//make frame
	CGRect defaultFrame = CGRectMake(0, [_viewPickerSegment frame].origin.y + 35, [[self view] frame].size.width, [[self view] frame].size.height - 110);

	//determine which view to change. If the view isnt instantiated, create it
	if (index == 0) {
		if (!_descriptionView)
			_descriptionView = [[EADescriptionView alloc] initWithTorrent:_torrentDictionary andFrame:defaultFrame];
		[self replaceCurrentViewWith:_descriptionView];
	}
	if (index == 1) {
		if (!_imagesView)
			_imagesView = [[EAImagesView alloc] initWithTorrent:_torrentDictionary andFrame:defaultFrame];
		[self replaceCurrentViewWith:_imagesView];
	}
	if (index == 2) {
		if (!_commentsView)
			_commentsView = [[EACommentsView alloc] initWithTorrentID:[_torrentDictionary objectForKey:@"id"] andFrame:defaultFrame];
		[self replaceCurrentViewWith:_commentsView];
	}
}

#pragma mark - PinchToClose methods
- (void)viewDidPinch:(UIPinchGestureRecognizer *)pinch {
	if ([pinch state] == UIGestureRecognizerStateChanged) {
		if ([pinch scale] >= 0.75 && [pinch scale] <= 1.2) {
			[self resizeByFactor:[pinch scale]];
			[[self view] setAlpha:[pinch scale]];
		}

		if ([pinch scale] < 0.70) {
			[[Delegate rootStackController] removeControllerAtIndex:[[[Delegate rootStackController] viewControllers] indexOfObject:self]];
			[[[Delegate rootStackController] pagingView] setContentOffset:CGPointMake(500, 0) animated:YES];
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
