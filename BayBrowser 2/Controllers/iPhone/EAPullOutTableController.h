//
//  EAPullOutTableController.h
//  EAPullOutMenu
//
//  Created by Ethan Arbuckle on 2/18/14.
//  Copyright (c) 2014 Ethan Arbuckle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EADynamicPostsController.h"
#import "EAMainPostsController.h"
#import "EATorrentDownloadManager.h"
#import "EAFileBrowser.h"
#import "EASettingsController.h"
#import "EADynamicBlur.h"

@interface EAPullOutTableController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *sideTable;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) UIViewController *mainViewController;
@property (nonatomic, strong) EADynamicBlur *blurView;
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic) BOOL isOpen;

- (void)tappedShowHide;
- (void)showTable;
- (void)hideTable;

@end
