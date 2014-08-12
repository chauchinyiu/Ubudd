//
//  UpdateAPNSTokenDTO.m
//  WhazzUpp
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
    [dictionary setObject:self.token.base64Encoding forKey:@"token"];
    
    return dictionary;
}
@end
