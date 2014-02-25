//
//  EAPostSearchHeader.m
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/24/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import "EAPostSearchHeader.h"
#import <QuartzCore/QuartzCore.h>

@implementation EAPostSearchHeader

#pragma mark - EAPostSearchHeader
- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self setBackgroundColor:[[EAThemeManager sharedManager] colorForNavigationBarBackground]];

		//create search box
		_searchTextBox = [[UITextField alloc] initWithFrame:CGRectMake(4, 5, [self bounds].size.width - 75, 30)];
		[_searchTextBox setClipsToBounds:YES];
		[[_searchTextBox layer] setBorderWidth:0];
		[[_searchTextBox layer] setCornerRadius:15];
		[_searchTextBox setDelegate:self];
		[_searchTextBox setBackgroundColor:[UIColor lightGrayColor]];
		[_searchTextBox setKeyboardAppearance:UIKeyboardAppearanceDark];
		[_searchTextBox setAutocorrectionType:UITextAutocorrectionTypeNo];
		[_searchTextBox setPlaceholder:@"Search"];

		//add padding
		UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 30)];
		[_searchTextBox setLeftView:paddingView];
		[_searchTextBox setLeftViewMode:UITextFieldViewModeAlways];

		[self addSubview:_searchTextBox];

		//create sort button
		_sortButton = [[UIButton alloc] initWithFrame:CGRectMake(([self bounds].size.width) - 65, 8, 55, 25)];
		[_sortButton setTitle:@"SE" forState:UIControlStateNormal];
		[_sortButton setBackgroundColor:[UIColor lightGrayColor]];
		[_sortButton setClipsToBounds:YES];
		[[_sortButton layer] setBorderWidth:0];
		[[_sortButton layer] setCornerRadius:12];
		[_searchTextBox setReturnKeyType:UIReturnKeyDone];
		[[_sortButton titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue" size:10]];
		[_sortButton addTarget:self action:@selector(sortButtonTapped) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_sortButton];
	}

	return self;
}

- (void)sortButtonTapped {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Sort By" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Seeders", @"Leechers", @"Uploaded", @"Size", @"Uploader", nil];
	[actionSheet showInView:self];
}

#pragma mark - UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	//this SortBy protocol makes it easier to see
	if (buttonIndex == 0) {
		[_delegate didChangeSortBy:EAPostSearchHeaderSortBySeeders];
		[_sortButton setTitle:@"SE" forState:UIControlStateNormal];
	}
	else if (buttonIndex == 1) {
		[_delegate didChangeSortBy:EAPostSearchHeaderSortByLeechers];
		[_sortButton setTitle:@"LE" forState:UIControlStateNormal];
	}
	else if (buttonIndex == 2) {
		[_delegate didChangeSortBy:EAPostSearchHeaderSortByUploaded];
		[_sortButton setTitle:@"Uploaded" forState:UIControlStateNormal];
	}
	else if (buttonIndex == 3) {
		[_delegate didChangeSortBy:EAPostSearchHeaderSortBySize];
		[_sortButton setTitle:@"Size" forState:UIControlStateNormal];
	}
	else if (buttonIndex == 4) {
		[_delegate didChangeSortBy:EAPostSearchHeaderSortByUploader];
		[_sortButton setTitle:@"Uploader" forState:UIControlStateNormal];
	}
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[_sortButton setTitle:@"SE" forState:UIControlStateNormal];
	[textField resignFirstResponder];
	[_delegate didEnterSearchText:[textField text]];
	return YES;
}

@end
