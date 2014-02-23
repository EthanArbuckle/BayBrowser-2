//
//  EACustomCommentsCell.h
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/13/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EACustomCommentsCell : UITableViewCell

- (id)init;
- (void)layoutSubviews;

@property (nonatomic, retain) UILabel *commentText;
@property (nonatomic, retain) UILabel *authorLabel;
@property (nonatomic, retain) UILabel *times;

@end
