//
//  EATorrentDetailController.h
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/12/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EADescriptionView.h"
#import "EACommentsView.h"
#import "EAImagesView.h"
#import "EAiPhoneDelegate.h"
#import "EAiPadDelegate.h"
#import "TSMessage.h"

@interface EATorrentDetailController : UIViewController <UIActionSheetDelegate>

@property (nonatomic, strong) UISegmentedControl *viewPickerSegment;
@property (nonatomic, strong) NSDictionary *torrentDictionary;
@property (nonatomic, strong) EADescriptionView *descriptionView;
@property (nonatomic, strong) EACommentsView *commentsView;
@property (nonatomic, strong) EAImagesView *imagesView;
@property (nonatomic) BOOL isPad;

- (void)downloadPrompt;
- (void)didChangeSegmentControl:(UISegmentedControl *)sender;
- (void)replaceCurrentViewWith:(UIView *)viewToAdd;

@end
