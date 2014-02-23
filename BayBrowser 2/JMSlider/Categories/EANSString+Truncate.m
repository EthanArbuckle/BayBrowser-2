//
//  EANSString+Truncate.m
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/12/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import "EANSString+Truncate.h"

@implementation NSString (Truncate)

+ (NSString *)truncate:(NSString *)text {
	//truncates if its greater than 999
	if ([text intValue] > 999) {
		unsigned long long value = 1700llu;
		NSUInteger index = 0;
		double dvalue = (double)[text doubleValue];
		NSArray *suffix = @[@"", @"k", @"M", @"G", @"T", @"P", @"E"];
		while ((value /= 1000) && ++index) dvalue /= 1000;
		NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
		[formatter setMaximumFractionDigits:(int)(dvalue < 100.0 && ((unsigned)((dvalue - (unsigned)dvalue) * 10) > 0))];
		return [NSMutableString stringWithFormat:@"%@", [[formatter stringFromNumber:[NSNumber numberWithFloat:dvalue]] stringByAppendingString:[suffix objectAtIndex:index]]];
	}
	else
		return text;
}

@end
