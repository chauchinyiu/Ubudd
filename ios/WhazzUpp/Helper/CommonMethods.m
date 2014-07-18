//
//  CommonMethods.m
//  WhazzUpp
//
//  Created by Sahil.Khanna on 20/05/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import "CommonMethods.h"
#import <SocialCommunication/C2WaitMessage.h>

@implementation CommonMethods

+ (float)osVersion {
    NSString *version = [[UIDevice currentDevice] systemVersion];
    return [version floatValue];
}

#pragma mark - Text formatting
+ (NSString *)trimText:(NSString *)text {
    return [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

#pragma mark -
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:title
                              message:message
                              delegate:delegate
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    [alertView show];
}

+ (void)showLoading:(BOOL)value title:(NSString *)title message:(NSString *)message {
    if (value)
        [C2WaitMessage waitMessageWithTitle:title ? title : @"" andMessage:message ? message : @""];
    else
        [C2WaitMessage hideWaitMessage];
}

@end