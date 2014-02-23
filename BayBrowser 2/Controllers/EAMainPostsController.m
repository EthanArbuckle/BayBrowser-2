//
//  EAViewController.m
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/11/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import "EAMainPostsController.h"

@implementation EAMainPostsController

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
    [[self view] setBackgroundColor:[UIColor clearColor]];
	//dont want to see through nav bar
	//[[[self navigationController] navigationBar] setTranslucent:NO];
    
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
        [title setTitle:@"All"];
        [navBar pushNavigationItem:title animated:NO];
        
        [[self view] addSubview:navBar];
    }
    else
        tableView = [[EACustomPostsTableView alloc] initWithFrame:[[self view] bounds]];
    
	__weak EACustomPostsTableView *tableView_ = tableView;
    
	//add search bar/sort by
	[tableView addHeader];
    
    //append on to url for 'sort by'
	[[tableView urlInformation] setObject:@"/top/all/" forKey:@"scheme"];
    
	//set posts to load first
	[tableView setInitialPostsBlock: ^{
	    [[tableView_ pirateAPI] getTop100Posts];
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
        [UIView animateWithDuration:.2 animations:^{
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
