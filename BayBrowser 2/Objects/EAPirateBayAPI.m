//
//  EAPirateBayAPI.m
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/11/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import "EAPirateBayAPI.h"

@implementation EAPirateBayAPI

/*    WARNING: STAY AWAY FROM THIS. SERIOUSLY. YOU DONT EVEN WANT TO TRY TO UNDERSTAND THIS. YOU HAVE BEEN WARNED   */


#pragma mark - EAPirateBayAPI
- (void)getCommentInformationFromTorrentWithID:(NSString *)torrentID {
	//construct url
	NSString *constructUrl = [NSString stringWithFormat:@"%@/torrent/%@", SETTINGS_BASE_URL, torrentID];
	NSURL *url = [NSURL URLWithString:constructUrl];
    
	AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:url]];
	[op setCompletionBlockWithSuccess: ^(AFHTTPRequestOperation *operation, id responseObject) {
	    //setup parser
	    TFHpple *htmlParser = [TFHpple hppleWithHTMLData:responseObject];
        
	    //parse comments, comment times, and usernames - fairly confusing
        
        //setup arrays
	    NSArray *commentsUsernamesNodes = [htmlParser searchWithXPathQuery:@"//div[@id='comments']/div"];
	    NSMutableArray *commentEntries = [[NSMutableArray alloc] init];
	    NSMutableArray *usernameEntries = [[NSMutableArray alloc] init];
	    NSMutableArray *commentTimesEntries = [[NSMutableArray alloc] init];
        
	    for (TFHppleElement * element in commentsUsernamesNodes) { //top level nodes
	        NSArray *commentsArray = [element childrenWithTagName:@"div"]; //descriptions are broken up in divs
	        for (TFHppleElement * elementT2 in commentsArray) { //second tier nodes
                
	            NSMutableString *commentStack = [[NSMutableString alloc] initWithFormat:@"%@", [elementT2 text]]; //get most comments
                
	            if ([[commentStack stringByReplacingOccurrencesOfString:@" " withString:@""] length] >= 1) { //only if there is text
	                
                    //get links
                    NSArray *linkArray = [elementT2 childrenWithTagName:@"a"];
	                for (TFHppleElement * link in linkArray) {
	                    NSString *commentTextPre = [[NSMutableString stringWithFormat:@"%@", [link text]] gtm_stringByUnescapingFromHTML]; //hide html code
	                    [commentStack appendString:[commentTextPre stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
					}
				}
                
                //only if there is text
	            if ([[commentStack stringByReplacingOccurrencesOfString:@" " withString:@""] length] >= 2)
					[commentEntries addObject:[[commentStack stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]gtm_stringByUnescapingFromHTML]]; //avoid html + whitespace
			}
            
            //get username
	        NSArray *usernameArray = [element childrenWithTagName:@"p"];
            
	        for (TFHppleElement * elementT3 in usernameArray) {
	            for (TFHppleElement * usernameLevtwo in[elementT3 children]) {
                    
	                NSString *usernameText = [usernameLevtwo text];
	                if ([[usernameText stringByReplacingOccurrencesOfString:@" " withString:@""] length] >= 1) { //only if user has text
	                    [usernameEntries addObject:[usernameText gtm_stringByUnescapingFromHTML]];
					}
                    
                    //get date
	                if ([[[usernameLevtwo content] stringByReplacingOccurrencesOfString:@" " withString:@""] length] > 5) {
	                    NSString *dateTime = [[usernameLevtwo content] stringByReplacingOccurrencesOfString:@" at " withString:@""];
	                    [commentTimesEntries addObject:[dateTime stringByReplacingOccurrencesOfString:@" CET:" withString:@""]];
					}
				}
			}
		}
        
	    //send to delegate method
	    [_delegate recieveResultsFromAPI:[[NSDictionary alloc] initWithObjectsAndKeys:commentEntries, @"comments", usernameEntries, @"usernames", commentTimesEntries, @"times", nil]];
	} failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
	    [_delegate failedToRecieveResultsWithError:error];
	}];
	[op start];
}

- (void)getDetailsAboutTorrentWithID:(NSString *)torrentID {
	//construct url
	NSString *constructUrl = [NSString stringWithFormat:@"%@/torrent/%@", SETTINGS_BASE_URL, torrentID];
	NSURL *url = [NSURL URLWithString:constructUrl];
    
	AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:url]];
	[op setCompletionBlockWithSuccess: ^(AFHTTPRequestOperation *operation, id responseObject) {
	    //setup parser
	    TFHpple *htmlParser = [TFHpple hppleWithHTMLData:responseObject];
        
	    //parse description. Also grabs links in text
	    NSArray *descriptionNodes = [htmlParser searchWithXPathQuery:@"//div[@class='nfo']/pre"];
	    NSMutableString *descriptionEntries = [[NSMutableString alloc] init];
	    NSMutableArray *imageEntries = [[NSMutableArray alloc] init];
	    for (TFHppleElement * element in descriptionNodes) {
	        for (TFHppleElement * elementD in[element children]) {
	            if ([elementD text]) {
	                [descriptionEntries appendString:[elementD text]];
	                if ([[elementD text] rangeOfString:@".png"].location != NSNotFound || [[elementD text] rangeOfString:@".jpg"].location != NSNotFound || [[elementD text] rangeOfString:@".jpeg"].location != NSNotFound) {
	                    [imageEntries addObject:[elementD text]];
					}
				}
	            if ([elementD content])
					[descriptionEntries appendString:[[elementD content] gtm_stringByUnescapingFromHTML]];
			}
		}
        
	    //send to delegate method
	    [_delegate recieveResultsFromAPI:[[NSDictionary alloc] initWithObjectsAndKeys:descriptionEntries, @"description", imageEntries, @"images", nil]];
	} failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
	    [_delegate failedToRecieveResultsWithError:error];
	}];
    
    [op setDownloadProgressBlock: ^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
	    [_delegate recieveProgressFromAPI:(float)totalBytesRead / 10000]; //Content-Length isnt provided, so this is just a guess
	}];
    
	[op start];
}

