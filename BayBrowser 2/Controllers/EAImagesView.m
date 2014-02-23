//
//  EAImagesView.m
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/14/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import "EAImagesView.h"

@implementation EAImagesView

#pragma mark - UIViewController
- (id)initWithTorrent:(NSDictionary *)passedTorrent andFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
    
	[self setBackgroundColor:[UIColor whiteColor]];
    
	//setup array and api
	_imagesArray = [[NSMutableArray alloc] init];
	EAPirateBayAPI *api = [[EAPirateBayAPI alloc] init];
	[api setDelegate:self];
    
	//get links
	[api getDetailsAboutTorrentWithID:[passedTorrent objectForKey:@"id"]];
    
    
	return self;
}

#pragma mark - EAPirateBayAPI delegate
- (void)recieveResultsFromAPI:(NSDictionary *)results {
    
    //array of urls
	NSArray *stringURLs = [results objectForKey:@"images"];
    
    //if it is empty, create label
	if ([stringURLs count] < 1) {
		UILabel *noImgs = [[UILabel alloc] initWithFrame:CGRectMake(([self bounds].size.width / 2) - 50, 130, 100, 20)];
		[noImgs setFont:[[EAThemeManager sharedManager] fontForCellMainLabel]];
		[noImgs setTextColor:[[EAThemeManager sharedManager] colorForCellMainLabel]];
		[noImgs setText:@"No Images!"];
		[noImgs setTextAlignment:NSTextAlignmentCenter];
		[noImgs setBackgroundColor:[UIColor clearColor]];
		[self addSubview:noImgs];
	}
	else {
		for (NSString *urlString in stringURLs) {
			NSURL *realURL = [NSURL URLWithString:[urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
			if (realURL)
				[_imagesArray addObject:realURL];
		}
        
		//create gallery
		AFImageViewer *gallery = [[AFImageViewer alloc] initWithFrame:CGRectMake(0, 0, [self frame].size.width, [self frame].size.height + 60)];
		[self addSubview:gallery];
		[gallery setImagesUrls:_imagesArray];
	}
}

- (void)failedToRecieveResultsWithError:(NSError *)error {
	NSLog(@"failed with error: %@", error);
}

- (void)recieveResultsFromAPIForNextPage:(NSDictionary *)results {
}

- (void)recieveProgressFromAPI:(float)prog {
}

@end
