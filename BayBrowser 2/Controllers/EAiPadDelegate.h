//
//  EAiPadDelegate.h
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 2/12/14.
//  Copyright (c) 2014 Ethan Arbuckle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Controller.h"
#import "EAPanedNavigationController.h"
#import "EAProgressBar.h"
#import "EASideMenuController.h"
#import "EAAppSwitcherPreviewOverlay.h"
#import "EANetworkSpeedOverlay.h"

@interface EAiPadDelegate : UIResponder <UIApplicationDelegate, NSObject>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) Controller *torrentController;
@property (nonatomic, strong) EAProgressBar *universalProgressIndicator;
@property (nonatomic, strong) EAPanedNavigationController *rootStackController;

@end
