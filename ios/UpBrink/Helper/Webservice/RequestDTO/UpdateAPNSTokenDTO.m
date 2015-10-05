//
//  UpdateAPNSTokenDTO.m
//  UpBrink
//
//  Created by Ming Kei Wong on 12/8/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "UpdateAPNSTokenDTO.h"

@implementation UpdateAPNSTokenDTO
@synthesize msisdn,token;
- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:self.msisdn forKey:@"msisdn"];
    
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:64];
    const unsigned char *dataBuffer = (const unsigned char *)(self.token.bytes);
    for (int i = 0; i < 32; ++i)
    {
        [hexString appendFormat:@"%02x", (unsigned int)dataBuffer[i]];
    }
    [dictionary setObject:hexString forKey:@"token"];
    
    return dictionary;
}
@end
