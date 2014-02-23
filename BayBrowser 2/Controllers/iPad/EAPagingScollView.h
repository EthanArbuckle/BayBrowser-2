//
//  EAPagingScollView.h
//  EAPanedNavigationController
//
//  Created by Ethan Arbuckle on 2/12/14.
//  Copyright (c) 2014 Ethan Arbuckle. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EAPanedNavigationController;

@interface EAPagingScollView : UIScrollView <UIGestureRecognizerDelegate>

@property (weak) EAPanedNavigationController *parentController;
@property NSUInteger numDelayedTouches;
@property NSUInteger numPanTouches;

@end
