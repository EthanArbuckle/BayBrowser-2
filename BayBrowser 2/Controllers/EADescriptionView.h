//
//  EADescriptionView.h
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/13/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAPirateBayAPI.h"
#import "EAThemeManager.h"

@interface EADescriptionView : UIView <EAPirateBayAPIDelegate>

- (id)initWithTorrent:(NSDictionary *)passedTorrent andFrame:(CGRect)frame;

@property (nonatomic, strong) NSDictionary *passed;

@end
