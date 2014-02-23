//
//  EASettingsController.m
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 12/9/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import "EASettingsController.h"

@implementation EASettingsController

- (id)init {
    
    return [self initAsPad:NO];
    
}

- (id)initAsPad:(BOOL)isPad {
	self = [super init];
    
	if (self) {
        
        _isPad = isPad;
        
		//create the table
        CGRect tableFrame = [[self view] bounds];
        if (!isPad)
            tableFrame.size.height -= 64;

		_table = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStyleGrouped];
		[_table setDelegate:self];
		[_table setDataSource:self];
		[[self view] addSubview:_table];
        
        if (isPad) {
            
            //create custom ipad frame
            CGRect iPadFrame = [[self view] bounds];
            iPadFrame.size.width = 400;
            iPadFrame.origin.y += 44;
            iPadFrame.size.height -= 50;
            [[self view] setFrame:iPadFrame];
            [_table setFrame:iPadFrame];
            
            //create navigation bar
            UINavigationBar *_navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, iPadFrame.size.width, 44)];
            [_navBar setTranslucent:NO];
            [_navBar layer].zPosition = 5;
            UINavigationItem *title = [UINavigationItem alloc];
            [title setTitle:@"BayBrowser Settings"];
            [_navBar pushNavigationItem:title animated:YES];
            [[self view] addSubview:_navBar];
            
        }
        
		//hides keypad when background tapped
		UITapGestureRecognizer *dismissKey = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
		[dismissKey setCancelsTouchesInView:NO];
		[[self view] addGestureRecognizer:dismissKey];
        
        //create contact bar button
        UIBarButtonItem *contactBar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(contact)];
        [[self navigationItem] setRightBarButtonItem:contactBar];
        
        //setup the tableview cell ui stuff
        _lMaximumConnections = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
        _lConnectionsPTorrent = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
        _lUploadLimit = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 20)];
        [_lUploadLimit setTextAlignment:NSTextAlignmentRight];
        _lDownloadLimit = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 20)];
        [_lDownloadLimit setTextAlignment:NSTextAlignmentRight];
        
	}
    
	return self;
}

