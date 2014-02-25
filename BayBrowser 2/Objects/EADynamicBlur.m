//
//  EADynamicBlur.m
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 2/19/14.
//  Copyright (c) 2014 Ethan Arbuckle. All rights reserved.
//

#import "EADynamicBlur.h"
#import <QuartzCore/QuartzCore.h>

@interface CABackdropLayer : CALayer
@end

@interface CAFilter : NSObject

+ (instancetype)filterWithName:(NSString *)name;

@end

@interface EADynamicBlur ()

@property (weak, nonatomic) CAFilter *blurFilter;

@end

extern NSString *const kCAFilterGaussianBlur;
NSString *const EABlurViewQualityDefault = @"default";
NSString *const EABlurViewQualityLow = @"low";
static NSString *const EABlurViewQualityKey = @"inputQuality";
static NSString *const EABlurViewRadiusKey = @"inputRadius";
static NSString *const EABlurViewBoundsKey = @"inputBounds";
static NSString *const EABlurViewHardEdgesKey = @"inputHardEdges";


@implementation EADynamicBlur

+ (Class)layerClass {
	return [CABackdropLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		CAFilter *filter = [CAFilter filterWithName:kCAFilterGaussianBlur];
		self.layer.filters = @[filter];
		self.blurFilter = filter;

		self.blurQuality = EABlurViewQualityDefault;
		self.blurRadius = 5.0f;
	}
	return self;
}

- (void)setQuality:(NSString *)quality {
	[self.blurFilter setValue:quality forKey:EABlurViewQualityKey];
}

- (NSString *)quality {
	return [self.blurFilter valueForKey:EABlurViewQualityKey];
}

- (void)setBlurRadius:(CGFloat)radius {
	[self.blurFilter setValue:@(radius) forKey:EABlurViewRadiusKey];
}

- (CGFloat)blurRadius {
	return [[self.blurFilter valueForKey:EABlurViewRadiusKey] floatValue];
}

- (void)setBlurCroppingRect:(CGRect)croppingRect {
	[self.blurFilter setValue:[NSValue valueWithCGRect:croppingRect] forKey:EABlurViewBoundsKey];
}

- (CGRect)blurCroppingRect {
	NSValue *value = [self.blurFilter valueForKey:EABlurViewBoundsKey];
	return value ? [value CGRectValue] : CGRectNull;
}

- (void)setBlurEdges:(BOOL)blurEdges {
	[self.blurFilter setValue:@(!blurEdges) forKey:EABlurViewHardEdgesKey];
}

- (BOOL)blurEdges {
	return ![[self.blurFilter valueForKey:EABlurViewHardEdgesKey] boolValue];
}

@end
