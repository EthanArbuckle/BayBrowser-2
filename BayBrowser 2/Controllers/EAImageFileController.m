//
//  EAImageFileController.m
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 12/3/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import "EAImageFileController.h"

@implementation EAImageFileController

#pragma mark - UIViewController

- (id)initWithPathToImage:(NSString *)imagePath {

    return [self initWithPathToImage:imagePath isPad:YES];
    
}

- (id)initWithPathToImage:(NSString *)imagePath isPad:(BOOL)isPad {
    self = [super init];
    
    if (isPad) {
        
        CGRect iPadFrame = [[self view] bounds];
        iPadFrame.size.width = 400;
        iPadFrame.origin.y += 44;
        iPadFrame.size.height -= 44;
        [[self view] setFrame:iPadFrame];
        
        UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, iPadFrame.size.width, 44)];
        [navBar setTranslucent:NO];
        UINavigationItem *title = [UINavigationItem alloc];
        [title setTitle:[imagePath lastPathComponent]];
        [navBar pushNavigationItem:title animated:NO];
        [[self view] addSubview:navBar];
        
    }
    
    //create image + gif support
    UIImage *image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL fileURLWithPath:imagePath]];
    AFImageViewer *gallery = [[AFImageViewer alloc] initWithFrame:CGRectMake(0, 0, [[self view] frame].size.width, [[self view] frame].size.height-40)];
    [gallery setImages:[NSArray arrayWithObject:image]];
    [gallery layer].zPosition = 2;
    
    //create cool background
	UIImageView *bgView = [[UIImageView alloc] initWithFrame:[[self view] frame]];
    
    //get iOS wallpaper
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/SpringBoard/LockBackgroundThumbnail.jpg"])
        [bgView setImage:[UIImage imageWithContentsOfFile:@"/var/mobile/Library/SpringBoard/LockBackgroundThumbnail.jpg"]];
    else
        [bgView setImage:[UIImage imageNamed:@"music_bg.png"]];
	[bgView layer].zPosition = -1;
	[[self view] addSubview:bgView];
    
	EADynamicBlur *blur = [[EADynamicBlur alloc] initWithFrame:[[self view] frame]];
	[[self view] addSubview:blur];
    
    [[self view] addSubview:gallery];
    
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self navigationController] setToolbarHidden:YES];
}
@end
