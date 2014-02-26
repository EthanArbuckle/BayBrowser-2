//
//  EANetworkSpeesOverlay.m
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 2/25/14.
//  Copyright (c) 2014 Ethan Arbuckle. All rights reserved.
//

#import "EANetworkSpeedOverlay.h"

@implementation EANetworkSpeedOverlay

- (id)initAsPad:(BOOL)isPad {
	self = [super init];

	if (self) {
		//set frame, depending on device
		if (isPad) {
			
			//draw frame
			[self setFrame:CGRectMake(0, 44 + [[UIApplication sharedApplication] statusBarFrame].size.height, 200, 50)];
			[self setCenter:CGPointMake(200, 200)];
			
			//draw labels
			_upLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, 200, 30)];
			_downLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 200, 30)];
			
		}
		else {
			
			//draw frame
			[self setFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - 140, 22, 140, 40)];
			
			//draw labels
			_upLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, 140, 20)];
			_downLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 140, 20)];
		}

		//draggable view
		UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
		[self addGestureRecognizer:pan];
		
		//border + curve
		[[self layer] setMasksToBounds:NO];
		[[self layer] setBorderWidth:1];
		[[self layer] setCornerRadius:5];

		[self setBackgroundColor:[[EAThemeManager sharedManager] colorForNavigationBarBackground]];

		//add notification listeners
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeNetworkOverlay) name:@"RemoveNetworkOverlay" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNetworkOverlay) name:@"AddNetworkOverlay" object:nil];

		//create labels
		[[Delegate torrentController] updateGlobalSpeed];
		
		[_upLabel setTextColor:[UIColor whiteColor]];
		[_upLabel setTextAlignment:NSTextAlignmentCenter];
		[_upLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13]];
		[_upLabel setText:[NSString stringWithFormat:@"Up: %@", [NSString stringForSpeed:[[Delegate torrentController] globalUploadSpeed]]]];
		[self addSubview:_upLabel];

		[_downLabel setTextColor:[UIColor whiteColor]];
		[_downLabel setTextAlignment:NSTextAlignmentCenter];
		[_downLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13]];
		[_downLabel setText:[NSString stringWithFormat:@"Down: %@", [NSString stringForSpeed:[[Delegate torrentController] globalDownloadSpeed]]]];
		[self addSubview:_downLabel];

		//create label speed update timer
		[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(update) userInfo:Nil repeats:YES];
	}
	return self;
}

- (void)update {
	//update speeds
	[[Delegate torrentController] updateGlobalSpeed];

	//update labels
	[_upLabel setText:[NSString stringWithFormat:@"Up: %@", [NSString stringForSpeed:[[Delegate torrentController] globalUploadSpeed]]]];
	[_downLabel setText:[NSString stringWithFormat:@"Down: %@", [NSString stringForSpeed:[[Delegate torrentController] globalDownloadSpeed]]]];
}

- (void)removeNetworkOverlay {
	//animate this view out
	[UIView animateWithDuration:.2 animations: ^{
	    [self setAlpha:0];
	}];
}

- (void)addNetworkOverlay {
	//animate this view in
	[UIView animateWithDuration:.2 animations: ^{
	    [self setAlpha:1];
	}];
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
	
	//touches began, lower its alpha and make it smaller
	if ([pan state] == UIGestureRecognizerStateBegan) {
		[self setTransform:CGAffineTransformMakeScale(.95, .95)];
		[self setAlpha:.9];
	}
	
	//touches ended, restore its size and alpha
	if ([pan state] == UIGestureRecognizerStateEnded) {
		[self setTransform:CGAffineTransformMakeScale(1, 1)];
		[self setAlpha:1];
	}
	
	//finger moved, move view with it
	if ([pan state] == UIGestureRecognizerStateChanged) {
		
		CGPoint center = [self center];
		CGPoint translation = [pan translationInView:self];
		center = CGPointMake(center.x + translation.x, center.y + translation.y);
		
		if (center.y > 30 && center.y < 465 && center.x > 65 && center.x < 260)
			[self setCenter:center];
		
		[pan setTranslation:CGPointZero inView:self];
	}
}

@end
