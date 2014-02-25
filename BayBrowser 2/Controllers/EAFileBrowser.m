//
//  EAFileBrowser.m
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/30/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import "EAFileBrowser.h"

@implementation EAFileBrowser

#pragma mark - UIViewController

- (id)initWithPath:(NSString *)sentPath {
	return [self initWithPath:sentPath isPad:NO];
}

- (id)initWithPath:(NSString *)sentPath isPad:(BOOL)isPad {
	self = [super init];

	if (self) {
		_isPad = isPad;
		_path = sentPath;
		[self setTitle:[_path lastPathComponent]];
		_files = [[NSMutableArray alloc] init];

		//setup table
		_filesTable = [[UITableView alloc] initWithFrame:[[self view] bounds]];
		[_filesTable setDelegate:self];
		[_filesTable setDataSource:self];
		CGRect frame = [_filesTable frame];
		frame.size.height -= 64;
		[_filesTable setFrame:frame];

		if (_isPad) {
			//create seperate frame for ipad
			CGRect iPadFrame = [[self view] bounds];
			iPadFrame.origin.y += 44;
			iPadFrame.size.height -= 110;
			iPadFrame.size.width = 400;
			[_filesTable setFrame:iPadFrame];
			[[self view] setFrame:iPadFrame];

			//create navigation bar
			_navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, iPadFrame.size.width, 44)];
			[_navBar setTranslucent:NO];
			[_navBar layer].zPosition = 5;
			UINavigationItem *title = [UINavigationItem alloc];
			[title setTitle:[_path lastPathComponent]];
			[_navBar pushNavigationItem:title animated:YES];

			//create edit button
			UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(tappedEditButton)];
			[[_navBar topItem] setRightBarButtonItem:editButton];
			[[self view] addSubview:_navBar];
		}

		//add the table to view
		[[self view] addSubview:_filesTable];
		[_filesTable setAllowsMultipleSelectionDuringEditing:YES];

		//edit button
		UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(tappedEditButton)];
		[[self navigationItem] setRightBarButtonItem:editButton];
	}

	return self;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[_files removeAllObjects];

	//get files in current directory
	//remove files starting with a '.'
	for (NSString *file in[[NSFileManager defaultManager] contentsOfDirectoryAtPath:_path error:nil]) {
		if (![file hasPrefix:@"."])
			[_files addObject:file];
	}

	[_filesTable reloadData];

	//create webserver toolbar button
	UIBarButtonItem *webServ = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"wifi.png"] style:UIBarButtonItemStylePlain target:self action:@selector(tappedWebButton)];
	NSArray *items = [NSArray arrayWithObjects:webServ, nil];

	if (_isPad) {
		_toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, [_filesTable bounds].size.height + 44, [[self view] bounds].size.width, 46)];
		[_toolbar setItems:items];
		[_toolbar setTranslucent:YES];
		[[self view] addSubview:_toolbar];
	}
	else {
		[[self navigationController] setToolbarHidden:NO];
		[self setToolbarItems:items animated:YES];
	}
}

- (void)tappedEditButton {
	if ([_filesTable isEditing]) {
		[_filesTable setEditing:NO animated:YES];

		//change done to edit
		UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(tappedEditButton)];

		UIBarButtonItem *webServ = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"wifi.png"] style:UIBarButtonItemStylePlain target:self action:@selector(tappedWebButton)];

		NSArray *items = [NSArray arrayWithObjects:webServ, nil];

		if (_isPad) {
			_toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, [_filesTable bounds].size.height + 44, [[self view] bounds].size.width, 46)];
			[_toolbar setTranslucent:YES];
			[_toolbar setItems:items];
			[[self view] addSubview:_toolbar];

			[[_navBar topItem] setRightBarButtonItem:editButton];
		}
		else {
			[[self navigationController] setToolbarHidden:NO];
			[self setToolbarItems:items animated:YES];
			[[self navigationItem] setRightBarButtonItem:editButton];
		}
	}
	else {
		[_filesTable setEditing:YES animated:YES];

		//change edit to done
		UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(tappedEditButton)];

		UIBarButtonItem *trash = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(tappedTrashIcon)];
		NSArray *items = [NSArray arrayWithObjects:trash, nil];

		if (_isPad) {
			//update ipad toolbar
			[[_navBar topItem] setRightBarButtonItem:doneButton];

			_toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, [_filesTable bounds].size.height + 44, [[self view] bounds].size.width, 46)];
			[_toolbar setTranslucent:YES];
			[_toolbar setItems:items];
			[[self view] addSubview:_toolbar];
		}
		else {
			[[self navigationItem] setRightBarButtonItem:doneButton];

			[self setToolbarItems:items];
		}
	}
}