- (void)dismissKeyboard {
	//find the freaking textfield
	for (id sub in[[self view] subviews]) {
		if ([sub isKindOfClass:[UITableView class]]) {
			UITableViewCell *cell = [(UITableView *)sub cellForRowAtIndexPath :[NSIndexPath indexPathForRow:0 inSection:0]];
			for (id subv in[[cell contentView] subviews])
				if ([subv isKindOfClass:[UITextField class]]) {
					[(UITextField *)subv resignFirstResponder];
					[[NSUserDefaults standardUserDefaults] setValue:[subv text] forKey:@"baseUrl"];
					[[NSUserDefaults standardUserDefaults] synchronize];
				}
		}
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    
    //hide the toolbar
	[[self navigationController] setToolbarHidden:YES];
    [self becomeFirstResponder];
    
	//refresh table
	for (id sub in[[self view] subviews]) {
		if ([sub isKindOfClass:[UITableView class]])
			[(UITableView *)sub reloadData];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 6;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0)
		return @"Base URL";
    if (section == 1)
        return @"";
    if (section == 2)
        return @"Connections";
    if (section == 3)
        return @"Upload";
    if (section == 4)
        return @"Download";
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0)
		return 1;
    if (section == 1) {
        return 4;
    }
    if (section == 2)
        return 4;
    if (section == 3)
        return 3;
    if (section == 4)
        return 3;
    if (section == 5)
        return 1;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [[UITableViewCell alloc] init];
	if ([indexPath section] == 0) {
		//create base url text field for cell
		CGRect frame = [cell bounds];
		frame.origin.x = 5;
		frame.size.width -= 10;
		UITextField *urlField = [[UITextField alloc] initWithFrame:frame];
		[urlField setReturnKeyType:UIReturnKeyDone];
		[urlField setText:SETTINGS_BASE_URL];
		[urlField setDelegate:self];
		[[cell contentView] addSubview:urlField];
	}
    
	if ([indexPath section] == 1) {
		if ([indexPath row] == 0)
			[[cell textLabel] setText:@"Enable Downloading"];
		if ([indexPath row] == 1)
			[[cell textLabel] setText:@"Enable 'Porn' Category"];
		if ([indexPath row] == 2)
			[[cell textLabel] setText:@"Enable Seeding"];
        if ([indexPath row] == 3)
            [[cell textLabel] setText:@"Enable Status Bar Progress"];

		[self setupSwitchCell:cell atIndex:[indexPath row]]; //adds switch to each cell
	}
    
    if ([indexPath section] == 2) {
        if ([indexPath row] == 0) {
            [[cell textLabel] setText:@"Maximum Connections"];
            [_lMaximumConnections setText:[NSString stringWithFormat:@"%d", [[Delegate torrentController] globalMaximumConnections]]];
            [cell setAccessoryView:_lMaximumConnections];
        }
        if ([indexPath row] == 1) {
            UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(10, 17, [[self view] frame].size.width - 20, 10)];
            [slider addTarget:self action:@selector(maxConnectionsValueChanged:) forControlEvents:UIControlEventValueChanged];
            [slider setValue:(float)[[Delegate torrentController] globalMaximumConnections]/100];
            [cell addSubview:slider];
        }
        if ([indexPath row] == 2) {
            [[cell textLabel] setText:@"Connections Per Torrent"];
            [_lConnectionsPTorrent setText:[NSString stringWithFormat:@"%d", [[Delegate torrentController] connectionsPerTorrent]]];
            [cell setAccessoryView:_lConnectionsPTorrent];
        }
        if ([indexPath row] == 3) {
            UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(10, 17, [[self view] frame].size.width - 20, 10)];
            [slider addTarget:self action:@selector(connectionsPTorrentChanged:) forControlEvents:UIControlEventValueChanged];
            [slider setValue:(float)[[Delegate torrentController] connectionsPerTorrent]/100];
            [cell addSubview:slider];
        }
    }
    
    if ([indexPath section] == 3) {
        if ([indexPath row] == 0) {
            [[cell textLabel] setText:@"Enable Upload Limit"];
            UISwitch *enable = [[UISwitch alloc] init];
            [enable setOn:[[Delegate torrentController] globalUploadSpeedLimitEnabled]];
            [enable addTarget:self action:@selector(enableUploadChanged:) forControlEvents:UIControlEventValueChanged];
            [cell setAccessoryView:enable];
        }
        if ([indexPath row] == 1) {
            [[cell textLabel] setText:@"Upload Limit (KB/s)"];
            [_lUploadLimit setText:[NSString stringWithFormat:@"%d", [[Delegate torrentController] globalUploadSpeedLimit]]];
            [cell setAccessoryView:_lUploadLimit];
        }
        if ([indexPath row] == 2) {
            UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(10, 17, [[self view] frame].size.width - 20, 10)];
            [slider addTarget:self action:@selector(uploadLimitChanged:) forControlEvents:UIControlEventValueChanged];
            [slider setValue:(float)[[Delegate torrentController] globalUploadSpeedLimit]/5000];
            [cell addSubview:slider];
        }
    }
    
    if ([indexPath section] == 4) {
        if ([indexPath row] == 0) {
            [[cell textLabel] setText:@"Enable Download Limit"];
            UISwitch *enable = [[UISwitch alloc] init];
            [enable setOn:[[Delegate torrentController] globalDownloadSpeedLimitEnabled]];
            [enable addTarget:self action:@selector(enableDownloadChanged:) forControlEvents:UIControlEventValueChanged];
            [cell setAccessoryView:enable];
        }
        if ([indexPath row] == 1) {
            [[cell textLabel] setText:@"Download Limit (KB/s)"];
            [_lDownloadLimit setText:[NSString stringWithFormat:@"%d", [[Delegate torrentController] globalDownloadSpeedLimit]]];
            [cell setAccessoryView:_lDownloadLimit];
        }
        if ([indexPath row] == 2) {
            UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(10, 17, [[self view] frame].size.width - 20, 10)];
            [slider addTarget:self action:@selector(downloadLimitChanged:) forControlEvents:UIControlEventValueChanged];
            [slider setValue:(float)[[Delegate torrentController] globalDownloadSpeedLimit]/5000];
            [cell addSubview:slider];
        }
    }
    
    if ([indexPath section] == 5) {
        [[cell textLabel] setText:@"BayBrowser 2.0.7 Changelog"];
    }
    
	return cell;
}

