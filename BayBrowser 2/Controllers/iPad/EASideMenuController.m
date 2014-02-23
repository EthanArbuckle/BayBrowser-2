//
//  EASideMenuController.m
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 2/12/14.
//  Copyright (c) 2014 Ethan Arbuckle. All rights reserved.
//

#import "EASideMenuController.h"

@implementation EASideMenuController

- (id)init
{
    if (self = [super init]) {
        
        //create static side table
        _sideMenuTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 200, [[self view] bounds].size.height-64)];
        [_sideMenuTable setDataSource:self];
        [_sideMenuTable setDelegate:self];
        [_sideMenuTable setBackgroundColor:[UIColor colorWithRed:0.800000 green:0.800000 blue:0.800000 alpha:1]];
        [_sideMenuTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [[self view] addSubview:_sideMenuTable];

        //update frame
        [[self view] setFrame:CGRectMake(0, 0, 200, [[self view] bounds].size.height)];
        
        //create navigationbar
        UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, [[self view] bounds].size.width, 44)];
        [navBar setTranslucent:NO];
        UINavigationItem *title = [UINavigationItem alloc];
        [title setTitle:@"BayBrowser"];
        [navBar pushNavigationItem:title animated:NO];
        [[self view] addSubview:navBar];
        
        //categories to be added. a + will indent that object by 2
        _categoryList = [[NSMutableArray alloc] initWithObjects:@"All",
                         @"Audio", @"+Music", @"+Audio Books", @"+Sound Clips", @"+FLAC", @"+Other",
                         @"Video", @"+Movies", @"+Music Videos", @"+Movie Clips", @"+TV Shows", @"+HD - Movies", @"+HD - TV Shows", @"+3D", @"+Other",
                         @"Applications", @"+Windows", @"+Mac", @"+iOS", @"+Android", @"+Other",
                         @"Games", @"+PC", @"+Mac", @"+PSx", @"+Xbox", @"+Wii", @"+iOS", @"+Android", @"+Other",
                         @"Other", @"+E-Books", @"+Comics", @"+Pictures", @"+Covers", @"+Physibles", @"+Other",
                         nil];
        
        if (SETTINGS_PORN_ENABLED)
            [_categoryList insertObject:@"Porn" atIndex:31];
        
        //schemes pulled from this list
        _schemeList = [[NSMutableArray alloc] initWithObjects:@"/top/all",
                       @"/browse/100", @"/browse/101", @"/browse/102", @"/browse/103", @"/browse/104", @"/browse/199",
                       @"/browse/200", @"/browse/201", @"/browse/203", @"/browse/204", @"/browse/205", @"/browse/207", @"/browse/208", @"/browse/209", @"/browse/299",
                       @"/browse/300", @"/browse/301", @"/browse/302", @"/browse/305", @"/browse/306", @"/browse/399",
                       @"/browse/400", @"/browse/401", @"/browse/402", @"/browse/403", @"/browse/404", @"/browse/405", @"/browse/407", @"/browse/408", @"/browse/499",
                       @"/browse/600", @"/browse/601", @"/browse/602", @"/browse/603", @"/browse/604", @"/browse/605", @"/browse/699",
                       nil];
        
        if (SETTINGS_PORN_ENABLED)
            [_schemeList insertObject:@"/browse/500" atIndex:31];
        
        _loadedControllers = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return [_categoryList count];
    else if (section == 1)
        return 2;
    else
        return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    [cell setBackgroundColor:[UIColor colorWithRed:0.800000 green:0.800000 blue:0.800000 alpha:1]]; //cell color
    
    UIView *selectedColor = [[UIView alloc] init];
    [selectedColor setBackgroundColor:[UIColor colorWithRed:0.600000 green:0.600000 blue:0.600000 alpha:1]]; //cell selected color
    [cell setSelectedBackgroundView:selectedColor];
    
    if ([indexPath section] == 0) {
        //remove plus signs
        if ([[_categoryList objectAtIndex:[indexPath row]] rangeOfString:@"+"].location != NSNotFound)
            [[cell textLabel] setText:[[_categoryList objectAtIndex:[indexPath row]] stringByReplacingOccurrencesOfString:@"+" withString:@""]];
        else
            [[cell textLabel] setText:[_categoryList objectAtIndex:[indexPath row]]];
    }
    
    if ([indexPath section] == 1) {
        
        if ([indexPath row] == 0)
            [[cell textLabel] setText:@"Active"];
        if ([indexPath row] == 1)
            [[cell textLabel] setText:@"File Browser"];
    }
    
    if ([indexPath section] == 2) {
        if ([indexPath row] == 0)
            [[cell textLabel] setText:@"Settings"];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    //indent objects beginning with a +
    if ([[_categoryList objectAtIndex:[indexPath row]] rangeOfString:@"+"].location != NSNotFound)
        return 2;
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //remove all controllers
    for (int i = 1; i < [[[Delegate rootStackController] viewControllers] count]; i++)
        [[Delegate rootStackController] removeControllerAtIndex:i];
    
    if ([indexPath section] == 0) {
        if ([indexPath row] == 0) {
            //allposts has a seperate controller
            EAMainPostsController *allPosts = [[EAMainPostsController alloc] init];
            [allPosts setIsPad:YES];
            [[Delegate rootStackController] pushViewController:allPosts animated:YES];
        }
        else {
            //dynamic controller
            EADynamicPostsController *dynamicController = [[EADynamicPostsController alloc] initWithScheme:[_schemeList objectAtIndex:[indexPath row]]];
            [dynamicController setIsPad:YES];
            [dynamicController setTitleForNavigationBar:[[_categoryList objectAtIndex:[indexPath row]] stringByReplacingOccurrencesOfString:@"+" withString:@""]];
            [[Delegate rootStackController] pushViewController:dynamicController animated:YES];
        }
    }
    
    if ([indexPath section] == 1) {
        
        
        if ([indexPath row] == 0) { //open active
            
            EATorrentDownloadManager *active = [[EATorrentDownloadManager alloc] initAsiPad:YES];
            [[Delegate rootStackController] pushViewController:active animated:YES];
        }
        
        if ([indexPath row] == 1) {
            
            EAFileBrowser *fileBrowser = [[EAFileBrowser alloc] initWithPath:@"/" isPad:YES];
            [[Delegate rootStackController] pushViewController:fileBrowser animated:YES];
            
        }
    }
    
    if ([indexPath section] == 2) {
        if ([indexPath row] == 0) {
            
            EASettingsController *settings = [[EASettingsController alloc] initAsPad:YES];
            
            [[Delegate rootStackController] pushViewController:settings animated:YES];
        }
    }
    
    [[[Delegate rootStackController] pagingView] setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return @"Categories";
    if (section == 1)
        return @"Downloads";
    else
        return @"BayBrowser 2.0.7";
}

@end
