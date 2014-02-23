//
//  EACustomPostsTableView.h
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/24/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "EAiPhoneDelegate.h"
#import "JMSlider.h"
#import "EAPirateBayAPI.h"
#import "EACustomPostsCell.h"
#import "EANSString+Truncate.h"
#import "EAThemeManager.h"
#import "EAPostSearchHeader.h"
#import "EATorrentDetailController.h"
#import "GCDWebServer.h"
#import "TSMessage.h"

@interface EACustomPostsTableView : UIView <UITableViewDataSource, UITableViewDelegate, EAPirateBayAPIDelegate, EACustomPostsCellDelegate, UIActionSheetDelegate, EAPostSearchHeaderDelegate, JMSliderDelegate, MFMailComposeViewControllerDelegate>

- (void)addHeader;
- (void)addFooter;
- (void)start;
- (void)refreshData;

@property (nonatomic, strong) UITableView *postsTableView;
@property (nonatomic, strong) NSMutableDictionary *allPosts;
@property (nonatomic, strong) EAPirateBayAPI *pirateAPI;
@property (nonatomic, strong) JMSlider *postFooter;
@property (nonatomic, strong) EAPostSearchHeader *postHeader;
@property (nonatomic, strong) NSMutableDictionary *urlInformation;
@property (nonatomic, strong) void (^initialPostsBlock)(void);
@property (nonatomic, strong) UIViewController *parent;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic) BOOL isPad;

@end
