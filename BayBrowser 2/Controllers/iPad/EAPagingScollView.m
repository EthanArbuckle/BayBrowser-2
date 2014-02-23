//
//  EAPagingScollView.m
//  EAPanedNavigationController
//
//  Created by Ethan Arbuckle on 2/12/14.
//  Copyright (c) 2014 Ethan Arbuckle. All rights reserved.
//

#import "EAPagingScollView.h"

@implementation EAPagingScollView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        //gesture only needs 1 finger
        [[self panGestureRecognizer] setMaximumNumberOfTouches:1];
        [[self panGestureRecognizer] setMinimumNumberOfTouches:1];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        
        return (_numPanTouches == 0 && _numDelayedTouches == 0);
    }
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    //set appropriate int for gestures number of touches
    NSString *gestureClass = NSStringFromClass([gestureRecognizer class]);
    if ([gestureClass rangeOfString:@"DelayedTouches"].location != NSNotFound)
        _numDelayedTouches = [gestureRecognizer numberOfTouches];
    
    if ([gestureClass rangeOfString:@"PanGesture"].location != NSNotFound)
        _numPanTouches = [gestureRecognizer numberOfTouches];
    
    return YES;
    
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    
    return [super touchesShouldCancelInContentView:view];
    
}
@end
