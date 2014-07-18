//
//  ServiceURL.m
//  WhazzUpp
//
//  Created by Sahil.Khanna on 29/05/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import "ServiceURL.h"

@implementation ServiceURL

#define kURL @"http://128.199.145.104/process.php"

/*
 * If multiple services are available
 */
+ (NSString *)url {
    return kURL;
}

@end