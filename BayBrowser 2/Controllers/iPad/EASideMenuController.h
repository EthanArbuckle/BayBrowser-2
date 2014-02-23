//
//  EASideMenuController.h
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 2/12/14.
//  Copyright (c) 2014 Ethan Arbuckle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAiPhoneDelegate.h"
#import "EAMainPostsController.h"
#import "EADynamicPostsController.h"
#import "EATorrentDownloadManager.h"
#import "EAFileBrowser.h"
#import "EASettingsController.h"

@interface EASideMenuController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *sideMenuTable;
@property (nonatomic, strong) NSMutableArray *categoryList;
@property (nonatomic, strong) NSMutableArray *schemeList;
@property (nonatomic, strong) NSMutableArray *loadedControllers;

@end
