//
//  CommonMethods.m
//  WhazzUpp
//
//  Created by Sahil.Khanna on 20/05/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import "CommonMethods.h"
#import <SocialCommunication/C2WaitMessage.h>

@implementation WUListEntry
@synthesize source, data, sourcePath, mapToPath;
@end

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

+ (UIFont*) getStdFontType:(int)type{
    
    UIFont* f;
    if (type == 0) {
        f = [UIFont fontWithName:@"HelveticaNeue-Bold" size:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline].pointSize * 2 - 17];
    }
    else if (type == 1) {
        f = [UIFont fontWithName:@"HelveticaNeue" size:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline].pointSize * 2 - 17];
    }
    else if (type == 2) {
        f = [UIFont fontWithName:@"HelveticaNeue" size:([UIFont preferredFontForTextStyle:UIFontTextStyleHeadline].pointSize - 1) * 2 - 17];
    }
    else if (type == 3) {
        f = [UIFont fontWithName:@"HelveticaNeue" size:([UIFont preferredFontForTextStyle:UIFontTextStyleHeadline].pointSize - 2) * 2 - 17];
    }
    else{
        
    }
    return f;
}
@end