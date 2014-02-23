//
//  EACustomPostsTableView.m
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/24/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import "EACustomPostsTableView.h"

@implementation EACustomPostsTableView

#pragma mark - EACustomPostsTableView
- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		//setup posts tableview
		_postsTableView = [[UITableView alloc] initWithFrame:[self bounds]];
		[_postsTableView setDataSource:self];
		[_postsTableView setDelegate:self];
		[_postsTableView setCanCancelContentTouches:YES];
        [_postsTableView setScrollsToTop:YES];
		[self addSubview:_postsTableView];
        
		//init stuff
		_urlInformation = [[NSMutableDictionary alloc] init];
		_pirateAPI = [[EAPirateBayAPI alloc] init];
		[_pirateAPI setDelegate:self];
		_allPosts = [[NSMutableDictionary alloc] init];
        
		//start on page 1 (begins at 0)
		[_urlInformation setObject:@"0" forKey:@"page"];
        
		//defaults to sorted by seeders
		[_urlInformation setObject:@"/7/0/" forKey:@"sortby"];
        
        //add refresh control
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
        [_postsTableView addSubview:_refreshControl];
	}
    
	return self;
}

- (void)addHeader {
	//setup search bar/sorter
	_postHeader = [[EAPostSearchHeader alloc] initWithFrame:CGRectMake(0, 0, [self bounds].size.width, 40)];
	[_postHeader setDelegate:self];
	[_postsTableView setTableHeaderView:_postHeader];
	[_postsTableView setContentOffset:CGPointMake(0, 40)];
}

- (void)addFooter {
	//setup tableview footer slider
	_postFooter = [JMSlider sliderWithFrame:CGRectMake(0, 0, 320, 90) centerTitle:@"More" leftTitle:nil rightTitle:nil delegate:self];
	[_postFooter setLoading:YES];
	[_postsTableView setTableFooterView:_postFooter];
}

- (void)start {
	_initialPostsBlock();
}

