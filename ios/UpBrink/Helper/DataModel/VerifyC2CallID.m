//
//  VerifyC2CallID.m
//  UpBrink
//
//  Created by Ming Kei Wong on 2/9/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "VerifyC2CallID.h"

@implementation VerifyC2CallID
- (void)unwrapMessage:(NSDictionary *)message {
    self.errorCode = [[message objectForKey:@"error"] intValue];
    self.message = [message objectForKey:@"message"];
    self.c2CallID = [message objectForKey:@"c2CallID"];
    self.resultCode = [[message objectForKey:@"resultCode"] intValue];
}

@end
