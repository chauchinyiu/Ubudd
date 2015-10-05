//
//  RequestBuilder.m
//  UpBrink
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
+ (NSMutableURLRequest *)verifyUser:(RequestBase *)parameter {
    return [NSMutableURLRequest requestWithURL:[self serviceURL:@"verifyUser"]];
}
+ (NSMutableURLRequest *)updateAPNSToken:(RequestBase *)parameter {
    return [NSMutableURLRequest requestWithURL:[self serviceURL:@"updateAPNSToken"]];
}
+ (NSMutableURLRequest *)updateUserField:(RequestBase *)parameter {
    return [NSMutableURLRequest requestWithURL:[self serviceURL:@"updateUserField"]];
}
+ (NSMutableURLRequest *)updateRequestData:(RequestBase *)parameter Name:(NSString*)name{
    return [NSMutableURLRequest requestWithURL:[self serviceURL:name]];
}
+ (NSMutableURLRequest *)verifyC2CallID:(RequestBase *)parameter {
    return [NSMutableURLRequest requestWithURL:[self serviceURL:@"verifyC2CallID"]];
}
+ (NSMutableURLRequest *)addChatGroup:(RequestBase *)parameter {
    return [NSMutableURLRequest requestWithURL:[self serviceURL:@"addChatGroup"]];
}



+ (NSMutableURLRequest *)requestForMethod:(ServiceMethod)method parameter:(RequestBase *)parameter {
    NSMutableURLRequest *request = nil;
    NSDictionary *dict = [parameter dictionaryRepresentation];
    
    switch (method) {
        case METHOD__REGISTER:
            request = [self registerUser:parameter];
            break;
        case METHOD_VERIFICATIONCODE:
            request = [self verifyUser:parameter];
            break;
        case METHOD_UPDATE_APNS_TOKEN:
            request = [self updateAPNSToken:parameter];
            break;
        case METHOD_UPDATE_USER_FIELD:
            request = [self updateUserField:parameter];
            break;
        case METHOD_DATA_REQUEST:
            request = [self updateRequestData:parameter Name:[dict valueForKey:@"requestName"]];
            break;
        case METHOD_VERIFY_C2CALLID:
            request = [self verifyC2CallID:parameter];
            break;
        case METHOD_ADD_CHAT_GROUP:
            request = [self addChatGroup:parameter];
            break;
        default:
            break;
    }
    
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameter.dictionaryRepresentation options:kNilOptions error:nil]];
    
    return request;
}

@end