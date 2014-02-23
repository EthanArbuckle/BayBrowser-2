//
//  EADynamicBlur.h
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 2/19/14.
//  Copyright (c) 2014 Ethan Arbuckle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString * const EABlurViewQualityDefault;
extern NSString * const EABlurViewQualityLow;

NS_CLASS_AVAILABLE_IOS(7_0) @interface EADynamicBlur : UIView

@property (nonatomic, strong) NSString *blurQuality;
@property (nonatomic) CGFloat blurRadius;
@property (nonatomic) CGRect blurCroppingRect;
@property (nonatomic) BOOL blurEdges;

@end