//
//  EATextFIleController.h
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 12/2/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EATextFileController : UIViewController

- (id)initWithFilePath:(NSString *)filePath;
- (id)initWithFilePath:(NSString *)filePath isPad:(BOOL)isPad;

@end