- (void)refreshData {
    //empty table
    _allPosts = nil;
    [_postFooter setLoading:YES];
    [_postsTableView reloadData];
    
    //make request
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/0/7/0", SETTINGS_BASE_URL, [_urlInformation objectForKey:@"scheme"]]];
	[_pirateAPI scrapeInformationFromURL:url isPageOne:YES];

}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	//calculate cell size based on how big the title is
	NSString *title = [[_allPosts objectForKey:@"titles"] objectAtIndex:[indexPath row]];
	CGSize textSize = [title sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0f] constrainedToSize:CGSizeMake([self bounds].size.width, 20000) lineBreakMode:NSLineBreakByWordWrapping];
	float heightToAdd = MIN(textSize.height, 100.0f);
	return heightToAdd + 45;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[_allPosts objectForKey:@"titles"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//create tableviewcell
	EACustomPostsCell *cell = (EACustomPostsCell *)[tableView dequeueReusableCellWithIdentifier:@"EACustomPostsCell"];
	if (cell == nil) {
		cell = [[EACustomPostsCell alloc] init];
		[cell setUserInteractionEnabled:YES];
		[cell setDelegate:self];
		//[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}
    
	//set title label - size it
	[[cell titleLabel] setText:[[_allPosts objectForKey:@"titles"] objectAtIndex:[indexPath row]]];
	[[cell titleLabel] setNumberOfLines:0];
	[[cell titleLabel] sizeToFit];
    
	//set seeders/leechers label
	NSString *seeders = [NSString truncate:[[_allPosts objectForKey:@"seeders"] objectAtIndex:[indexPath row]]];
	NSString *leechers = [NSString truncate:[[_allPosts objectForKey:@"leechers"] objectAtIndex:[indexPath row]]];
	[[cell seedersLeechersLabel] setText:[NSString stringWithFormat:@"SE: %@ - LE: %@", seeders, leechers]];
    
	//set date label
	[[cell dataLabel] setText:[NSString stringWithFormat:@"uploaded: %@", [[_allPosts objectForKey:@"dates"] objectAtIndex:[indexPath row]]]];
    
	//set size label
	[[cell sizeLabel] setText:[[_allPosts objectForKey:@"sizes"] objectAtIndex:[indexPath row]]];
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//hide search keypad
	[[_postHeader searchTextBox] resignFirstResponder];
        
	//make detailview
	EATorrentDetailController *detailView = [[EATorrentDetailController alloc] init];
    
	//create dictionary with just selected torrent
	NSDictionary *torrentInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
	                             [[_allPosts objectForKey:@"titles"] objectAtIndex:[indexPath row]], @"title",
	                             [[_allPosts objectForKey:@"seeders"] objectAtIndex:[indexPath row]], @"seeders",
	                             [[_allPosts objectForKey:@"leechers"] objectAtIndex:[indexPath row]], @"leechers",
	                             [[_allPosts objectForKey:@"dates"] objectAtIndex:[indexPath row]], @"date",
	                             [[_allPosts objectForKey:@"sizes"] objectAtIndex:[indexPath row]], @"size",
	                             [[_allPosts objectForKey:@"ids"] objectAtIndex:[indexPath row]], @"id",
	                             [[_allPosts objectForKey:@"magnets"] objectAtIndex:[indexPath row]], @"magnet", nil];
    
	//send dict to detailview
	[detailView setTorrentDictionary:torrentInfo];
    
	//set detailsViews title
	[detailView setTitle:[[_allPosts objectForKey:@"titles"] objectAtIndex:[indexPath row]]];
    
	//push to detailview, depending on the type of device
    if (!_isPad)
        [[_parent navigationController] pushViewController:detailView animated:YES]; //iphone
    else {
        [detailView setIsPad:YES];
        if ([[[Delegate rootStackController] viewControllers] count] >= 3)
            [[Delegate rootStackController] removeControllerAtIndex:2];
        
        [[Delegate rootStackController] pushViewController:detailView animated:YES];
        
        [[[Delegate rootStackController] pagingView] setContentOffset:CGPointMake(
                                                                                  [[[Delegate rootStackController] pagingView] contentSize].width -
                                                                                  [[[Delegate rootStackController] pagingView] bounds].size.width, 0)
                                                     animated:YES];
    }
    
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - EAPirateBayAPI delegate
- (void)recieveResultsFromAPI:(NSDictionary *)results {
	//recieve posts from api
	[[Delegate universalProgressIndicator] hide];
	[_postFooter setLoading:NO];
	_allPosts = [results copy];
	[_postsTableView reloadData];
    [_refreshControl endRefreshing];
}

- (void)recieveResultsFromAPIForNextPage:(NSDictionary *)results {

	[[Delegate universalProgressIndicator] hide];
	[_postFooter setLoading:NO];
    
	//combine current posts with new ones. This should be redone
	NSMutableArray *titles = [_allPosts objectForKey:@"titles"],
	*seeders = [_allPosts objectForKey:@"seeders"],
    *leechers = [_allPosts objectForKey:@"leechers"],
    *dates = [_allPosts objectForKey:@"dates"],
    *sizes = [_allPosts objectForKey:@"sizes"],
    *ids = [_allPosts objectForKey:@"ids"],
    *magnets = [_allPosts objectForKey:@"magnets"];
    
	[titles addObjectsFromArray:[results objectForKey:@"titles"]];
	[seeders addObjectsFromArray:[results objectForKey:@"seeders"]];
	[leechers addObjectsFromArray:[results objectForKey:@"leechers"]];
	[dates addObjectsFromArray:[results objectForKey:@"dates"]];
	[sizes addObjectsFromArray:[results objectForKey:@"sizes"]];
	[ids addObjectsFromArray:[results objectForKey:@"ids"]];
	[magnets addObjectsFromArray:[results objectForKey:@"magnets"]];
    
	_allPosts = [[NSMutableDictionary alloc] initWithObjectsAndKeys:titles, @"titles", seeders, @"seeders", leechers, @"leechers", dates, @"dates", sizes, @"sizes", ids, @"ids", magnets, @"magnets", nil];
    
	[_postsTableView reloadData];
}

- (void)failedToRecieveResultsWithError:(NSError *)error {
	[TSMessage showNotificationWithTitle:@"Failed to get data!" type:TSMessageNotificationTypeError];
}

//underside button of cell tapped
- (void)undersideOfCell:(UITableViewCell *)cell WasTappedAtIndex:(int)index {
	NSIndexPath *cellIndex = [_postsTableView indexPathForCell:cell];
	if (index == 2) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:Nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Copy Magnet", @"Open in Safari", @"Email URL", nil];
		[actionSheet setTag:[cellIndex row]];
		[actionSheet setDelegate:self];
		[actionSheet showInView:self];
	}
}

