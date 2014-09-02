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
    METHOD_UPDATE_USER_FIELD,
    METHOD_DATA_REQUEST,
    METHOD_VERIFY_C2CALLID,
} typedef ServiceMethod;

@interface ServiceURL : NSObject

+ (NSString *)url;

@end