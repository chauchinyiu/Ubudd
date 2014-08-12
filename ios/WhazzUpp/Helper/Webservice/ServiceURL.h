//
//  ServiceURL.h
//  WhazzUpp
//
//  Created by Sahil.Khanna on 29/05/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

enum ServiceMethod {
    METHOD__REGISTER = 1,
    METHOD_VERIFICATIONCODE,
    METHOD_UPDATE_APNS_TOKEN,
} typedef ServiceMethod;

@interface ServiceURL : NSObject

+ (NSString *)url;

@end