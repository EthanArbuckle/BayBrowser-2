//
//  EAiPadDelegate.m
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 2/12/14.
//  Copyright (c) 2014 Ethan Arbuckle. All rights reserved.
//

#import "EAiPadDelegate.h"
#import "Controller.h"

@implementation EAiPadDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[self setWindow:[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]];

	//create clone of splash screen
	UIImage *splashImage = [UIImage imageNamed:@"splashscreen_640x960.png"];
	UIImageView *splashView = [[UIImageView alloc] initWithFrame:[[self window] frame]];
	[splashView setImage:splashImage];
	[splashView layer].zPosition = 5;
	[[self window] addSubview:splashView];

	if (!SETTINGS_HAS_RUN) {
		//first run, set defaults
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"canDownload"];
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"doesRefresh"];
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"showsPorn"];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"canSeed"];
		[[NSUserDefaults standardUserDefaults] setValue:@"http://thepiratebay.tn" forKey:@"baseUrl"];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasRun"];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showsProgress"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"useWifi"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"useNetwork"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}

	//theme navigation bar
	[[UINavigationBar appearance] setTintColor:[[EAThemeManager sharedManager] colorforNavigationBarItems]];
	[[UINavigationBar appearance] setTitleTextAttributes:@{ UITextAttributeTextColor : [[EAThemeManager sharedManager] colorforNavigationBarItems] }];

	NSArray *sysVersion = [[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."];

	//wont crash on iOS 6
	if ([[sysVersion objectAtIndex:0] intValue] >= 7)
		[[UINavigationBar appearance] setBarTintColor:[[EAThemeManager sharedManager] colorForNavigationBarBackground]];
	else {
		UIAlertView *iOS6 = [[UIAlertView alloc] initWithTitle:@"Warning!" message:@"BayBrowser was *NOT* created for iOS 6. You will most likely run into a bunch of issues." delegate:nil cancelButtonTitle:@"I will not complain about it being broken" otherButtonTitles:nil, nil];
		[iOS6 show];
	}

	//create torrent controller and progress label
	_torrentController = [[Controller alloc] init];
	_universalProgressIndicator = [[EAProgressBar alloc] initWithFrame:CGRectZero];

	//create static side menu
	EASideMenuController *sideController = [[EASideMenuController alloc] init];

	EAMainPostsController *allPosts = [[EAMainPostsController alloc] init];
	[allPosts setIsPad:YES];

	//create iPad navigation stack
	_rootStackController = [[EAPanedNavigationController alloc] initWithRootViewController:nil];

	//push first controllers to view stack
	[_rootStackController pushViewController:sideController animated:YES];
	[_rootStackController pushViewController:allPosts animated:YES];

	//set navigation stack as window root controller
	[_window setRootViewController:_rootStackController];
	[_window makeKeyAndVisible];

	//theme status bar text
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

	//create symlink
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *downloadsFolder = [NSString stringWithFormat:@"%@/Downloads", documentsDirectory];
	[[NSFileManager defaultManager] linkItemAtPath:downloadsFolder toPath:@"/var/mobile/Downloads/BayBrowser Downloads" error:nil];

	//everything has loaded, animate splash screen off
	[UIView animateWithDuration:.6 animations: ^{
	    CGRect frame = [splashView frame];
	    frame.origin.x = -1 * frame.size.width;
	    [splashView setFrame:frame];
	} completion: ^(BOOL finished) {
	    [splashView removeFromSuperview];
	}];

	return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	//create app switcher overlay
	EAAppSwitcherPreviewOverlay *preview = [[EAAppSwitcherPreviewOverlay alloc] initWithFrame:[[self window] bounds]];

	[[self window] addSubview:preview];

	//save torrents
	[_torrentController updateTorrentHistory];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	//iterate though subviews until view with '80085' as a tag, removes the overlay
	for (id sub in[[self window] subviews])
		if ([sub tag] == 80085)
			[sub removeFromSuperview];
}

@end
