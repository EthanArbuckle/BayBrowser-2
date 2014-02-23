//
//  EAImagesView.h
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/14/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAPirateBayAPI.h"
#import "AFImageViewer.h"
#import "EAThemeManager.h"

@interface EAImagesView : UIView <EAPirateBayAPIDelegate>

- (id)initWithTorrent:(NSDictionary *)passedTorrent andFrame:(CGRect)frame;

@property (nonatomic, strong) NSMutableArray *imagesArray;

@end
