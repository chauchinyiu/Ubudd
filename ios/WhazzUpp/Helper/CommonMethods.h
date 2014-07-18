//
//  CommonMethods.h
//  WhazzUpp
//
//  Created by Sahil.Khanna on 20/05/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constant.h"

@interface CommonMethods : NSObject

+ (float)osVersion;

#pragma mark - Text formatting
+ (NSString *)trimText:(NSString *)text;

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate;

+ (void)showLoading:(BOOL)value title:(NSString *)title message:(NSString *)message;

@end