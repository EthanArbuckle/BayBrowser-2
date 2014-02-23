//
//  EADynamicPostsController.h
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/18/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EACustomPostsTableView.h"

@interface EADynamicPostsController : UIViewController

- (id)initWithScheme:(NSString *)pScheme;

@property (nonatomic, strong) NSString *scheme;
@property (nonatomic) BOOL isPad;
@property (nonatomic, strong) NSString *titleForNavigationBar;

@end
