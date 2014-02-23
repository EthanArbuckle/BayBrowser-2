//
//  EAThemeManager.m
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/12/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import "EAThemeManager.h"

@implementation EAThemeManager

#pragma mark - EAThemeManager
+ (EAThemeManager *)sharedManager {
	static EAThemeManager *sharedManager = nil;
	if (sharedManager == nil)
		sharedManager = [[EAThemeManager alloc] init];
	return sharedManager;
}

- (UIColor *)colorForCellBackground {
	return [UIColor colorWithRed:255.0f / 255.0f green:255.0f / 255.0f blue:255.0f / 255.0f alpha:1];
}

- (UIColor *)colorForCellMainLabel {
	return [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
}

- (UIColor *)colorForCellDetailLabel {
	return [UIColor colorWithRed:30.0f / 255.0f green:33.0f / 255.0f blue:42.0f / 255.0f alpha:1.0f];
}

- (UIColor *)colorForNavigationBarBackground {
	return [UIColor colorWithRed:30.0f / 255.0f green:33.0f / 255.0f blue:42.0f / 255.0f alpha:1.0f];
}

- (UIColor *)colorforNavigationBarItems {
	return [UIColor colorWithRed:220.0f / 255.0f green:221.0f / 255.0f blue:225.0f / 255.0f alpha:1];
}

- (UIFont *)fontForCellMainLabel {
	return [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
}

- (UIFont *)fontForCellDetailLabel {
	return [UIFont fontWithName:@"HelveticaNeue" size:10];
}

@end
