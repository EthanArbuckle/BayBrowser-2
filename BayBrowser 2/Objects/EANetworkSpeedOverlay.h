//
//  EANetworkSpeesOverlay.h
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 2/25/14.
//  Copyright (c) 2014 Ethan Arbuckle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "EAThemeManager.h"
#import "EAiPhoneDelegate.h"
#import "NSStringAdditions.h"

@interface EANetworkSpeedOverlay : UIView

@property (nonatomic, strong) UILabel *upLabel;
@property (nonatomic, strong) UILabel *downLabel;

- (id)initAsPad:(BOOL)isPad;
- (void)removeNetworkOverlay;
- (void)addNetworkOverlay;
- (void)update;

@end
