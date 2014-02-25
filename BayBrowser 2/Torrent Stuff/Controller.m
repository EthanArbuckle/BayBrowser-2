//
//  Controller.m
//  iTransmission
//
//  Created by Mike Chen on 10/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Controller.h"
#import "Torrent.h"
#import "Notifications.h"
#import "TorrentFetcher.h"
#include <stdlib.h>

static tr_rpc_callback_status rpcCallback(tr_session * handle UNUSED, tr_rpc_callback_type type, struct tr_torrent * torrentStruct,
                                          void * controller)
{
    [(Controller *)controller rpcCallback: type forTorrentStruct: torrentStruct];
    return TR_RPC_NOREMOVE; //we'll do the remove manually
}

@implementation Controller

@synthesize window;
@synthesize navController;
@synthesize torrentViewController;
@synthesize activityCounter;
@synthesize logMessageTimer = fLogMessageTimer;
@synthesize installedApps = fInstalledApps;
@synthesize fileLogger = fFileLogger, fTorrents;

#pragma mark -
#pragma mark Application lifecycle

- (id)init {
    self = [super init];
    [self resetToDefaultPreferences];
    [self fixDocumentsDirectory];
	[self transmissionInitialize];
    
    self.installedApps = [self findRelatedApps];
    return self;
}

- (NSArray*)findRelatedApps
{
    NSMutableArray *ret = [NSMutableArray array];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"ifile://"]]) {
        [ret addObject:@"ifile"];
    }
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]]) {
        [ret addObject:@"cydia"];
    }
    
    return [NSArray arrayWithArray:ret];
}

- (void)resetToDefaultPreferences
{
    [NSUserDefaults resetStandardUserDefaults];
    fDefaults = [NSUserDefaults standardUserDefaults];
    [fDefaults setBool:YES forKey:@"SpeedLimitAuto"];
    [fDefaults setBool:NO forKey:@"AutoStartDownload"];
    [fDefaults setBool:YES forKey:@"DHTGlobal"];
    [fDefaults setInteger:0 forKey:@"DownloadLimit"];
    [fDefaults setInteger:0 forKey:@"UploadLimit"];
    [fDefaults setBool:NO forKey:@"DownloadLimitEnabled"];
    [fDefaults setBool:NO forKey:@"UploadLimitEnabled"];
    [fDefaults setObject:[self defaultDownloadDir] forKey:@"DownloadFolder"];
    [fDefaults setObject:[self defaultDownloadDir] forKey:@"IncompleteDownloadFolder"];
    [fDefaults setBool:NO forKey:@"UseIncompleteDownloadFolder"];
    [fDefaults setBool:YES forKey:@"LocalPeerDiscoveryGlobal"];
    [fDefaults setInteger:30 forKey:@"PeersTotal"];
    [fDefaults setInteger:20 forKey:@"PeersTorrent"];
    [fDefaults setBool:NO forKey:@"RandomPort"];
    [fDefaults setInteger:30901 forKey:@"BindPort"];
    [fDefaults setInteger:0 forKey:@"PeerSocketTOS"];
    [fDefaults setBool:YES forKey:@"PEXGlobal"];
    [fDefaults setBool:YES forKey:@"NatTraversal"];
    [fDefaults setBool:NO forKey:@"Proxy"];
    [fDefaults setInteger:0 forKey:@"ProxyPort"];
    [fDefaults setFloat:0.0f forKey:@"RatioLimit"];
    [fDefaults setBool:NO forKey:@"RatioCheck"];
    [fDefaults setBool:YES forKey:@"RenamePartialFiles"];
    [fDefaults setBool:NO forKey:@"RPCAuthorize"];
    [fDefaults setBool:NO forKey:@"RPC"];
	[fDefaults setObject:@"" forKey:@"RPCUsername"];
    [fDefaults setObject:@"" forKey:@"RPCPassword"];
	[fDefaults setInteger:9091 forKey:@"RPCPort"];
    [fDefaults setBool:NO forKey:@"RPCUseWhitelist"];
	[fDefaults setBool:YES forKey:@"UseWiFi"];
	[fDefaults setBool:NO forKey:@"UseCellularNetwork"];
	[fDefaults synchronize];
}

