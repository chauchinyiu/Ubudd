//
//  VerifyUser.m
//  WriteMe
//
//  Created by Rahul Sharma on 30/07/14.
//  Copyright (c) 2014 3Embed Technologies. All rights reserved.
//

#import "VerifyUser.h"

@implementation VerifyUser
- (void)unwrapMessage:(NSDictionary *)message {
    self.errorCode = [[message objectForKey:@"error"] intValue];
    self.message = [message objectForKey:@"message"];
    
}

@end
