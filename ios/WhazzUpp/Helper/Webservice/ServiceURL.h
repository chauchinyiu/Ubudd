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
    METHOD__PURCHASE,
    METHOD__DOCUMENT_LIST,
    METHOD__FORGOT_PASSWORD,
    METHOD__LOGIN,
    METHOD__UPLOAD_PDF,
    METHOD__SIGNATURE_COUNT,
    METHOD__GET_PDF,
    METHOD__DELETE_FILE,
    METHOD_VERIFICATIONCODE,
} typedef ServiceMethod;

@interface ServiceURL : NSObject

+ (NSString *)url;

@end