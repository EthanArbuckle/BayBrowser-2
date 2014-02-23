//
//  EASettingsController.h
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 12/9/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EADynamicPostsController.h"
#import "EAiPhoneDelegate.h"
#import "EADynamicPostsController.h"
#import "TSMessage.h"
#import "EASettingsController.h"

@interface EASettingsController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) UILabel *lMaximumConnections;
@property (nonatomic, strong) UILabel *lConnectionsPTorrent;
@property (nonatomic, strong) UILabel *lUploadLimit;
@property (nonatomic, strong) UILabel *lDownloadLimit;
@property (nonatomic) BOOL isPad;

- (id)initAsPad:(BOOL)isPad;
- (void)maxConnectionsValueChanged:(UISlider *)sender;
- (void)connectionsPTorrentChanged:(UISlider *)sender;
- (void)enableUploadChanged:(UISwitch *)sender;
- (void)uploadLimitChanged:(UISlider *)sender;
- (void)enableDownloadChanged:(UISwitch *)sender;
- (void)downloadLimitChanged:(UISlider *)sender;

@end
