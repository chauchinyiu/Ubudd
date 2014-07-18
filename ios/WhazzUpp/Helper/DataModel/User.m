//
//  User.m
//  WhazzUpp
//
//  Created by Sahil.Khanna on 29/05/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import "User.h"

@implementation User

- (void)unwrapMessage:(NSDictionary *)message {
    self.errorCode = [[message objectForKey:@"error"] intValue];
    self.message = [message objectForKey:@"message"];
    
    NSDictionary *data = [message objectForKey:@"data"];
    self.msisdn = [data objectForKey:@"msisdn"];
    self.email = [data objectForKey:@"email"];
    self.password = [data objectForKey:@"password"];
}

@end