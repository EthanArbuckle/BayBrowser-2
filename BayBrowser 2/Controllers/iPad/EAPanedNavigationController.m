//
//  EAPanedNavigationController.m
//  EAPanedNavigationController
//
//  Created by Ethan Arbuckle on 2/12/14.
//  Copyright (c) 2014 Ethan Arbuckle. All rights reserved.
//

#import "EAPanedNavigationController.h"

@implementation EAPanedNavigationController


- (id)initWithRootViewController:(UIViewController *)rootViewController {
	self = [super init];

	if (self) {
		//create objects
		_viewControllers = [[NSMutableArray alloc] init];
		_pivotPoints = [[NSMutableArray alloc] init];
		_rootViewController = rootViewController;

		//set background color
		[[self view] setBackgroundColor:[UIColor clearColor]];

		//create the noise (texture) view as the backgound
		KGNoiseLinearGradientView *noiseView = [[KGNoiseLinearGradientView alloc] initWithFrame:[[self view] bounds]];
		[noiseView setBackgroundColor:[UIColor colorWithRed:0.149020 green:0.145098 blue:0.149020 alpha:1]];
		[noiseView setAlternateBackgroundColor:[UIColor colorWithRed:0.156863 green:0.156863 blue:0.156863 alpha:1]];
		[noiseView setNoiseOpacity:0.03f];
		[[self view] addSubview:noiseView];

		//setupt the pagingview, this holds all the views
		_pagingView = [[EAPagingScollView alloc] initWithFrame:[[self view] bounds]];
		CGRect screenFrame = [_pagingView frame];
		screenFrame.origin.y = [[UIApplication sharedApplication] statusBarFrame].size.height;
		screenFrame.size.height -= [[UIApplication sharedApplication] statusBarFrame].size.height;
		[_pagingView setContentSize:CGSizeMake(800, 200)];
		[_pagingView setDelegate:self];
		[_pagingView setParentController:self];
		[_pagingView setBackgroundColor:[UIColor clearColor]];
		[_pagingView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
		[_pagingView setDecelerationRate:UIScrollViewDecelerationRateFast];
		[_pagingView setShowsHorizontalScrollIndicator:NO];
		[_pagingView setShowsVerticalScrollIndicator:YES];
		[_pagingView setAlwaysBounceHorizontal:YES];
		[_pagingView setScrollsToTop:NO];

		//create wrapper view
		_wrapperView = [[EAWrapperView alloc] initWithFrame:[[self view] bounds]];
		[_wrapperView setPagingView:_pagingView];
		[_wrapperView setBackgroundColor:[UIColor clearColor]];
		[_wrapperView addSubview:_pagingView];
		[[self view] addSubview:_wrapperView];
	}

	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)layoutControllers {
	//start x origin at 0
	CGFloat offsetX = 0;

	[_pivotPoints removeAllObjects];

	//create array to cycle through
	NSArray *viewControllers = [NSArray arrayWithArray:_viewControllers];

	//cycle through controllers
	for (UIViewController *controller in viewControllers) {
		//dont count it as a controller if it is being faded out (removed)
		if ([[controller view] alpha] != 1)
			continue;

		//alight x with previous controllers
		CGRect frame = [controller.view frame];
		frame.size.height = [_pagingView frame].size.height;
		frame.origin.x = offsetX;
		frame.origin.y = [[UIApplication sharedApplication] statusBarFrame].size.height;
		[UIView animateWithDuration:.4 animations: ^{
		    [controller.view setFrame:frame];
		}];

		[_pivotPoints addObject:[NSNumber numberWithFloat:offsetX]];
		offsetX += [controller.view frame].size.width;

		//create black 1px seperating view between controllers
		UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(-1, 44, 1, frame.size.height - 44)];
		[divider setBackgroundColor:[UIColor blackColor]];
		[[controller view] addSubview:divider];

		//this view fills in the black gap between controllers in the nav bar
		UIView *navigationBarConnector = [[UIView alloc] initWithFrame:CGRectMake(-1, 0, 1, 44)];
		[navigationBarConnector setBackgroundColor:[[EAThemeManager sharedManager] colorForNavigationBarBackground]];
		[[controller view] addSubview:navigationBarConnector];

		//this is a fake status bar that sits on top of views. This is done so they move with the views (And shrink)
		_fakeStatusBar = [[UIView alloc] initWithFrame:CGRectMake(-1, -1 * ([[UIApplication sharedApplication] statusBarFrame].size.height), [[controller view] bounds].size.width + 1, [[UIApplication sharedApplication] statusBarFrame].size.height)];
		[_fakeStatusBar setBackgroundColor:[[EAThemeManager sharedManager] colorForNavigationBarBackground]];
		[[controller view] addSubview:_fakeStatusBar];

		//if it has the pinch methods implemented, add the pinch gesture
		if ([controller respondsToSelector:@selector(viewDidPinch:)]) {
			UIPinchGestureRecognizer *pincher = [[UIPinchGestureRecognizer alloc] initWithTarget:controller action:@selector(viewDidPinch:)];
			[[controller view] addGestureRecognizer:pincher];
		}

		offsetX += 1; //1px gap between views
	}

	//update content size
	CGPoint currentOffset = [_pagingView contentOffset];
	[_pagingView setContentSize:CGSizeMake(offsetX - 1, _pagingView.bounds.size.height)];
	[_pagingView setContentOffset:CGPointMake(currentOffset.x, 0) animated:YES];
}

- (void)activateController:(UIViewController *)controller scrolling:(BOOL)scrolling {
	[self activateController:controller scrolling:scrolling pagingDirection:EAPagingDirectionRight];
}

