//
//  EACustomPostsCell.h
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/12/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAThemeManager.h"

@protocol EACustomPostsCellDelegate <NSObject>

- (void)undersideOfCell:(UITableViewCell *)cell WasTappedAtIndex:(int)index;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface EACustomPostsCell : UITableViewCell <UIScrollViewDelegate>

- (id)init;
- (void)layoutSubviews;

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *seedersLeechersLabel;
@property (nonatomic, retain) UILabel *sizeLabel;
@property (nonatomic, retain) UILabel *dataLabel;
@property (nonatomic, retain) id <EACustomPostsCellDelegate> delegate;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIView *scrollViewContentView;
@property (nonatomic, retain) UIView *scrollViewButtonView;
@property (nonatomic, assign) BOOL isShowingMenu;
@property (nonatomic, retain) UIButton *moreButton;

@end
