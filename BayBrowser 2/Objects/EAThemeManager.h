//
//  EAThemeManager.h
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/12/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EAThemeManager.h"


@interface EAThemeManager : NSObject

+ (EAThemeManager *)sharedManager;

- (UIColor *)colorForCellBackground;
- (UIColor *)colorForCellMainLabel;
- (UIColor *)colorForCellDetailLabel;

- (UIColor *)colorForNavigationBarBackground;
- (UIColor *)colorforNavigationBarItems;

- (UIFont *)fontForCellMainLabel;
- (UIFont *)fontForCellDetailLabel;

@end
