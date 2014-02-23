//
//  main.m
//  BayBrowser 2
//
//  Created by Ethan Arbuckle on 11/11/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EAiPhoneDelegate.h"
#import "EAiPadDelegate.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        signal(SIGPIPE, (void*)(int)SO_NOSIGPIPE); //dont break on sigpipe
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([EAiPhoneDelegate class]));
        else
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([EAiPadDelegate class]));
    }
}
