//
//  WebserviceHandler.m
//  UpBrink
//
//  Created by Sahil.Khanna on 29/05/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import "WebserviceHandler.h"
#import "RequestBuilder.h"
#import "ConnectionHandler.h"
#import "Reachability.h"
#import "CommonMethods.h"
#import "User.h"
#import "VerifyUser.h"
#import "UpdateAPNSToken.h"
#import "UpdateUserField.h"
#import "DataResponse.h"
#import "VerifyC2CallID.h"

@interface WebserviceHandler()

@property (nonatomic, strong) id target;
@property (nonatomic, assign) SEL action;
@property (nonatomic, assign) ServiceMethod method;

@end

@implementation WebserviceHandler

@synthesize target;
@synthesize action;
@synthesize method;

#pragma mark -
- (void)execute:(ServiceMethod)_method parameter:(id)parameter target:(id)_target action:(SEL)_action {
//    if (![CommonMethods isConnected]) {
//        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Could not connect to server. Check if device is connected to internet" forKey:NSLocalizedDescriptionKey];
//        NSError *error = [NSError errorWithDomain:@"com.3embed.signXtra" code:NSURLErrorNotConnectedToInternet userInfo:userInfo];
//        [_target performSelector:_action withObject:nil withObject:error];
//    }
//    else {
        [self setTarget:_target];
        [self setAction:_action];
        [self setMethod:_method];
        
        NSMutableURLRequest *request = [RequestBuilder requestForMethod:_method parameter:parameter];
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPMethod:@"POST"];
    
        ConnectionHandler *connectionHandler = [[ConnectionHandler alloc] initWithTarget:self action:@selector(serviceResponse:error:)];
        [NSURLConnection connectionWithRequest:request delegate:connectionHandler];
//    }
}

- (void)serviceResponse:(NSData *)responseData error:(NSError *)error {
    NSError *_error = nil;
    
    if (responseData == nil) {
        return;
    }
    
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&_error];
    
    ResponseBase *responseBase = nil;
    
    switch (method) {
        case METHOD__REGISTER:
            responseBase = [[User alloc] init];
            break;
        case METHOD_VERIFICATIONCODE:
            responseBase = [[VerifyUser alloc] init];
            break;
        case METHOD_UPDATE_APNS_TOKEN:
            responseBase = [[UpdateAPNSToken alloc] init];
            break;
        case METHOD_UPDATE_USER_FIELD:
            responseBase = [[UpdateUserField alloc] init];
            break;
        case METHOD_DATA_REQUEST:
        case METHOD_ADD_CHAT_GROUP:
            responseBase = [[DataResponse alloc] init];
            break;
        case METHOD_VERIFY_C2CALLID:
            responseBase = [[VerifyC2CallID alloc] init];
            break;
            
        default:
            break;
    }
    
    
    [responseBase unwrapMessage:response];
    
    if ([target respondsToSelector:action])
        [target performSelector:action withObject:responseBase withObject:nil];
    
    
}

@end