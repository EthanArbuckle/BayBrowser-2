//
//  EATorrentDownloadManager.m
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/17/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import "EATorrentDownloadManager.h"

@implementation EATorrentDownloadManager

#pragma mark - UIViewController

- (id)init {
	return [self initAsiPad:NO];
}

- (id)initAsiPad:(BOOL)isPad {
	if (self = [super init]) {
		//create table
		_torrentsTable = [[UITableView alloc] initWithFrame:[[self view] bounds]];
		CGRect frame = [_torrentsTable frame];
		frame.size.height -= 64;

		//only reduce height for iphones
		if (!isPad)
			[_torrentsTable setFrame:frame];

		if (isPad) {
			//set custom frame
			CGRect ipadFrame = [_torrentsTable frame];
			ipadFrame.size.width = 400;
			ipadFrame.origin.y = 44;
			ipadFrame.size.height -= 44;
			[_torrentsTable setFrame:ipadFrame];
			[[self view] setFrame:ipadFrame];

			//create custom navigationbar
			UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, ipadFrame.size.width, 44)];
			[navBar setTranslucent:NO];
			UINavigationItem *title = [UINavigationItem alloc];
			[title setTitle:@"Active"];
			[navBar pushNavigationItem:title animated:NO];
			[[self view] addSubview:navBar];
		}

		//setup tableview delegates
		[_torrentsTable setDelegate:self];
		[_torrentsTable setDataSource:self];
		[[self view] addSubview:_torrentsTable];

		//create torrents table
		_allTorrents = [[NSMutableArray alloc] init];

		//listen for torrent finished notification from controller
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(torrentFinished) name:@"TorrentFinishedDownloading" object:nil];
		
	}

	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	//remove all torrents
	[_allTorrents removeAllObjects];

	//refresh our list
	NSString *completedPath = [[[Delegate torrentController] documentsDirectory] stringByAppendingString:@"/Inactive.plist"];
	NSArray *inactive = [NSArray arrayWithContentsOfFile:completedPath];
	for (NSDictionary *object in inactive) {
		NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:object, @"torrent", @"complete", @"status", nil];
		[_allTorrents addObject:dict];
	}

	for (Torrent *t in[[Delegate torrentController] fTorrents]) {
		NSMutableDictionary *torrentDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:t, @"torrent", @"active", @"status", nil];
		[_allTorrents addObject:torrentDict];
	}

	//reload torrents when view is opened
	[_torrentsTable reloadData];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];

	[self save];
}

- (void)save {
	//location to completed plist
	NSString *completedPath = [[[Delegate torrentController] documentsDirectory] stringByAppendingString:@"/Inactive.plist"];

	//populate array from completed plist
	NSMutableArray *toFile = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithContentsOfFile:completedPath]];

	//add all active to array
	if ([_allTorrents count] > 0 && _allTorrents) {
		int objectCnt = [_allTorrents count];
		while (objectCnt-- >= 0) {
			if ([_allTorrents count] < objectCnt) return;
			NSDictionary *dict = [_allTorrents objectAtIndex:objectCnt];
			if ([[dict objectForKey:@"status"] isEqualToString:@"active"]) {
				Torrent *t = [dict objectForKey:@"torrent"];
				if ([t isComplete]) {
					NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[t name], @"name", [t dataLocation], @"location", nil];
					[toFile addObject:dict];
					[t stopTransfer];
					[_allTorrents removeObject:dict];
				}
			}
		}
	}

	//only write if there are objects
	if ([toFile count] == 0) return;

	//write it
	[toFile writeToFile:completedPath atomically:NO];
}

- (void)update:(NSTimer *)cell {
	//runs every 1 second for each cell, refreshes info
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
	    NSIndexPath *index = [_torrentsTable indexPathForCell:[cell userInfo]];
	    [[Delegate torrentController] updateGlobalSpeed];
	    Torrent *torrent = [[_allTorrents objectAtIndex:[index row]] objectForKey:@"torrent"];
	    [torrent update];
	    [self performUpdateOnCell:[cell userInfo] withTorrent:torrent];
	});
}

- (void)performUpdateOnCell:(EACustomTorrentCell *)cell withTorrent:(Torrent *)torrent {
	//start a new thread to update each cell
	dispatch_async(dispatch_get_main_queue(), ^{
	    [[cell statusLabel] setText:[torrent statusString]];
	    [[cell progressBar] setProgress:[torrent progressDone]];
	    [[cell progressLabel] setText:[torrent progressString]];
	    if ([torrent isComplete]) {
	        [self save];
	        [cell setBackgroundColor:[UIColor colorWithRed:204.0f / 255.0f green:255.0f / 255.0f blue:204.0f / 255.0f alpha:1]];
	        if (!SETTINGS_CAN_SEED)
				[torrent stopTransfer];
		}
	});
}