- (void)transmissionInitialize
{
	fDefaults = [NSUserDefaults standardUserDefaults];
    
    if (![fDefaults boolForKey:@"NotFirstRun"]) {
        [self resetToDefaultPreferences];
        [fDefaults setBool:YES forKey:@"NotFirstRun"];
        [self performSelector:@selector(firstRunMessage) withObject:nil afterDelay:0.5f];
    }
    
    //checks for old version speeds of -1
    if ([fDefaults integerForKey: @"UploadLimit"] < 0)
    {
        [fDefaults removeObjectForKey: @"UploadLimit"];
        [fDefaults setBool: NO forKey: @"CheckUpload"];
    }
    if ([fDefaults integerForKey: @"DownloadLimit"] < 0)
    {
        [fDefaults removeObjectForKey: @"DownloadLimit"];
        [fDefaults setBool: NO forKey: @"CheckDownload"];
    }
    
    tr_bencInitDict(&settings, 41);
    tr_sessionGetDefaultSettings(&settings);
    
    tr_bencDictAddBool(&settings, TR_PREFS_KEY_ALT_SPEED_ENABLED, [fDefaults boolForKey: @"SpeedLimit"]);
    
	tr_bencDictAddBool(&settings, TR_PREFS_KEY_ALT_SPEED_TIME_ENABLED, NO);
    
    tr_bencDictAddInt(&settings, TR_PREFS_KEY_DSPEED_KBps, [fDefaults integerForKey: @"DownloadLimit"]);
    tr_bencDictAddBool(&settings, TR_PREFS_KEY_DSPEED_ENABLED, [fDefaults boolForKey: @"DownloadLimitEnabled"]);
    tr_bencDictAddInt(&settings, TR_PREFS_KEY_USPEED_KBps, [fDefaults integerForKey: @"UploadLimit"]);
    tr_bencDictAddBool(&settings, TR_PREFS_KEY_USPEED_ENABLED, [fDefaults boolForKey: @"UploadLimitEnabled"]);
    
	tr_bencDictAddBool(&settings, TR_PREFS_KEY_BLOCKLIST_ENABLED, [fDefaults boolForKey: @"Blocklist"]);
	tr_bencDictAddBool(&settings, TR_PREFS_KEY_DHT_ENABLED, [fDefaults boolForKey: @"DHTGlobal"]);
	tr_bencDictAddStr(&settings, TR_PREFS_KEY_DOWNLOAD_DIR, [[self defaultDownloadDir] cStringUsingEncoding:NSASCIIStringEncoding]);
	tr_bencDictAddStr(&settings, TR_PREFS_KEY_DOWNLOAD_DIR, [[[fDefaults stringForKey: @"DownloadFolder"]
															  stringByExpandingTildeInPath] UTF8String]);
	tr_bencDictAddStr(&settings, TR_PREFS_KEY_INCOMPLETE_DIR, [[[fDefaults stringForKey: @"IncompleteDownloadFolder"]
																stringByExpandingTildeInPath] UTF8String]);
	tr_bencDictAddBool(&settings, TR_PREFS_KEY_INCOMPLETE_DIR_ENABLED, [fDefaults boolForKey: @"UseIncompleteDownloadFolder"]);

	tr_bencDictAddBool(&settings, TR_PREFS_KEY_LPD_ENABLED, [fDefaults boolForKey: @"LocalPeerDiscoveryGlobal"]);
	tr_bencDictAddInt(&settings, TR_PREFS_KEY_MSGLEVEL, TR_MSG_DBG);
	tr_bencDictAddInt(&settings, TR_PREFS_KEY_PEER_LIMIT_GLOBAL, [fDefaults integerForKey: @"PeersTotal"]);
	tr_bencDictAddInt(&settings, TR_PREFS_KEY_PEER_LIMIT_TORRENT, [fDefaults integerForKey: @"PeersTorrent"]);
	
	const BOOL randomPort = [fDefaults boolForKey: @"RandomPort"];
	tr_bencDictAddBool(&settings, TR_PREFS_KEY_PEER_PORT_RANDOM_ON_START, randomPort);
	if (!randomPort)
		tr_bencDictAddInt(&settings, TR_PREFS_KEY_PEER_PORT, [fDefaults integerForKey: @"BindPort"]);
	
	if ([fDefaults objectForKey: @"PeerSocketTOS"])
		tr_bencDictAddInt(&settings, TR_PREFS_KEY_PEER_SOCKET_TOS, [fDefaults integerForKey: @"PeerSocketTOS"]);
	
    tr_bencDictAddBool(&settings, TR_PREFS_KEY_PEX_ENABLED, [fDefaults boolForKey: @"PEXGlobal"]);
    tr_bencDictAddBool(&settings, TR_PREFS_KEY_PORT_FORWARDING, [fDefaults boolForKey: @"NatTraversal"]);
    tr_bencDictAddReal(&settings, TR_PREFS_KEY_RATIO, [fDefaults floatForKey: @"RatioLimit"]);
    tr_bencDictAddBool(&settings, TR_PREFS_KEY_RATIO_ENABLED, [fDefaults boolForKey: @"RatioCheck"]);
    tr_bencDictAddBool(&settings, TR_PREFS_KEY_RENAME_PARTIAL_FILES, [fDefaults boolForKey: @"RenamePartialFiles"]);
    tr_bencDictAddBool(&settings, TR_PREFS_KEY_RPC_AUTH_REQUIRED,  [fDefaults boolForKey: @"RPCAuthorize"]);
    tr_bencDictAddBool(&settings, TR_PREFS_KEY_RPC_ENABLED,  [fDefaults boolForKey: @"RPC"]);
    tr_bencDictAddInt(&settings, TR_PREFS_KEY_RPC_PORT, [fDefaults integerForKey: @"RPCPort"]);
    tr_bencDictAddStr(&settings, TR_PREFS_KEY_RPC_USERNAME,  [[fDefaults stringForKey: @"RPCUsername"] UTF8String]);
    tr_bencDictAddBool(&settings, TR_PREFS_KEY_RPC_WHITELIST_ENABLED,  [fDefaults boolForKey: @"RPCUseWhitelist"]);
    tr_bencDictAddBool(&settings, TR_PREFS_KEY_START, [fDefaults boolForKey: @"AutoStartDownload"]);
    tr_bencDictAddBool(&settings, TR_PREFS_KEY_SCRIPT_TORRENT_DONE_ENABLED, [fDefaults boolForKey: @"DoneScriptEnabled"]);
    tr_bencDictAddStr(&settings, TR_PREFS_KEY_SCRIPT_TORRENT_DONE_FILENAME, [[fDefaults stringForKey: @"DoneScriptPath"] UTF8String]);
    tr_bencDictAddBool(&settings, TR_PREFS_KEY_UTP_ENABLED, [fDefaults boolForKey: @"UTPGlobal"]);
    
    tr_formatter_size_init(1000, [NSLocalizedString(@"KB", "File size - kilobytes") UTF8String],
                           [NSLocalizedString(@"MB", "File size - megabytes") UTF8String],
                           [NSLocalizedString(@"GB", "File size - gigabytes") UTF8String],
                           [NSLocalizedString(@"TB", "File size - terabytes") UTF8String]);
    
    tr_formatter_speed_init(1000,
                            [NSLocalizedString(@"KB/s", "Transfer speed (kilobytes per second)") UTF8String],
                            [NSLocalizedString(@"MB/s", "Transfer speed (megabytes per second)") UTF8String],
                            [NSLocalizedString(@"GB/s", "Transfer speed (gigabytes per second)") UTF8String],
                            [NSLocalizedString(@"TB/s", "Transfer speed (terabytes per second)") UTF8String]); //why not?
    
    tr_formatter_mem_init(1024, [NSLocalizedString(@"KB", "Memory size - kilobytes") UTF8String],
                          [NSLocalizedString(@"MB", "Memory size - megabytes") UTF8String],
                          [NSLocalizedString(@"GB", "Memory size - gigabytes") UTF8String],
                          [NSLocalizedString(@"TB", "Memory size - terabytes") UTF8String]);
	
	fLib = tr_sessionInit("macosx", [[self configDir] cStringUsingEncoding:NSASCIIStringEncoding], YES, &settings);
	tr_bencFree(&settings);
    
    NSString *webDir = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"web"];
    if (setenv("TRANSMISSION_WEB_HOME", [webDir cStringUsingEncoding:NSUTF8StringEncoding], 1)) {
        NSLog(@"Failed to set \"TRANSMISSION_WEB_HOME\" environmental variable. ");
    }
	
	fTorrents = [[NSMutableArray alloc] init];	
    fActivities = [[NSMutableArray alloc] init];
    tr_sessionSetRPCCallback(fLib, rpcCallback, self);
	
	fUpdateInProgress = NO;
	
	fPauseOnLaunch = YES;
    
    [self loadTorrentHistory];
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(torrentFinished:) name:@"TorrentFinishedDownloading" object:nil];
}

