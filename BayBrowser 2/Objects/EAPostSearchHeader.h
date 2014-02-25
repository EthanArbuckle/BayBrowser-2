//
//  EAPostSearchHeader.h
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/24/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAThemeManager.h"

typedef enum {
	EAPostSearchHeaderSortBySeeders,
	EAPostSearchHeaderSortByLeechers,
	EAPostSearchHeaderSortByUploaded,
	EAPostSearchHeaderSortBySize,
	EAPostSearchHeaderSortByUploader
} EAPostSearchHeaderSortByType;


@protocol EAPostSearchHeaderDelegate <NSObject>

- (void)didChangeSortBy:(EAPostSearchHeaderSortByType)sortByType;
- (void)didEnterSearchText:(NSString *)searchString;

@end

@interface EAPostSearchHeader : UIView <UIActionSheetDelegate, UITextFieldDelegate>

- (void)sortButtonTapped;

@property (nonatomic, retain) UITextField *searchTextBox;
@property (nonatomic, retain) UIButton *sortButton;
@property (nonatomic, retain) id <EAPostSearchHeaderDelegate> delegate;

@end
