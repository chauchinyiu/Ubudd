//
//  WULoginController.m
//  UpBrink
//
//  Created by Sahil.Khanna on 18/05/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import "WULoginController.h"
#import "CommonMethods.h"

@implementation WULoginController

#pragma mark - Webservice Response

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:txtEmail]) {
        [txtPassword becomeFirstResponder];
        return NO;
    }
    else {
        [txtPassword resignFirstResponder];
        [super loginUser:self];
        return YES;
    }
}

@end