- (tr_session*)rawSession
{
    return fLib;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [fTorrents release];
    self.logMessageTimer = nil;
    fTorrents = nil;
    [fActivities release];
    fActivities = nil;
	self.window = nil;
    self.installedApps = nil;
    self.torrentViewController = nil;
    self.fileLogger = nil;
	[super dealloc];
}

- (NSString*)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

- (void)updateTorrentHistory
{
    NSError *err = nil;
    [[NSFileManager defaultManager] removeItemAtPath:[self transferPlist] error:&err];
    NSMutableArray *torrents = [[NSMutableArray alloc] init];
    for (Torrent * torrent in fTorrents) {
        [torrents addObject:[torrent history]];
    }
    [torrents writeToFile: [self transferPlist] atomically: NO];
    
}

- (void)loadTorrentHistory
{
    return;
    NSArray * history = [NSArray arrayWithContentsOfFile: [self transferPlist]];
    if (!history)
    {
        //old version saved transfer info in prefs file
        if ((history = [fDefaults arrayForKey: @"History"]))
            [fDefaults removeObjectForKey: @"History"];
    }
    
    if (history)
    {
        for (NSDictionary *historyItem in history)
        {
            Torrent *torrent = [[Torrent alloc] initWithHistory:historyItem lib:fLib forcePause:NO];
            if (torrent) {
                [fTorrents addObject:torrent];
                if ([[historyItem objectForKey:@"isComplete"] boolValue])
                    [torrent stopTransfer];
            }
        }
    }
}

