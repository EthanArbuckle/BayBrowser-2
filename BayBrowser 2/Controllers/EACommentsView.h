//
//  EACommentsView.h
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/13/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAPirateBayAPI.h"
#import "EACustomCommentsCell.h"
#import "EAThemeManager.h"

@interface EACommentsView : UIView <UITableViewDataSource, UITableViewDelegate, EAPirateBayAPIDelegate>

- (id)initWithTorrentID:(NSString *)torrentID andFrame:(CGRect)frame;

@property (nonatomic, strong) NSDictionary *commentInformation;
@property (nonatomic, strong) UITableView *commentsTable;

@end
