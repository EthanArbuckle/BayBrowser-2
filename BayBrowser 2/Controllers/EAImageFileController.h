//
//  EAImageFileController.h
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 12/3/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+animatedGIF.h"
#import "AFImageViewer.h"
#import "EADynamicBlur.h"

@interface EAImageFileController : UIViewController

- (id)initWithPathToImage:(NSString *)imagePath;
- (id)initWithPathToImage:(NSString *)imagePath isPad:(BOOL)isPad;

@end