- (void)recieveProgressFromAPI:(float)prog {
	[[Delegate universalProgressIndicator] show];
	[[Delegate universalProgressIndicator] setProgress:prog];
}

#pragma mark - UIScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	//hide search keypad
	[[_postHeader searchTextBox] resignFirstResponder];
}

#pragma mark - UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		//copy the magnet
		[[UIPasteboard generalPasteboard] setString:[[_allPosts objectForKey:@"magnets"] objectAtIndex:[actionSheet tag]]];
	}
	if (buttonIndex == 1) {
		//open link in safari
		NSString *url = [NSString stringWithFormat:@"%@/torrent/%@", SETTINGS_BASE_URL, [[_allPosts objectForKey:@"ids"] objectAtIndex:[actionSheet tag]]];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
	}
    if (buttonIndex == 2) {
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *emailView = [[MFMailComposeViewController alloc] init];
            [emailView setMailComposeDelegate:self];
            [emailView setSubject:[[_allPosts objectForKey:@"titles"] objectAtIndex:[actionSheet tag]]];
            NSString *url = [NSString stringWithFormat:@"%@/torrent/%@", SETTINGS_BASE_URL, [[_allPosts objectForKey:@"ids"] objectAtIndex:[actionSheet tag]]];
            [emailView setMessageBody:url isHTML:NO];
            [[_parent navigationController] presentViewController:emailView animated:YES completion:nil];
        }
    }
}

#pragma mark - JMSlider delegate
- (void)slider:(JMSlider *)slider didSelect:(JMSliderSelection)selection {
	[_postFooter setLoading:YES];
	//step page number up
	int nextPage = [[_urlInformation objectForKey:@"page"] intValue];
	nextPage++;
	[_urlInformation setObject:[NSString stringWithFormat:@"%d", nextPage] forKey:@"page"];
    
	//make request
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@%@", SETTINGS_BASE_URL, [_urlInformation objectForKey:@"scheme"], [_urlInformation objectForKey:@"page"], [_urlInformation objectForKey:@"sortby"]]];
	[_pirateAPI scrapeInformationFromURL:url isPageOne:NO];
}

#pragma mark - EASearchHeader delegate
- (void)didChangeSortBy:(EAPostSearchHeaderSortByType)sortByType {
	[_urlInformation setObject:@"0" forKey:@"page"];
    
	if (sortByType == EAPostSearchHeaderSortBySeeders)
		[_urlInformation setObject:@"/7/0/" forKey:@"sortby"];
	if (sortByType == EAPostSearchHeaderSortByLeechers)
		[_urlInformation setObject:@"/9/0/" forKey:@"sortby"];
	if (sortByType == EAPostSearchHeaderSortByUploaded)
		[_urlInformation setObject:@"/3/0/" forKey:@"sortby"];
	if (sortByType == EAPostSearchHeaderSortBySize)
		[_urlInformation setObject:@"/5/0/" forKey:@"sortby"];
	if (sortByType == EAPostSearchHeaderSortByUploader)
		[_urlInformation setObject:@"/11/0/" forKey:@"sortby"];
    
	[_pirateAPI scrapeInformationFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@%@", SETTINGS_BASE_URL, [_urlInformation objectForKey:@"scheme"], [_urlInformation objectForKey:@"page"], [_urlInformation objectForKey:@"sortby"]]] isPageOne:YES];
}

- (void)didEnterSearchText:(NSString *)searchString {
	if ([searchString length] > 0) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/search/%@/0%@/%@", SETTINGS_BASE_URL, [searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[_urlInformation objectForKey:@"sortby"] stringByReplacingOccurrencesOfString:@"/0/" withString:@""], [[_urlInformation objectForKey:@"scheme"] stringByReplacingOccurrencesOfString:@"/browse/" withString:@""]]];
		[_pirateAPI scrapeInformationFromURL:url isPageOne:YES];
	}
}

#pragma mark - MFMailComposer delegate
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end