//
//  EAAppSwitcherPreviewOverlay.m
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 1/30/14.
//  Copyright (c) 2014 Ethan Arbuckle. All rights reserved.
//

#import "EAAppSwitcherPreviewOverlay.h"

@implementation EAAppSwitcherPreviewOverlay

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _activeTorrents = [[NSMutableArray alloc] init];

        [self setTag:80085];
        [self setBackgroundColor:[UIColor blackColor]];
        [self setAlpha:0.9f];
        
        //create main text label
        if ([[[Delegate torrentController] fTorrents] count] > 0) {
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, [self bounds].size.width, 20)];
            [titleLabel setText:@"Active Torrents"];
            [titleLabel setFont:[UIFont boldSystemFontOfSize:25]];
            [titleLabel setTextAlignment:NSTextAlignmentCenter];
            [titleLabel setTextColor:[UIColor whiteColor]];
            [self addSubview:titleLabel];
            
            //create table with active
            UITableView *activeTable = [[UITableView alloc] initWithFrame:CGRectMake(10, 60, [self bounds].size.width - 20, [self bounds].size.height - 50)];
            [activeTable setDataSource:self];
            [activeTable setBackgroundColor:[UIColor clearColor]];
            [activeTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            [self addSubview:activeTable];
        }
        else { //no active torrents
            UILabel *noActive = [[UILabel alloc] initWithFrame:CGRectMake(0, ([self bounds].size.height/2)-10, [self bounds].size.width, 20)];
            [noActive setText:@"No Active Torrents!"];
            [noActive setTextAlignment:NSTextAlignmentCenter];
            [noActive setFont:[UIFont boldSystemFontOfSize:25]];
            [noActive setTextColor:[UIColor whiteColor]];
            [self addSubview:noActive];
        }

    }
    
    return self;
}

#pragma mark - UITableView datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    //add title
    [[cell textLabel] setText:[[(Torrent *)[_activeTorrents objectAtIndex:[indexPath row]] name] stringByReplacingOccurrencesOfString:@"+" withString:@" "]];
    [[cell textLabel] setTextColor:[UIColor whiteColor]];
    [[cell textLabel] setFont:[UIFont systemFontOfSize:20]];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    for (Torrent *t in [[Delegate torrentController] fTorrents]) {
        if ([t isSeeding] || [t isActive])
            [_activeTorrents addObject:t];
    }
    
    return [_activeTorrents count];
}


@end
