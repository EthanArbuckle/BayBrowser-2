//
//  EAMusicPlayerController.h
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 12/1/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "EAVisualizer.h"
#import "EADynamicBlur.h"

@interface EAMusicPlayerController : UIViewController <UIActionSheetDelegate>

@property (nonatomic, strong) NSString *pathToAudioFile;
@property (nonatomic, strong) AVAudioPlayer *musicPlayer;
@property (nonatomic, strong) EAVisualizer *visView;
@property (nonatomic, strong) NSDictionary *audioInfo;

- (id)initWithAudioFilePath:(NSString *)audioFilePath;
- (id)initWithAudioFilePath:(NSString *)audioFilePath isPad:(BOOL)isPad;

@end
