//
//  ConnectionHandler.m
//  UpBrink
//
//  Created by Sahil.Khanna on 29/05/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import "ConnectionHandler.h"

@interface ConnectionHandler ()

@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) id target;
@property (nonatomic, assign) SEL action;

@end

@implementation ConnectionHandler

@synthesize responseData;
@synthesize target;
@synthesize action;

#pragma mark - Connection Delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (!responseData) {
        [self setResponseData:[NSMutableData data]];
    }
    
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if ([target respondsToSelector:action]) {
        [target performSelector:action withObject:responseData withObject:nil];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if ([target respondsToSelector:action]) {
        [target performSelector:action withObject:nil withObject:error];
    }
}

#pragma mark - ConnectionHandler Methods
- (id)initWithTarget:(id)_target action:(SEL)_action {
    self = [super init];
    
    if (self) {
        [self setTarget:_target];
        [self setAction:_action];
    }
    
    return self;
}

@end