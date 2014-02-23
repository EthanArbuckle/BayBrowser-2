//
//  EAMusicPlayerController.m
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 12/1/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import "EAMusicPlayerController.h"

@implementation EAMusicPlayerController

- (id)initWithAudioFilePath:(NSString *)audioFilePath {
    
    return [self initWithAudioFilePath:audioFilePath isPad:NO];
    
}

#pragma mark - UIViewController
- (id)initWithAudioFilePath:(NSString *)audioFilePath isPad:(BOOL)isPad {
    
    self = [super init];
    
	_pathToAudioFile = audioFilePath;
    
	//create audio info
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
	    NSURL *audioURL = [NSURL fileURLWithPath:_pathToAudioFile];
	    AudioFileID audioFile;
	    OSStatus theErr = noErr;
	    theErr = AudioFileOpenURL((__bridge CFURLRef)audioURL, kAudioFileReadPermission, 0, &audioFile);
	    UInt32 dictionarySize = 0;
	    theErr = AudioFileGetPropertyInfo(audioFile, kAudioFilePropertyInfoDictionary, &dictionarySize, 0);
	    CFDictionaryRef dictionary;
	    theErr = AudioFileGetProperty(audioFile, kAudioFilePropertyInfoDictionary, &dictionarySize, &dictionary);
	    if (dictionary) {
	        _audioInfo = (__bridge NSDictionary *)(dictionary);
	        [self setTitle:[_audioInfo objectForKey:@"title"]];
		}
	    else
			[self setTitle:[audioFilePath lastPathComponent]];
	});
    
    
    if (isPad) {
        
        CGRect iPadFrame = [[self view] bounds];
        iPadFrame.size.width = 400;
        iPadFrame.origin.y += 44;
        iPadFrame.size.height -= 44;
        [[self view] setFrame:iPadFrame];
        
        UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, iPadFrame.size.width, 44)];
        [navBar setTranslucent:NO];
        UINavigationItem *title = [UINavigationItem alloc];
        [title setTitle:[audioFilePath lastPathComponent]];
        [navBar pushNavigationItem:title animated:NO];
        [[self view] addSubview:navBar];
        
    }
    
    //create cool backgrond
	UIImageView *bgView = [[UIImageView alloc] initWithFrame:[[self view] frame]];
    
    //get iOS wallpaper
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/SpringBoard/LockBackgroundThumbnail.jpg"])
        [bgView setImage:[UIImage imageWithContentsOfFile:@"/var/mobile/Library/SpringBoard/LockBackgroundThumbnail.jpg"]];
    else
        [bgView setImage:[UIImage imageNamed:@"music_bg.png"]];
	[bgView layer].zPosition = -1;
	[[self view] addSubview:bgView];
    
	EADynamicBlur *blur = [[EADynamicBlur alloc] initWithFrame:[[self view] frame]];
	[bgView addSubview:blur];
    
    //audio player
	_musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:_pathToAudioFile] error:nil];
	[_musicPlayer setNumberOfLoops:-1];
	[_musicPlayer setMeteringEnabled:YES];
    
    //pretty visualizer
	_visView = [[EAVisualizer alloc] initWithFrame:CGRectMake(5, 0, [[self view] bounds].size.width - 10, [[self view] bounds].size.height - 170)];
	[_visView setAudioPlayer:_musicPlayer];
    
	//add song title label
	UILabel *songName = [[UILabel alloc] initWithFrame:CGRectMake(([[self view] bounds].size.width / 2) - 150, 330, 300, 20)];
	if (_audioInfo)
		[songName setText:[NSString stringWithFormat:@"%@ - %@", [_audioInfo objectForKey:@"artist"], [_audioInfo objectForKey:@"title"]]];
	else
		[songName setText:[audioFilePath lastPathComponent]];
	[songName setTextAlignment:NSTextAlignmentCenter];
	[[self view] addSubview:songName];
    
	MPVolumeView *volume = [[MPVolumeView alloc] initWithFrame:CGRectMake(20, [[self view] bounds].size.height - 90, [[self view] bounds].size.width - 40, 25)];
	[[self view] addSubview:volume];
    
	UIButton *playPause = [[UIButton alloc] initWithFrame:CGRectMake(([[self view] bounds].size.width / 2) - 55, [[self view] bounds].size.height - 140, 110, 55)];
	[playPause setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
	[playPause addTarget:self action:@selector(playPause:) forControlEvents:UIControlEventTouchUpInside];
	[[self view] addSubview:playPause];
    
	//UIBarButtonItem *importButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(importSong)];
	//[[self navigationItem] setRightBarButtonItem:importButton];
    
    if (isPad) {
        
        CGRect songFrame = [songName frame];
        songFrame.origin.y = playPause.frame.origin.y + 60;
        [songName setFrame:songFrame];
        
        songFrame = [_visView frame];
        songFrame = CGRectMake(0, 100, 400, 400);
        [_visView setFrame:songFrame];
        
    }
    
	return self;
}

- (void)importSong {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Import to Music Library", nil];
	[actionSheet showInView:[self view]];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    
	[[self navigationController] setToolbarHidden:YES animated:YES];
    
	[[self view] addSubview:_visView];
	[_musicPlayer play];
}

- (void)playPause:(UIButton *)sender {
    //detirines whether to play or pause
	if ([_musicPlayer isPlaying]) {
		[_musicPlayer pause];
		[sender setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
	}
	else {
		[_musicPlayer play];
		[sender setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
	}
}

- (void)dealloc {
	[_musicPlayer stop];
	_musicPlayer = nil;
	[[_visView audioPlayer] stop];
	[_visView stop];
}

#pragma mark - UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
    }
}

@end
