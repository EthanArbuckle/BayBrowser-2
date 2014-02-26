//
//  EAAppDelegate.m
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/11/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import "EAiPhoneDelegate.h"
#import "Torrent.h"

@implementation EAiPhoneDelegate

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
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasRun 2.0.7"];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showsProgress"];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"useWifi"];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"useNetwork"];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showOverlay"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}

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

	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *downloadsFolder = [NSString stringWithFormat:@"%@/Downloads", documentsDirectory];

	_pullOutMenu = [[EAPullOutTableController alloc] init];

	[[self window] setRootViewController:_pullOutMenu];

	[[self window] makeKeyAndVisible];

	_universalProgressIndicator = [[EAProgressBar alloc] initWithFrame:CGRectZero];
	[_window addSubview:_universalProgressIndicator];

	_torrentController = [[Controller alloc] init];

	//everything has loaded, animate splash screen off
	[UIView animateWithDuration:.3 animations: ^{
	    CGRect frame = [splashView frame];
	    frame.origin.x = -500;
	    [splashView setFrame:frame];
	} completion: ^(BOOL finished) {
	    [splashView removeFromSuperview];
	}];

	[[UIApplication sharedApplication] endBackgroundTask:_backgroundRunner];
	_backgroundRunner = UIBackgroundTaskInvalid;

	//create link
	[[NSFileManager defaultManager] linkItemAtPath:downloadsFolder toPath:@"/var/mobile/Downloads/BayBrowser Downloads" error:nil];

	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	
	//create network speed view
	EANetworkSpeedOverlay *networkSpeed = [[EANetworkSpeedOverlay alloc] initAsPad:NO];
	if (SETTINGS_SHOW_OVERLAY)
		[networkSpeed addNetworkOverlay];
	else
		[networkSpeed removeNetworkOverlay];
	[[self window] addSubview:networkSpeed];

	return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	//iterate though subviews until view with '80085' as a tag, removes the overlay
	for (id sub in[[self window] subviews])
		if ([sub tag] == 80085)
			[sub removeFromSuperview];
}

//this method is what creates the appswitcher preview overlay
- (void)applicationDidEnterBackground:(UIApplication *)application {
	//save torrents
	[_torrentController updateTorrentHistory];

	EAAppSwitcherPreviewOverlay *preview = [[EAAppSwitcherPreviewOverlay alloc] initWithFrame:[[self window] bounds]];

	[[self window] addSubview:preview];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	//restore torrents
	if (_torrentController) {
		[_torrentController loadTorrentHistory];
	}
}

- (void)applicationWillResignActive:(UIApplication *)application {
	//background downloading
	_backgroundRunner = [application beginBackgroundTaskWithExpirationHandler: ^{
	    BOOL hasRunningTorrents;
	    for (Torrent *torrent in[_torrentController fTorrents]) {
	        if (![torrent isComplete]) {
	            hasRunningTorrents = YES;
	            break;
			}
		}
	    if (hasRunningTorrents) {
	        //[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTorrents) userInfo:nil repeats:YES];
		}
	    else {
	        [application endBackgroundTask:_backgroundRunner];
	        _backgroundRunner = UIBackgroundTaskInvalid;
		}
	}];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	//add the torrent
	[_torrentController addTorrentFromManget:[url absoluteString]];

	return YES;
}

- (void)updateTorrents {
	for (Torrent *torrent in[_torrentController fTorrents]) {
		[torrent update];
		[_torrentController updateGlobalSpeed];
		if ([torrent isComplete]) {
			[[_torrentController fTorrents] removeObject:torrent];
			UILocalNotification *notification = [[UILocalNotification alloc] init];
			notification.alertBody = [NSString stringWithFormat:@"Finished downloading %@", torrent];
			notification.alertAction = @"Open";
			[[UIApplication sharedApplication] scheduleLocalNotification:notification];
		}
	}
}

@end
