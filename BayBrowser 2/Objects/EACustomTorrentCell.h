//
//  EACustomTorrentCell.h
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/28/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EACustomTorrentCell : UITableViewCell

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *statusLabel;
@property (nonatomic, retain) UILabel *progressLabel;
@property (nonatomic, retain) UIProgressView *progressBar;

@end
