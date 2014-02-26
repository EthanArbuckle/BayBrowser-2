//
//  EAiPhoneDelegate.h
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/11/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAThemeManager.h"
#import "EAProgressBar.h"
#import "Controller.h"
#import "EAAppSwitcherPreviewOverlay.h"
#import "EAPanedNavigationController.h"
#import "EAPullOutTableController.h"
#import "EANetworkSpeedOverlay.h"

@class EAPullOutTableController;

@interface EAiPhoneDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) EAProgressBar *universalProgressIndicator;
@property (nonatomic, strong) Controller *torrentController;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRunner;
@property (nonatomic, strong) EAPullOutTableController *pullOutMenu;

//temp var for ipad until i rework the delegates
@property (nonatomic, strong) EAPanedNavigationController *rootStackController;

@end