- (void)tappedTrashIcon {
	//delete items and refresh
	for (NSIndexPath *index in[_filesTable indexPathsForSelectedRows]) {
		[[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@", _path, [_files objectAtIndex:[index row]]] error:nil];
		[_files removeObjectAtIndex:[index row]];
	}

	[_filesTable deleteRowsAtIndexPaths:[_filesTable indexPathsForSelectedRows] withRowAnimation:UITableViewRowAnimationAutomatic];

	//turn of edit mode
	[self tappedEditButton];
}

- (void)tappedWebButton {
	//create webserver alert view
	UIAlertView *webAlert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"Open 'http://%@:8080' in your browser.", [self getIPAddress]] delegate:self cancelButtonTitle:@"Stop Webserver" otherButtonTitles:nil, nil];
	[webAlert show];

	_webServer = [[GCDWebServer alloc] init];

	//root webserver index is the downloads folder
	NSString *webPath = [NSString stringWithFormat:@"%@/Documents/Downloads", NSHomeDirectory()];
	[_webServer addHandlerForBasePath:@"/" localPath:webPath indexFilename:nil cacheAge:3600];

	//run the webserver on port 8080
	[_webServer runWithPort:8080];
}

- (void)presentFilePickerWithPath:(NSString *)filePath {
	//show actionsheet to choose how to view file
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"%@\n\nOpen in", [filePath pathComponents].lastObject] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Audio Player", @"Video Player", @"Text Viewer", @"Image Viewer", @"iFile", nil];
	[actionSheet setAccessibilityValue:filePath];
	[actionSheet showInView:[self view]];
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_files count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"EAFileBrowserCell";
	EACustomFileCell *cell = (EACustomFileCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (!cell)
		cell = [[EACustomFileCell alloc] init];

	NSString *newPath = [_path stringByAppendingPathComponent:[_files objectAtIndex:[indexPath row]]];

	BOOL isDirectory;
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:newPath isDirectory:&isDirectory];

	//set info for file
	NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:newPath error:nil];
	[[cell fileName] setText:[_files objectAtIndex:[indexPath row]]];

	//if its a directory, put the accessory diclosure indicator
	if (fileExists && isDirectory)
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	else {
		[cell setAccessoryType:UITableViewCellAccessoryNone];
		//file size
		float size = [fileInfo fileSize];
		size = size / 1024;
		size = size / 2024;
		[[cell sizeLabel] setText:[NSString stringWithFormat:@"Size: %.2fmb", size]];

		//file date
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"MM/dd/yy hh:mm a"];
		[[cell dateLabel] setText:[dateFormatter stringFromDate:[fileInfo fileModificationDate]]];
	}

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (![tableView isEditing]) {
		NSString *newPath = [_path stringByAppendingPathComponent:[_files objectAtIndex:[indexPath row]]];
		BOOL isDirectory;

		[[NSFileManager defaultManager] fileExistsAtPath:newPath isDirectory:&isDirectory];

		//only open if its a folder
		if (isDirectory) {
			//create new instance with file path
			EAFileBrowser *newBrowser = [[EAFileBrowser alloc] initWithPath:newPath isPad:_isPad];

			if (_isPad) {
				//remove controllers in front of the current one (only in front of it)
				[[Delegate rootStackController] removeAllControllersAfterController:self];
                
				//everythings off, now push this one
				[[Delegate rootStackController] pushViewController:newBrowser animated:YES];

				//set the content offset of the navigation stack to move to the newly created controller
				[[[Delegate rootStackController] pagingView] setContentOffset:CGPointMake(
				     [[[Delegate rootStackController] pagingView] contentSize].width -
				     [[[Delegate rootStackController] pagingView] bounds].size.width, 0)
				                                                     animated:YES];
			}
			else

				//a bit simplier for iphones
				[[self navigationController] pushViewController:newBrowser animated:YES];
		}
		else {
			//not a folder, present the file picker
			[self presentFilePickerWithPath:newPath];
		}

		//deselect
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 50;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

#pragma mark - UIActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (_isPad) {
		//remove all controllers in front of this one
		for (UIViewController *controller in[[Delegate rootStackController] viewControllers]) {
			int index = [[[Delegate rootStackController] viewControllers] indexOfObject:self];
			if ([[[Delegate rootStackController] viewControllers] indexOfObject:controller] >= index + 1)
				[[Delegate rootStackController] removeControllerAtIndex:[[[Delegate rootStackController] viewControllers] indexOfObject:controller]];
		}
	}

	if (buttonIndex == 0) {
		//push to music view
		if (_isPad) {
			EAMusicPlayerController *audio = [[EAMusicPlayerController alloc] initWithAudioFilePath:[actionSheet accessibilityValue] isPad:YES];
			[[Delegate rootStackController] pushViewController:audio animated:YES];
		}
		else {
			EAMusicPlayerController *audio = [[EAMusicPlayerController alloc] initWithAudioFilePath:[actionSheet accessibilityValue] isPad:NO];
			[[self navigationController] pushViewController:audio animated:YES];
		}
	}

	if (buttonIndex == 1) {
		//video file. just using native iOS video viewer for now (vlc in the future)
		NSURL *vidURL = [NSURL fileURLWithPath:[actionSheet accessibilityValue]];
		MPMoviePlayerViewController *video = [[MPMoviePlayerViewController alloc] initWithContentURL:vidURL];
		[[video moviePlayer] setContentURL:vidURL];
		[[video moviePlayer] prepareToPlay];
		[[video view] setFrame:[[self view] bounds]];
		[[video moviePlayer] setShouldAutoplay:YES];
		[[video moviePlayer] setMovieSourceType:MPMovieSourceTypeFile];
		[[video moviePlayer] setFullscreen:YES animated:YES];
		[[video moviePlayer] setControlStyle:MPMovieControlStyleFullscreen];
		[[video moviePlayer] setScalingMode:MPMovieScalingModeAspectFill];
		[self presentMoviePlayerViewControllerAnimated:video];

		return;
	}

	if (buttonIndex == 2) {
		//text file
		if (_isPad) {
			EATextFileController *text = [[EATextFileController alloc] initWithFilePath:[actionSheet accessibilityValue] isPad:YES];
			[[Delegate rootStackController] pushViewController:text animated:YES];
		}
		else {
			EATextFileController *text = [[EATextFileController alloc] initWithFilePath:[actionSheet accessibilityValue]];
			[[self navigationController] pushViewController:text animated:YES];
		}
	}

	if (buttonIndex == 3) {
		//image file
		if (_isPad) {
			EAImageFileController *image = [[EAImageFileController alloc] initWithPathToImage:[actionSheet accessibilityValue] isPad:YES];
			[[Delegate rootStackController] pushViewController:image animated:YES];
		}
		else {
			EAImageFileController *image = [[EAImageFileController alloc] initWithPathToImage:[actionSheet accessibilityValue] isPad:NO];
			[[self navigationController] pushViewController:image animated:YES];
		}
	}

	if (buttonIndex == 4) {
		//open file in ifile
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"ifile://%@", [[actionSheet accessibilityValue] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
		[[UIApplication sharedApplication] openURL:url];
	}

	//move to new controller
	if (_isPad) {
		[[[Delegate rootStackController] pagingView] setContentOffset:CGPointMake(
		     [[[Delegate rootStackController] pagingView] contentSize].width -
		     [[[Delegate rootStackController] pagingView] bounds].size.width, 0)
		                                                     animated:YES];
	}
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
	[_webServer stop];
}

