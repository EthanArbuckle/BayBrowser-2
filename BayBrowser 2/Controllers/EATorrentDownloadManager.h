//
//  EATorrentDownloadManager.h
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/17/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAiPhoneDelegate.h"
#import "Controller.h"
#import "Torrent.h"
#import "EACustomTorrentCell.h"

@interface EATorrentDownloadManager : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UITableView *torrentsTable;
@property (nonatomic, strong) NSMutableArray *allTorrents;

- (id)initAsiPad:(BOOL)isPad;
- (void)save;
- (void)update:(EACustomTorrentCell *)cell;
- (void)performUpdateOnCell:(EACustomTorrentCell *)cell withTorrent:(Torrent *)torrent;

@end
