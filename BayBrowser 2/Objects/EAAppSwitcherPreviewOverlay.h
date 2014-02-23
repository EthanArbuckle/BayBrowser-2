//
//  EAAppSwitcherPreviewOverlay.h
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 1/30/14.
//  Copyright (c) 2014 Ethan Arbuckle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAiPhoneDelegate.h"

@interface EAAppSwitcherPreviewOverlay : UIView <UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *activeTorrents;
@end