- (void)setupSwitchCell:(UITableViewCell *)cell atIndex:(NSInteger)row {
	// create a uiswitch - add it to cell
	UISwitch *cellSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
	[cellSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
	[cellSwitch setTag:row];
    
	switch (row) {
		case 0:
			[cellSwitch setOn:SETTINGS_CAN_DOWNLOAD];
			break;
            
		case 1:
			[cellSwitch setOn:SETTINGS_PORN_ENABLED];
			break;
            
		case 2:
			[cellSwitch setOn:SETTINGS_CAN_SEED];
			break;
        case 3:
            [cellSwitch setOn:SETTINGS_PROGRESS_ENABLED];
            break;
            
		default:
			break;
	}
    
	[cell setAccessoryView:cellSwitch];
}

- (void)switchChanged:(UISwitch *)cellSwitch {
	//switch tapped, update settings
	switch ([cellSwitch tag]) {
		case 0:
			[[NSUserDefaults standardUserDefaults] setBool:[cellSwitch isOn] forKey:@"canDownload"];
			break;
            
		case 1: {
			[[NSUserDefaults standardUserDefaults] setBool:[cellSwitch isOn] forKey:@"showsPorn"];
            if ([cellSwitch isOn]) {
                if (_isPad) {
                    [[(EASideMenuController *)[[[Delegate rootStackController] viewControllers] objectAtIndex:0] categoryList] insertObject:@"Porn" atIndex:31];
                    [[(EASideMenuController *)[[[Delegate rootStackController] viewControllers] objectAtIndex:0] schemeList] insertObject:@"/browse/500" atIndex:31];
                    [[(EASideMenuController *)[[[Delegate rootStackController] viewControllers] objectAtIndex:0] sideMenuTable] reloadData];
                }
                //else
                   // [[Delegate slideoutController] addPornToTable:[[EADynamicPostsController alloc] initWithScheme:@"/browse/500"]];
            }
            else {
                if (_isPad) {
                    [[(EASideMenuController *)[[[Delegate rootStackController] viewControllers] objectAtIndex:0] categoryList] removeObjectAtIndex:31];
                    [[(EASideMenuController *)[[[Delegate rootStackController] viewControllers] objectAtIndex:0] schemeList] removeObjectAtIndex:31];
                    [[(EASideMenuController *)[[[Delegate rootStackController] viewControllers] objectAtIndex:0] sideMenuTable] reloadData];
                }
               // else
                  //  [[Delegate slideoutController] removePornFromTable];
            }
			break;
		}
            
		case 2:
			[[NSUserDefaults standardUserDefaults] setBool:[cellSwitch isOn] forKey:@"canSeed"];
			break;
            
        case 3:
            [[NSUserDefaults standardUserDefaults] setBool:[cellSwitch isOn] forKey:@"showsProgress"];
            
		default:
			break;
	}
    
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    if ([indexPath section] == 5) {
        UIAlertView *changelog = [[UIAlertView alloc] initWithTitle:@"BayBrowser 2.0.7 Changelog" message:@"No More Pro\n\n" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
        [changelog show];
    }
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	//save base url
	[[NSUserDefaults standardUserDefaults] setValue:[textField text] forKey:@"baseUrl"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[textField resignFirstResponder];
    
	return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 10.0;
}

- (void)contact {
    UIActionSheet *contactSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Done" destructiveButtonTitle:Nil otherButtonTitles:@"Email me", @"Follow me!", nil];
    [contactSheet showInView:[self view]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:ethan.a.arbuckle@gmail.com"]];
    if (buttonIndex == 1)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/its_not_herpes"]];
}

- (void)maxConnectionsValueChanged:(UISlider *)sender {
    [_lMaximumConnections setText:[NSString stringWithFormat:@"%d", (int)round([sender value]*100)]];
    //update controller
    [[Delegate torrentController] setGlobalMaximumConnections:(int)round([sender value]*100)];
}

- (void)connectionsPTorrentChanged:(UISlider *)sender {
    [_lConnectionsPTorrent setText:[NSString stringWithFormat:@"%d", (int)round([sender value]*100)]];
    //update controller
    [[Delegate torrentController] setConnectionsPerTorrent:(int)round([sender value]*100)];
}

- (void)enableUploadChanged:(UISwitch *)sender {
    [[Delegate torrentController] setGlobalUploadSpeedLimitEnabled:[sender isOn]];
}

- (void)uploadLimitChanged:(UISlider *)sender {
    [_lUploadLimit setText:[NSString stringWithFormat:@"%d", (int)([sender value]*5000)]];
    [[Delegate torrentController] setGlobalUploadSpeedLimit:(int)([sender value]*5000)];
}

- (void)enableDownloadChanged:(UISwitch *)sender {
    [[Delegate torrentController] setGlobalDownloadSpeedLimitEnabled:[sender isOn]];
}

- (void)downloadLimitChanged:(UISlider *)sender {
    [_lDownloadLimit setText:[NSString stringWithFormat:@"%d", (int)([sender value]*5000)]];
    [[Delegate torrentController] setGlobalDownloadSpeedLimit:(int)([sender value]*5000)];
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.type == UIEventSubtypeMotionShake)
    {
        [[UIPasteboard generalPasteboard] setString:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
        [TSMessage showNotificationWithTitle:@"Copied Device Identifer!" type:TSMessageNotificationTypeSuccess];
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)viewDidPinch:(UIPinchGestureRecognizer *)pinch {
    
    if ([pinch state] == UIGestureRecognizerStateChanged) {
        if ([pinch scale] >= 0.75 && [pinch scale] <= 1.2) {
            [self resizeByFactor:[pinch scale]];
            [[self view] setAlpha:[pinch scale]];
        }
        
        if ([pinch scale] < 0.70) {
            [[Delegate rootStackController] removeControllerAtIndex:[[[Delegate rootStackController] viewControllers] indexOfObject:self]];
        }
    }
    
    if ([pinch state] == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:.2 animations:^{
            [[self view] setTransform:CGAffineTransformIdentity];
            [[self view] setAlpha:1];
        }];
    }
    
    
}

- (void)resizeByFactor:(CGFloat)factor {
    
    CGAffineTransform transform = CGAffineTransformMakeScale(factor, factor);
    self.view.transform = transform;
}

@end
