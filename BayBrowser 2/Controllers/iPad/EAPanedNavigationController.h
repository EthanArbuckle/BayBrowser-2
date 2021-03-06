//
//  EAPanedNavigationController.h
//  EAPanedNavigationController
//
//  Created by Ethan Arbuckle on 2/12/14.
//  Copyright (c) 2014 Ethan Arbuckle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAPagingScollView.h"
#import "EAWrapperView.h"
#import "EAThemeManager.h"
#import "KGNoise.h"

typedef enum {
	EAPagingDirectionRight = 0,
	EAPagingDirectionLeft,
} EAPagingDirection;

@class EAPagingScollView;

@interface EAPanedNavigationController : UIViewController <UIScrollViewDelegate>

@property (strong) NSMutableArray *viewControllers;
@property (strong, readonly) UIViewController *activeController;
@property (strong) UIViewController *rootViewController;
@property (strong) UIViewController *topViewController;
@property (strong) EAPagingScollView *pagingView;
@property (strong) EAWrapperView *wrapperView;
@property (strong) UIView *fakeStatusBar;

- (id)initWithRootViewController:(UIViewController *)rootViewController;
- (void)layoutControllers;
- (void)pushViewController:(UIViewController *)controller animated:(BOOL)animated;
- (UIViewController *)visibleViewController;
- (UIViewController *)secondLastController;
- (UIViewController *)controllerBeforeController:(UIViewController *)controller;
- (void)removeControllerAtIndex:(int)index;
- (void)removeAllControllersAfterController:(UIViewController *)controller;
@end
