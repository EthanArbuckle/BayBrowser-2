//
//  EAFileBrowser.h
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/30/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EACustomFileCell.h"
#import "EAMusicPlayerController.h"
#import "EATextFileController.h"
#import "EAImageFileController.h"
#import "GCDWebServer.h"
#import "EAiPhoneDelegate.h"

@interface EAFileBrowser : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UITableView *filesTable;
@property (nonatomic, strong) NSMutableArray *files;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) GCDWebServer *webServer;
@property (nonatomic, strong) UINavigationBar *navBar;
@property (nonatomic) BOOL isPad;

- (id)initWithPath:(NSString *)sentPath;
- (id)initWithPath:(NSString *)sentPath isPad:(BOOL)isPad;
- (void)tappedEditButton;
- (void)tappedTrashIcon;
- (void)tappedWebButton;

@end