- (NSString*)defaultDownloadDir
{
    return [[self documentsDirectory] stringByAppendingPathComponent:@"Downloads"];
}

- (NSString*)transferPlist
{
	return [[self documentsDirectory] stringByAppendingPathComponent:@"Transfer.plist"];
}

- (NSString*)torrentsPath
{
	return [[self documentsDirectory] stringByAppendingPathComponent:@"torrents"];
}

- (NSString*)configDir
{
    return [[self documentsDirectory] stringByAppendingPathComponent:@"config"];
}

- (BOOL)isSessionActive
{
	return [self isStartingTransferAllowed];
}

- (BOOL)isStartingTransferAllowed
{
    NetworkStatus network = [_reachability currentReachabilityStatus];
    
    if (network == ReachableViaWiFi && !SETTINGS_USE_WIFI) return NO;
    
    if (network == ReachableViaWWAN && !SETTINGS_USE_NETWORK) return NO;
    
    if (network == NotReachable) return NO;
    
	return YES;
}

- (CGFloat)globalDownloadSpeed
{
    return fGlobalSpeedCached[0];
}

- (void)updateGlobalSpeed
{
    [fTorrents makeObjectsPerformSelector: @selector(update)];

    CGFloat dlRate = 0.0, ulRate = 0.0;
    for (Torrent * torrent in fTorrents)
    {
        dlRate += [torrent downloadRate];
        ulRate += [torrent uploadRate];
    }
    
    fGlobalSpeedCached[0] = dlRate;
    fGlobalSpeedCached[1] = ulRate;
}

- (CGFloat)globalUploadSpeed
{
    return fGlobalSpeedCached[1];
}

- (void)fixDocumentsDirectory
{
    BOOL isDir, exists;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    NSArray *directories = [NSArray arrayWithObjects:[self documentsDirectory], [self configDir], [self torrentsPath], [self defaultDownloadDir], nil];
    
    for (NSString *d in directories) {
        exists = [fileManager fileExistsAtPath:d isDirectory:&isDir];
        if (exists && !isDir) {
            [fileManager removeItemAtPath:d error:nil];
            [fileManager createDirectoryAtPath:d withIntermediateDirectories:YES attributes:nil error:nil];
            continue;
        }
        if (!exists) {
            [fileManager createDirectoryAtPath:d withIntermediateDirectories:YES attributes:nil error:nil];
            continue;
        }
    }
    [fileManager release];
}

