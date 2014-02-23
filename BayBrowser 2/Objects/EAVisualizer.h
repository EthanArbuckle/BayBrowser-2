//
//  VisualizerView.h
//  iPodVisualizer
//
//  Created by Xinrong Guo on 13-3-30.
//  Copyright (c) 2013 Xinrong Guo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface EAVisualizer : UIView

- (void)stop;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@end