- (void)activateController:(UIViewController *)controller scrolling:(BOOL)scrolling pagingDirection:(EAPagingDirection)pagingDirection {
	if (_activeController != controller) { //if it isnt active
		UIViewController *previouslyActivatedController = _activeController;
		if ([previouslyActivatedController respondsToSelector:@selector(foldingViewWillBecomeActive)])
			[previouslyActivatedController performSelector:@selector(foldingViewWillBecomeActive)];
	}

	_activeController = controller;

	if ([controller respondsToSelector:@selector(foldingViewWillBecomeActive)])
		[controller performSelector:@selector(foldingViewWillBecomeActive)];

	// if (scrolling)
	// [self scrollToController:controller pagingDirection:pagingDirection animated:YES];
}

- (void)stopAnimation {
	[[_pagingView layer] removeAllAnimations];
}

- (void)pushViewController:(UIViewController *)controller animated:(BOOL)animated {
	//dont add it if it already exists
	if ([_viewControllers containsObject:controller])
		return;

	//make sure the x frame is always to the right, the animations bring it in to the left
	CGRect frame = [[controller view] frame];
	frame.origin.x = 2000 *[_viewControllers count];

	[[controller view] setFrame:frame];

	//add the controller
	[self addChildViewController:controller];
	[_viewControllers addObject:controller];

	//put it on the paging view
	[_pagingView addSubview:[controller view]];

	[self layoutControllers];
}

- (void)activateTopController {
	[self activateController:_topViewController scrolling:YES];
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	[self layoutControllers];
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
	[super presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
	[super dismissViewControllerAnimated:flag completion:completion];
}

- (UIViewController *)popSingleViewController:(UIViewController *)poppingController animated:(BOOL)animated lastOperation:(BOOL)lastOperation {
	NSUInteger numControllers = [_viewControllers count];

	if (numControllers <= 1)
		return nil;

	if (!poppingController || ![_viewControllers containsObject:poppingController])
		return nil;

	NSUInteger indexOfController = [_viewControllers indexOfObject:poppingController];
	BOOL wasTopController = (poppingController == _topViewController);

	[poppingController removeFromParentViewController];

	[poppingController viewWillDisappear:NO];
	[[poppingController view] removeFromSuperview];
	[poppingController viewDidDisappear:NO];

	if (lastOperation && indexOfController > 0) {
		UIViewController *secondLastController = [_viewControllers objectAtIndex:(indexOfController - 1)];

		if (wasTopController) {
			[self activateController:secondLastController scrolling:animated];
		}
		else {
			[self layoutControllers];
			[self activateController:secondLastController scrolling:animated pagingDirection:EAPagingDirectionLeft];
		}
	}

	return poppingController;
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
	UIViewController *lastController = [_viewControllers lastObject];
	return [self popSingleViewController:lastController animated:animated lastOperation:YES];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
	return [self popToViewController:self.rootViewController animated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
	NSArray *popped = nil;
	NSUInteger indexOfController = [_viewControllers indexOfObject:viewController];
	if (indexOfController == NSNotFound)
		return [NSArray array];

	NSUInteger remaining = [_viewControllers count] - (indexOfController + 1);
	popped = [_viewControllers subarrayWithRange:NSMakeRange(indexOfController + 1, remaining)];

	for (UIViewController *controller in popped)
		[self popSingleViewController:controller animated:animated lastOperation:(controller == popped.lastObject)];

	return popped;
}

- (void)pushViewController:(UIViewController *)viewController afterPoppingToController:(UIViewController *)poppedToController {
	if (poppedToController == nil || [_viewControllers indexOfObject:poppedToController] == NSNotFound) {
		[self pushViewController:viewController animated:YES];
		return;
	}

	NSUInteger indexOfController = [_viewControllers indexOfObject:poppedToController];
	NSUInteger remaining = [_viewControllers count] - (indexOfController + 1);
	NSArray *popped = [_viewControllers subarrayWithRange:NSMakeRange(indexOfController + 1, remaining)];
	for (UIViewController *controller in popped)
		[self popSingleViewController:controller animated:YES lastOperation:NO];

	BOOL animatePush = YES;
	/*
	   if (
	    _pagingView.contentSize.width > _pagingView.width &&
	    poppedToController.containerView.right > (self.pagingView.contentSize.width - 5.))
	   {
	    animatePush = NO;
	   }*/

	[self pushViewController:viewController animated:animatePush];
}

- (NSArray *)popToActiveViewControllerAnimated:(BOOL)animated {
	return [self popToViewController:self.activeController animated:animated];
}

- (UIViewController *)visibleViewController {
	return _activeController;
}

- (UIViewController *)secondLastController {
	if ([_viewControllers count] <= 1)
		return nil;

	return [_viewControllers objectAtIndex:([_viewControllers count] - 2)];
}

- (UIViewController *)controllerBeforeController:(UIViewController *)controller {
	if ([_viewControllers count] <= 1)
		return nil;

	NSUInteger ind = [_viewControllers indexOfObject:controller];
	if (ind <= 0)
		return nil;

	return [_viewControllers objectAtIndex:(ind - 1)];
}

- (void)removeControllerAtIndex:(int)index {
	//get controller at index
	UIViewController *controllerToRemove = [_viewControllers objectAtIndex:index];

	[UIView animateWithDuration:.4f animations: ^{
	    [[controllerToRemove view] setAlpha:0]; //animate its alpha to 0
	} completion: ^(BOOL finished) {
	    //remove it when complete
	    if ([_viewControllers count] - 1 >= index) {
	        [[controllerToRemove view] removeFromSuperview];
	        [_viewControllers removeObjectAtIndex:index];
	        [self layoutControllers];
		}
	}];
}

- (void)scrollToController:(UIViewController *)controller {
	if (![_viewControllers containsObject:controller])
		return;
}

@end
