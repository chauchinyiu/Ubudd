//
//  CommonMethods.h
//  UpBrink
//
//  Created by Sahil.Khanna on 20/05/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constant.h"

@interface WUListEntry : NSObject

@property NSMutableString* source;
@property NSMutableDictionary* data;
@property NSIndexPath* sourcePath;
@property NSIndexPath* mapToPath;

@end



@interface CommonMethods : NSObject

+ (float)osVersion;

#pragma mark - Text formatting
+ (NSString *)trimText:(NSString *)text;

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate;

+ (void)showLoading:(BOOL)value title:(NSString *)title message:(NSString *)message;

+ (UIFont*) getStdFontType:(int)type;


+(void)showSinglePhoto:(UIImage*)image title:(NSString*) title onNavigationController:(UINavigationController*) nc;

+(void)showMovie:(NSString*)movie onNavigationController:(UINavigationController*) nc;

@end