//get ip address - my goodness this is eh
#pragma mark - IP address
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <netdb.h>

- (NSString *)getIPAddress {
	NSString *address = @"error";
	struct ifaddrs *interfaces = NULL;
	struct ifaddrs *temp_addr = NULL;
	int success = 0;
	success = getifaddrs(&interfaces);
	if (success == 0) {
		temp_addr = interfaces;
		while (temp_addr != NULL) {
			if (temp_addr->ifa_addr->sa_family == AF_INET) {
				address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
			}

			temp_addr = temp_addr->ifa_next;
		}
	}
	freeifaddrs(interfaces);
	return address;
}

- (void)viewDidPinch:(UIPinchGestureRecognizer *)pinch {
	if ([pinch state] == UIGestureRecognizerStateChanged) {
		if ([pinch scale] >= 0.75 && [pinch scale] <= 1.2) {
			[self resizeByFactor:[pinch scale]];
			[[self view] setAlpha:[pinch scale]];
		}

		if ([pinch scale] < 0.70) {
			[[Delegate rootStackController] removeControllerAtIndex:[[[Delegate rootStackController] viewControllers] indexOfObject:self]];
			[[Delegate rootStackController] layoutControllers];
		}
	}

	if ([pinch state] == UIGestureRecognizerStateEnded) {
		[UIView animateWithDuration:.2 animations: ^{
		    [[self view] setTransform:CGAffineTransformIdentity];
		    [[self view] setAlpha:1];
		}];
	}
}

- (void)resizeByFactor:(CGFloat)factor {
	CGAffineTransform transform = CGAffineTransformMakeScale(factor, factor);
	self.view.transform = transform;
}

@end