- (void)torrentFinished {
	//called when a torrent completed, presents a notiication
	UILocalNotification *notification = [[UILocalNotification alloc] init];
	notification.alertBody = @"Your torrent has finished downloading!";
	notification.alertAction = @"Open";
	[[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//number of torrents
	return [_allTorrents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//setup cell
	EACustomTorrentCell *cell = (EACustomTorrentCell *)[tableView dequeueReusableCellWithIdentifier:@"EACustomTorrentCell"];

	if (!cell)
		cell = [[EACustomTorrentCell alloc] init];

	//completed and active are different cells
	if ([[[_allTorrents objectAtIndex:[indexPath row]] objectForKey:@"status"] isEqualToString:@"complete"]) {
		[[cell titleLabel] setText:[[[_allTorrents objectAtIndex:[indexPath row]] objectForKey:@"torrent"] objectForKey:@"name"]];
		[[cell statusLabel] setText:@"Completed"];
		[[cell progressBar] setHidden:YES];
	}
	else {
		//current torrent
		Torrent *torrent = [[_allTorrents objectAtIndex:[indexPath row]] objectForKey:@"torrent"];

		//setup info
		[[cell titleLabel] setText:[[torrent name] stringByReplacingOccurrencesOfString:@"+" withString:@" "]];
		[[cell statusLabel] setText:[torrent statusString]];

		//setup progress string
		[[cell progressLabel] setText:[torrent progressString]];

		//progress
		[[cell progressBar] setProgress:[torrent progressDone]];

		NSTimer *cellTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(update:) userInfo:cell repeats:YES];
		[[_allTorrents objectAtIndex:[indexPath row]] setObject:cellTimer forKey:@"timer"];
	}

	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//create actionsheet depending on completed or active
	UIActionSheet *actionSheet;
	if ([[[_allTorrents objectAtIndex:[indexPath row]] objectForKey:@"status"] isEqualToString:@"complete"]) {
		actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Close" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Open in iFile", nil];
	}
	else {
		actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Close" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Pause", @"Resume", @"Open in iFile", nil];
	}

	//present it
	[actionSheet setTag:[indexPath row]];
	[actionSheet showInView:[self view]];

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if ([[[_allTorrents objectAtIndex:[actionSheet tag]] objectForKey:@"status"] isEqualToString:@"complete"]) {
		if (buttonIndex == 0) {
			//action sheet to delete
			UIAlertView *delete = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@", [[[_allTorrents objectAtIndex:[actionSheet tag]] objectForKey:@"torrent"] objectForKey:@"name"]] message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete Torrent", @"Delete Torrent + Data", nil];
			[delete setTag:[actionSheet tag]];
			[delete show];
		}

		if (buttonIndex == 1) {
			//open in ifile
			NSString *path = [NSString stringWithFormat:@"ifile://%@", [[[[_allTorrents objectAtIndex:[actionSheet tag]] objectForKey:@"torrent"] objectForKey:@"location"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
			NSURL *url = [NSURL URLWithString:path];
			[[UIApplication sharedApplication] openURL:url];
		}
	}
	else {
		///create torrent
		Torrent *torrent = [[_allTorrents objectAtIndex:[actionSheet tag]] objectForKey:@"torrent"];

		if (buttonIndex == 0) {
			//delete torrent
			UIAlertView *delete = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@", [torrent name]] message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete Torrent", @"Delete Torrent + Data", nil];
			[delete setTag:[actionSheet tag]];
			[delete show];
		}

		if (buttonIndex == 1) //pause
			[torrent stopTransfer];

		if (buttonIndex == 2) //play
			[torrent startTransfer];

		if (buttonIndex == 3) {
			//open in ifile
			NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"ifile://%@", [[torrent dataLocation] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
			[[UIApplication sharedApplication] openURL:url];
		}
	}
}

#pragma mark - UIAlertView delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0)
		return;

	NSString *location;
	NSString *tlocation;
	Torrent *torrent;

	//delete torrent data, file, or both

	if ([[[_allTorrents objectAtIndex:[alertView tag]] objectForKey:@"status"] isEqualToString:@"complete"]) {
		location = [[[_allTorrents objectAtIndex:[alertView tag]] objectForKey:@"torrent"] objectForKey:@"location"];
	}

	else {
		torrent = [[_allTorrents objectAtIndex:[alertView tag]] objectForKey:@"torrent"];
		location = [torrent dataLocation];
		tlocation = [torrent torrentLocation];
	}

	//just delete .torrent
	if (buttonIndex == 1) {
		[torrent stopTransfer];
		[[NSFileManager defaultManager] removeItemAtPath:tlocation error:nil];
	}

	//delete all
	if (buttonIndex == 2) {
		[torrent stopTransfer];
		[[NSFileManager defaultManager] removeItemAtPath:location error:nil];
		[[NSFileManager defaultManager] removeItemAtPath:tlocation error:nil];

		//remove from saved plist
		NSMutableArray *files = [[NSMutableArray alloc] initWithContentsOfFile:[[[Delegate torrentController] documentsDirectory] stringByAppendingString:@"/Inactive.plist"]];

		if ([files containsObject:[_allTorrents objectAtIndex:[alertView tag]]]) {
			[files removeObject:[_allTorrents objectAtIndex:[alertView tag]]];
		}

		[[NSFileManager defaultManager] removeItemAtPath:[[[Delegate torrentController] documentsDirectory] stringByAppendingString:@"/Inactive.plist"] error:nil];
		[files writeToFile:[[[Delegate torrentController] documentsDirectory] stringByAppendingString:@"/Inactive.plist"] atomically:NO];
	}

	[_allTorrents removeObjectAtIndex:[alertView tag]];

	[_torrentsTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[alertView tag] inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

@end
