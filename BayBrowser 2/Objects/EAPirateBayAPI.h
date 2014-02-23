//
//  EAPirateBayAPI.h
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/11/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFHpple.h"
#import "GTMNSString+HTML.h"
#import "AFNetworking.h"

@protocol EAPirateBayAPIDelegate <NSObject>

- (void)recieveResultsFromAPI:(NSDictionary *)results;
- (void)recieveResultsFromAPIForNextPage:(NSDictionary *)results;
- (void)failedToRecieveResultsWithError:(NSError *)error;
- (void)recieveProgressFromAPI:(float)prog;

@end

@interface EAPirateBayAPI : NSObject

- (void)getCommentInformationFromTorrentWithID:(NSString *)torrentID;
- (void)getDetailsAboutTorrentWithID:(NSString *)torrentID;
- (void)getTop100Posts;
- (void)getResultsForSearchQuery:(NSString *)search;
- (void)scrapeInformationFromURL:(NSURL *)url isPageOne:(BOOL)pge;

@property (retain, nonatomic) id <EAPirateBayAPIDelegate> delegate;

@end
