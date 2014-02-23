//
//  EACustomTorrentCell.m
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/28/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import "EACustomTorrentCell.h"

@implementation EACustomTorrentCell

#pragma mark - EACustomTorrentCell
- (id)init {
    if (self = [super init]) {
        
        //create name label
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, [[self contentView] frame].size.width - 10, 20)];
        [_titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
        
        //status label
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, [[self contentView] frame].size.width - 10, 20)];
        [_statusLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:10]];
        [_statusLabel setTextColor:[UIColor darkGrayColor]];
        [_statusLabel setBackgroundColor:[UIColor clearColor]];
        
        //progress label
        _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, [[self contentView] frame].size.width - 10, 20)];
        [_progressLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:10]];
        [_progressLabel setTextColor:[UIColor darkGrayColor]];
        [_progressLabel setBackgroundColor:[UIColor clearColor]];
        
        //progress bar
        _progressBar = [[UIProgressView alloc] initWithFrame:CGRectMake(5, 60, [[self contentView] frame].size.width - 10, 4)];
        
        //add elements to view
        [[self contentView] addSubview:_titleLabel];
        [[self contentView] addSubview:_statusLabel];
        [[self contentView] addSubview:_progressLabel];
        [[self contentView] addSubview:_progressBar];
    }
    
    return self;
}
@end
