//
//  EATextFIleController.m
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 12/2/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import "EATextFIleController.h"

@implementation EATextFileController

#pragma mark - UIViewController

- (id)initWithFilePath:(NSString *)filePath {
	return [self initWithFilePath:filePath isPad:NO];
}

- (id)initWithFilePath:(NSString *)filePath isPad:(BOOL)isPad {
	self = [super init];

	//create textview
	NSString *fileText = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
	UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(5, 20, [[self view] bounds].size.width - 10, [[self view] bounds].size.height - 10)];
	[text setText:fileText];
	[text setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
	[text setEditable:NO];
	[[self view] addSubview:text];

	//set the title to the file name
	[self setTitle:[fileText lastPathComponent]];

	[[self view] setBackgroundColor:[UIColor whiteColor]];

	if (isPad) {
		//create custom ipad frame
		CGRect iPadFrame = [[self view] bounds];
		iPadFrame.size.width = 400;
		iPadFrame.origin.y += 44;
		iPadFrame.size.height -= 44;
		[[self view] setFrame:iPadFrame];

		[text setFrame:CGRectMake(5, 64, [[self view] bounds].size.width - 10, [[self view] bounds].size.height - 64)];
		[text setContentOffset:CGPointMake(0, 0)];

		//create navigation bar
		UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, iPadFrame.size.width, 44)];
		[navBar setTranslucent:NO];
		UINavigationItem *title = [UINavigationItem alloc];
		[title setTitle:[filePath lastPathComponent]];
		[navBar pushNavigationItem:title animated:NO];
		[[self view] addSubview:navBar];
	}

	return self;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	//hide the toolbar
	[[self navigationController] setToolbarHidden:YES];
}

@end
