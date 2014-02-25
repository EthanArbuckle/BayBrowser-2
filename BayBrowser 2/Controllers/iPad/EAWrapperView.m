//
//  EAWrapperView.m
//  EAPanedNavigationController
//
//  Created by Ethan Arbuckle on 2/13/14.
//  Copyright (c) 2014 Ethan Arbuckle. All rights reserved.
//

#import "EAWrapperView.h"

@implementation EAWrapperView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	if (point.x < 50 &&
	    (
	        (point.y > 158 && point.y < (self.bounds.size.height / 2. - 146.))  ||
	        (point.y < (self.bounds.size.height  - 40.) && point.y > self.bounds.size.height  - (self.bounds.size.height  / 2.) + 106.)
	    )) {
		return [super hitTest:CGPointMake(53, point.y) withEvent:event];
	}

	return [super hitTest:point withEvent:event];
}

@end
