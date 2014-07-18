//
//  RequestBuilder.m
//  WhazzUpp
//
//  Created by Sahil.Khanna on 29/05/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import "RequestBuilder.h"
#import "DTOHeaders.h"

@implementation RequestBuilder

+ (NSURL *)serviceURL:(NSString *)method {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [ServiceURL url], method]];
}

+ (NSMutableURLRequest *)registerUser:(RequestBase *)parameter {
    return [NSMutableURLRequest requestWithURL:[self serviceURL:@"register"]];
}

+ (NSMutableURLRequest *)requestForMethod:(ServiceMethod)method parameter:(RequestBase *)parameter {
    NSMutableURLRequest *request = nil;
    
    switch (method) {
        case METHOD__REGISTER:
            request = [self registerUser:parameter];
            break;
        case METHOD__PURCHASE:
            //soapMessage = [self purchase:parameter];
            break;
        default:
            break;
    }
    
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameter.dictionaryRepresentation options:kNilOptions error:nil]];
    
    return request;
}

@end