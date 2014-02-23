//
//  EACustomPostsCell.m
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/12/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import "EACustomPostsCell.h"

int lastLocationOfFinger;

@implementation EACustomPostsCell

#pragma mark - EACustomPostsCell
- (id)init {
	if (self = [super init]) {
		//setup labels
		_titleLabel = [[UILabel alloc] init];
		_seedersLeechersLabel = [[UILabel alloc] init];
		_sizeLabel = [[UILabel alloc] init];
		_dataLabel = [[UILabel alloc] init];
        
		//customize labels
		[_titleLabel setFont:[[EAThemeManager sharedManager] fontForCellMainLabel]];
		[_titleLabel setTextColor:[[EAThemeManager sharedManager] colorForCellMainLabel]];
		[_titleLabel setText:@"!"];
		[_titleLabel setBackgroundColor:[UIColor clearColor]];
		[_titleLabel setLineBreakMode:NSLineBreakByWordWrapping]; //allows multiline
        
		[_seedersLeechersLabel setFont:[[EAThemeManager sharedManager] fontForCellDetailLabel]];
		[_seedersLeechersLabel setTextColor:[[EAThemeManager sharedManager] colorForCellDetailLabel]];
		[_seedersLeechersLabel setText:@"!"];
		[_seedersLeechersLabel setBackgroundColor:[UIColor clearColor]];
        
		[_sizeLabel setFont:[[EAThemeManager sharedManager] fontForCellDetailLabel]];
		[_sizeLabel setTextColor:[[EAThemeManager sharedManager] colorForCellDetailLabel]];
		[_sizeLabel setText:@"!"];
		[_sizeLabel setBackgroundColor:[UIColor clearColor]];
        
		[_dataLabel setFont:[[EAThemeManager sharedManager] fontForCellDetailLabel]];
		[_dataLabel setTextColor:[[EAThemeManager sharedManager] colorForCellDetailLabel]];
		[_dataLabel setText:@"!"];
		[_dataLabel setBackgroundColor:[UIColor clearColor]];
        
		[self setIsShowingMenu:NO];
        
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([self frame]), CGRectGetHeight([self frame]))];
		[_scrollView setContentSize:CGSizeMake(CGRectGetWidth([self frame]) + 74, CGRectGetHeight([self frame]))];
		[_scrollView setDelegate:self];
		[_scrollView setShowsHorizontalScrollIndicator:NO];
        
		_scrollViewButtonView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 74, 0.0f, 74, CGRectGetHeight(self.frame))];
		[self.scrollView addSubview:_scrollViewButtonView];
        
        
		_scrollViewContentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
		_scrollViewContentView.backgroundColor = [UIColor whiteColor];
		[_scrollView addSubview:_scrollViewContentView];
		UITapGestureRecognizer *contentTaps = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotContentTap)];
		[_scrollViewContentView addGestureRecognizer:contentTaps];
        
        [_scrollView setScrollsToTop:NO];
        
		//add labels to cell
		/*[[self contentView] addSubview:titleLabel];
         [[self contentView] addSubview:seedersLeechersLabel];
         [[self contentView] addSubview:sizeLabel];
         [[self contentView] addSubview:dataLabel]; */
		[[self scrollView] addSubview:_titleLabel];
		[[self scrollView] addSubview:_seedersLeechersLabel];
		[[self scrollView] addSubview:_sizeLabel];
		[[self scrollView] addSubview:_dataLabel];
		[[self contentView] addSubview:_scrollView];
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
    
	//position labels
	[_titleLabel setFrame:CGRectMake(15, 5, [[self contentView] frame].size.width - 19, [[self contentView] bounds].size.height - 30)];
	[_seedersLeechersLabel setFrame:CGRectMake(15, [_titleLabel bounds].size.height + 5, 180, 21)];
	[_sizeLabel setFrame:CGRectMake(119, [_titleLabel bounds].size.height + 5, 72, 21)];
	[_dataLabel setFrame:CGRectMake(185, [_titleLabel bounds].size.height + 5, 157, 21)];
    
	_scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) + 74, CGRectGetHeight(self.bounds));
	_scrollView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
	_scrollViewButtonView.frame = CGRectMake(CGRectGetWidth(self.bounds) - 74, 0.0f, 74, CGRectGetHeight(self.bounds));
	
    _scrollViewContentView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
	_moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_moreButton setBackgroundColor:[UIColor colorWithRed:232.0f / 255.0f green:48.0f / 255.0f blue:76.0f / 255.0f alpha:1.0f]];
	[_moreButton setFrame:CGRectMake(0, 0.0f, 74, CGRectGetHeight(self.frame))];
	[_moreButton setTitle:@"More" forState:UIControlStateNormal];
	[_moreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[_moreButton addTarget:self action:@selector(tappedButton) forControlEvents:UIControlEventTouchUpInside];
	[_scrollViewButtonView addSubview:_moreButton];
}

#pragma mark - UIScrollView delegate
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollViews withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
	if (_scrollView.contentOffset.x > 74) {
		targetContentOffset->x = 74;
	}
	else {
		*targetContentOffset = CGPointZero;
        
		// Need to call this subsequently to remove flickering. Strange.
		dispatch_async(dispatch_get_main_queue(), ^{
		    [scrollViews setContentOffset:CGPointZero animated:YES];
		});
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollViews {
	if (scrollViews.contentOffset.x < 0.0f) {
		scrollViews.contentOffset = CGPointZero;
	}
	_scrollViewButtonView.frame = CGRectMake(scrollViews.contentOffset.x + (CGRectGetWidth(self.bounds) - 74), 0.0f, 74, CGRectGetHeight(self.bounds));
    
	if (_scrollView.contentOffset.x >= 74) {
		if (!self.isShowingMenu) {
			self.isShowingMenu = YES;
            //remove these causes the bottom scroll view to flicker
			/*dispatch_async(dispatch_get_main_queue(), ^{
			    [self setAccessoryType:UITableViewCellAccessoryNone];
			}); */
		}
	}
	else if (_scrollView.contentOffset.x == 0.0f) {
		if (self.isShowingMenu) {
			self.isShowingMenu = NO;
			/*dispatch_async(dispatch_get_main_queue(), ^{
			    [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
			});*/
		}
	}
}

- (void)gotContentTap {
	if ([_delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
		UITableView *table = (UITableView *)[self superview];
		if (![table isKindOfClass:[UITableView class]]) {
			table = (UITableView *)self.superview.superview;
		}
        
		NSIndexPath *indexPath = [table indexPathForCell:self];
        
		[self.delegate tableView:table didSelectRowAtIndexPath:indexPath];
	}
}

#pragma mark - EACustomPostsCellDelegate
- (void)tappedButton {
	[_delegate undersideOfCell:self WasTappedAtIndex:2];
}

@end