- (NSString*)randomTorrentPath
{
    return [[self torrentsPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%f.torrent", [[NSDate date] timeIntervalSince1970]]];
}

- (NSUInteger)torrentsCount
{
    return [fTorrents count];
}

- (Torrent*)torrentAtIndex:(NSInteger)index
{
    return [fTorrents objectAtIndex:index];
}

- (void)torrentFetcher:(TorrentFetcher *)fetcher fetchedTorrentContent:(NSData *)data fromURL:(NSString *)url
{
    NSError *error = nil;
    [self decreaseActivityCounter];
    NSString *path = [self randomTorrentPath];
    [data writeToFile:path options:0 error:&error];
    error = [self openFile:path addType:ADD_URL forcePath:nil];
    if (error) {
        [[[[UIAlertView alloc] initWithTitle:@"Add from URL" message:[NSString stringWithFormat:@"Adding from %@ failed. %@", url, [error localizedDescription]]  delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] autorelease] show];
    }
    [fActivities removeObject:fetcher];
}

- (void)torrentFetcher:(TorrentFetcher *)fetcher failedToFetchFromURL:(NSString *)url withError:(NSError *)error
{
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Add torrent" message:[NSString stringWithFormat:@"Failed to fetch torrent URL: \"%@\". \nError: %@", url, [error localizedDescription]] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] autorelease];
    [alertView show];
    [fActivities removeObject:fetcher];    
    [self decreaseActivityCounter];
}

- (void)removeTorrents:(NSArray*)torrents trashData:(BOOL)trashData
{
	for (Torrent *torrent in torrents) {
		[torrent stopTransfer];
		[torrent closeRemoveTorrent:trashData];
		[fTorrents removeObject:torrent];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:NotificationTorrentsRemoved object:self userInfo:nil];
}

- (void)removeTorrents:(NSArray *)torrents trashData:(BOOL)trashData afterDelay:(NSTimeInterval)delay
{
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    [options setObject:torrents forKey:@"torrents"];
    [options setObject:[NSNumber numberWithBool:trashData] forKey:@"trashData"];
    [self performSelector:@selector(_removeTorrentsDelayed:) withObject:options afterDelay:delay];
}

- (void)_removeTorrentsDelayed:(NSDictionary*)options
{
    BOOL trashData = [[options objectForKey:@"trashData"] boolValue];
    NSArray *torrents = [options objectForKey:@"torrents"];
    [self removeTorrents:torrents trashData:trashData];
}

- (void)addTorrentFromURL:(NSString*)url
{
    TorrentFetcher *fetcher = [[[TorrentFetcher alloc] initWithURLString:url delegate:self] autorelease];
    [fActivities addObject:fetcher];
    [self increaseActivityCounter];
}

- (void)firstRunMessage
{

}