- (void)getTop100Posts {
	//construct url
	NSString *constructUrl = [NSString stringWithFormat:@"%@/top/all", SETTINGS_BASE_URL];
	NSURL *url = [NSURL URLWithString:constructUrl];
    
	[self scrapeInformationFromURL:url isPageOne:YES];
}

- (void)getResultsForSearchQuery:(NSString *)search {
	//create search url
	NSString *constructUrl = [NSString stringWithFormat:@"%@/search/%@/0/99/0", SETTINGS_BASE_URL, search];
	NSURL *url = [NSURL URLWithString:[constructUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
	[self scrapeInformationFromURL:url isPageOne:YES];
}

- (void)scrapeInformationFromURL:(NSURL *)url isPageOne:(BOOL)pge {
	AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:url]];
	[op setCompletionBlockWithSuccess: ^(AFHTTPRequestOperation *operation, id responseObject) {
	    //setup parser
	    TFHpple *htmlParser;
	    htmlParser = [TFHpple hppleWithHTMLData:responseObject];
        
	    //parse titles
	    NSArray *titleNodes = [htmlParser searchWithXPathQuery:@"//div[@class='detName']/a"];
	    NSMutableArray *titleEntries = [[NSMutableArray alloc] init];
	    for (TFHppleElement * element in titleNodes) {
	        [titleEntries addObject:[[element text] gtm_stringByUnescapingFromHTML]];
		}
        
	    //parse seeders & leechers
	    NSArray *seederLeechersNodes = [htmlParser searchWithXPathQuery:@"//td[@align='right']"];
	    NSMutableArray *seederEntries = [[NSMutableArray alloc] init];
	    NSMutableArray *leecherEntries = [[NSMutableArray alloc] init];
	    int index = 2;
	    for (TFHppleElement * element in seederLeechersNodes) {
	        if ([element text]) {
	            if (index % 2)
					[leecherEntries addObject:[element text]];
	            else
					[seederEntries addObject:[element text]];
	            index++;
			}
		}
	    //parse uploaded date/size
	    NSArray *dateSizeNodes = [htmlParser searchWithXPathQuery:@"//font[@class='detDesc']"];
	    NSMutableArray *dateEntries = [[NSMutableArray alloc] init];
	    NSMutableArray *sizeEntries = [[NSMutableArray alloc] init];
	    for (TFHppleElement * element in dateSizeNodes) {
	        NSArray *splitStrings = [[element text] componentsSeparatedByString:@","];
	        if ([splitStrings count] > 1) {
	            [dateEntries addObject:[[splitStrings objectAtIndex:0] stringByReplacingOccurrencesOfString:@"Uploaded " withString:@""]];
	            [sizeEntries addObject:[[splitStrings objectAtIndex:1] stringByReplacingOccurrencesOfString:@"Size " withString:@""]];
			}
	        else {
	            [dateEntries addObject:@"?"];
	            [sizeEntries addObject:@"?"];
			}
		}
        
	    //parse id
	    NSArray *idNodes = [htmlParser searchWithXPathQuery:@"//div[@class='detName']/a"];
	    NSMutableArray *idEntries = [[NSMutableArray alloc] init];
	    for (TFHppleElement * element in idNodes) {
	        NSArray *splitIds = [[element objectForKey:@"href"] componentsSeparatedByString:@"/"];
	        [idEntries addObject:[splitIds objectAtIndex:2]];
		}
        
	    //parse magnet
	    NSArray *magnetNodes = [htmlParser searchWithXPathQuery:@"//tr/td/a"];
	    NSMutableArray *magnetEntries = [[NSMutableArray alloc] init];
	    for (TFHppleElement * element in magnetNodes)
			if ([[element objectForKey:@"href"] rangeOfString:@"magnet:?"].location != NSNotFound) {
			    [magnetEntries addObject:[element objectForKey:@"href"]];
			}
        
        NSDictionary *results = [[NSDictionary alloc] initWithObjectsAndKeys:titleEntries, @"titles", seederEntries, @"seeders", leecherEntries, @"leechers", dateEntries, @"dates", sizeEntries, @"sizes", idEntries, @"ids", magnetEntries, @"magnets", nil];
        if (pge)
            [_delegate recieveResultsFromAPI:results];
        else
            [_delegate recieveResultsFromAPIForNextPage:results];
        
	} failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
	    [_delegate failedToRecieveResultsWithError:error];
	}];
    
	[op setDownloadProgressBlock: ^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
	    [_delegate recieveProgressFromAPI:(float)totalBytesRead / 70000]; //Content-Length isnt provided, so this is just a guess
	}];
    
	[op start];
}

@end