- (NSError*)addTorrentFromManget:(NSString *)magnet
{
    NSError *err = nil;
    
    tr_torrent * duplicateTorrent;
    if ((duplicateTorrent = tr_torrentFindFromMagnetLink(fLib, [magnet UTF8String])))
    {
        const tr_info * info = tr_torrentInfo(duplicateTorrent);
        NSString * name = (info != NULL && info->name != NULL) ? [NSString stringWithUTF8String: info->name] : nil;
        err = [[[NSError alloc] initWithDomain:@"Controller" code:1 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Torrent %@ already exists. ", name] forKey:NSLocalizedDescriptionKey]] autorelease];
        return err;
    }
    
    //determine download location
    NSString * location = nil;
    if ([fDefaults boolForKey: @"DownloadLocationConstant"])
        location = [[fDefaults stringForKey: @"DownloadFolder"] stringByExpandingTildeInPath];
    Torrent * torrent;
    if (!(torrent = [[Torrent alloc] initWithMagnetAddress: magnet location: location lib: fLib]))
    {

        return err;
    }
    
    [torrent setWaitToStart: [fDefaults boolForKey: @"AutoStartDownload"]];
    [torrent update];
    [fTorrents addObject:torrent];
    [torrent release]; 
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNewTorrentAdded object:self userInfo:nil];
    [self updateTorrentHistory];
    return nil;
}

- (NSError*)openFile:(NSString*)file addType:(AddType)type forcePath:(NSString *)path
{
    NSError *error = nil;
    tr_ctor * ctor = tr_ctorNew(fLib);
    tr_ctorSetMetainfoFromFile(ctor, [file UTF8String]);
    
    tr_info info;
    const tr_parse_result result = tr_torrentParse(ctor, &info);
    tr_ctorFree(ctor);
    
    if (result != TR_PARSE_OK)
    {
        if (result == TR_PARSE_DUPLICATE) {
            error = [[[NSError alloc] initWithDomain:@"Controller" code:1 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Torrent %s already exists. ", info.name] forKey:NSLocalizedDescriptionKey]] autorelease];
        }
        else if (result == TR_PARSE_ERR)
        {
            error = [[[NSError alloc] initWithDomain:@"Controller" code:1 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Invalid torrent file. "] forKey:NSLocalizedDescriptionKey]] autorelease];
        }
        tr_metainfoFree(&info);
        return error;
    }
    
    
    Torrent * torrent;
    if (!(torrent = [[Torrent alloc] initWithPath:file location: [path stringByExpandingTildeInPath] deleteTorrentFile: NO lib: fLib])) {
        error = [[[NSError alloc] initWithDomain:@"Controller" code:1 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Unknown error. "] forKey:NSLocalizedDescriptionKey]] autorelease];
        return error;
    }
    
    if (type == ADD_CREATED)
        [torrent resetCache];
    
    [torrent setWaitToStart: [fDefaults boolForKey: @"AutoStartDownload"]];
    [torrent update];
    [fTorrents addObject: torrent];
    [torrent release];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNewTorrentAdded object:self userInfo:nil];
    [self updateTorrentHistory];
    return nil;
}

- (void)increaseActivityCounter
{
    activityCounter += 1;
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationActivityCounterChanged object:self userInfo:nil];
}

- (void)decreaseActivityCounter
{
    if (activityCounter == 0) return;
    activityCounter -= 1;
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationActivityCounterChanged object:self userInfo:nil];
}

- (void) rpcCallback: (tr_rpc_callback_type) type forTorrentStruct: (struct tr_torrent *) torrentStruct
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    Torrent * torrent = nil;
    if (torrentStruct != NULL && (type != TR_RPC_TORRENT_ADDED && type != TR_RPC_SESSION_CHANGED))
    {
        for (torrent in fTorrents)
            if (torrentStruct == [torrent torrentStruct])
            {
                [torrent retain];
                break;
            }
        
        if (!torrent)
        {
            [pool drain];
            
            NSLog(@"No torrent found matching the given torrent struct from the RPC callback!");
            return;
        }
    }
    
    switch (type)
    {
        case TR_RPC_TORRENT_ADDED:
            [self performSelectorOnMainThread: @selector(rpcAddTorrentStruct:) withObject:
			 [[NSValue valueWithPointer: torrentStruct] retain] waitUntilDone: NO];
            break;
			
        case TR_RPC_TORRENT_STARTED:
        case TR_RPC_TORRENT_STOPPED:
            [self performSelectorOnMainThread: @selector(rpcStartedStoppedTorrent:) withObject: torrent waitUntilDone: NO];
            break;
			
        case TR_RPC_TORRENT_REMOVING:
            [self performSelectorOnMainThread: @selector(rpcRemoveTorrent:) withObject: torrent waitUntilDone: NO];
            break;
			
        case TR_RPC_TORRENT_CHANGED:
            [self performSelectorOnMainThread: @selector(rpcChangedTorrent:) withObject: torrent waitUntilDone: NO];
            break;
			
        case TR_RPC_TORRENT_MOVED:
            [self performSelectorOnMainThread: @selector(rpcMovedTorrent:) withObject: torrent waitUntilDone: NO];
            break;
			
        case TR_RPC_SESSION_CHANGED:
            //TODO: Post notification to update preferences. 
            break;
			
        default:
            NSAssert1(NO, @"Unknown RPC command received: %d", type);
            [torrent release];
    }
    
    [pool drain];
}

- (void) rpcAddTorrentStruct: (NSValue *) torrentStructPtr
{
    tr_torrent * torrentStruct = (tr_torrent *)[torrentStructPtr pointerValue];
    [torrentStructPtr release];
    
    NSString * location = nil;
    if (tr_torrentGetDownloadDir(torrentStruct) != NULL)
        location = [NSString stringWithUTF8String: tr_torrentGetDownloadDir(torrentStruct)];
    
    Torrent * torrent = [[Torrent alloc] initWithTorrentStruct: torrentStruct location: location lib: fLib];
    
    [torrent update];
    [fTorrents addObject: torrent];
    [torrent release];
}

- (void) rpcRemoveTorrent: (Torrent *) torrent
{
    [self removeTorrents:[NSArray arrayWithObject: torrent] trashData:NO];
    [torrent release];
}

- (void) rpcStartedStoppedTorrent: (Torrent *) torrent
{
    [torrent update];
    [torrent release];
    
	//TODO: Post notification to update this torrent's info in UI. 
	
    [self updateTorrentHistory];
}

- (void) rpcChangedTorrent: (Torrent *) torrent
{
    [torrent update];
    
	//TODO: Post notification to update this torrent's info in UI. 
	
    [torrent release];
}

- (void) rpcMovedTorrent: (Torrent *) torrent
{
    [torrent update];
    
    [torrent release];
}


- (void)setGlobalUploadSpeedLimit:(NSInteger)kbytes
{
    [fDefaults setInteger:kbytes forKey:@"UploadLimit"];
    [fDefaults synchronize];
    tr_sessionSetSpeedLimit_KBps(fLib, TR_UP, [fDefaults integerForKey:@"UploadLimit"]);
    NSLog(@"tr_sessionIsSpeedLimited(TR_UP): %d", tr_sessionIsSpeedLimited(fLib, TR_UP));
}

- (void)setGlobalDownloadSpeedLimit:(NSInteger)kbytes
{
    [fDefaults setInteger:kbytes forKey:@"DownloadLimit"];
    [fDefaults synchronize];
    tr_sessionSetSpeedLimit_KBps(fLib, TR_DOWN, [fDefaults integerForKey:@"DownloadLimit"]);
    NSLog(@"tr_sessionIsSpeedLimited(TR_DOWN): %d", tr_sessionIsSpeedLimited(fLib, TR_DOWN));
}

- (void)setGlobalUploadSpeedLimitEnabled:(BOOL)enabled
{
    [fDefaults setBool:enabled forKey:@"UploadLimitEnabled"];
    [fDefaults synchronize];
    tr_sessionLimitSpeed(fLib, TR_UP, [fDefaults boolForKey:@"UploadLimitEnabled"]);
}

- (void)setGlobalDownloadSpeedLimitEnabled:(BOOL)enabled
{
    [fDefaults setBool:enabled forKey:@"DownloadLimitEnabled"];
    [fDefaults synchronize];
    tr_sessionLimitSpeed(fLib, TR_DOWN, [fDefaults boolForKey:@"DownloadLimitEnabled"]);
}

- (NSInteger)globalDownloadSpeedLimit
{
    return tr_sessionGetSpeedLimit_KBps(fLib, TR_DOWN);
}

- (NSInteger)globalUploadSpeedLimit
{
    return tr_sessionGetSpeedLimit_KBps(fLib, TR_UP);
}

- (void)setGlobalMaximumConnections:(NSInteger)c
{
    [fDefaults setInteger:c forKey:@"PeersTotal"];
    [fDefaults synchronize];
    tr_sessionSetPeerLimit(fLib, c);
}

- (NSInteger)globalMaximumConnections
{
    return tr_sessionGetPeerLimit(fLib);
}

- (void)setConnectionsPerTorrent:(NSInteger)c
{
    [fDefaults setInteger:c forKey:@"PeersTorrent"];
    [fDefaults synchronize];
    tr_sessionSetPeerLimitPerTorrent(fLib, c);
}

- (NSInteger)connectionsPerTorrent
{
    return tr_sessionGetPeerLimitPerTorrent(fLib);
}

- (BOOL)globalUploadSpeedLimitEnabled
{
    return tr_sessionIsSpeedLimited(fLib, TR_UP);
}

- (BOOL)globalDownloadSpeedLimitEnabled
{
    return tr_sessionIsSpeedLimited(fLib, TR_DOWN);
}

- (void)torrentFinished:(NSNotification*)notif {
}

@end