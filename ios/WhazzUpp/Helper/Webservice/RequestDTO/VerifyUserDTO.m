//
//  VerifyUserDTO.m
//  WriteMe
//
//  Created by Rahul Sharma on 30/07/14.
//  Copyright (c) 2014 3Embed Technologies. All rights reserved.
//

#import "VerifyUserDTO.h"

@implementation VerifyUserDTO
@synthesize msisdn,number;
- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:self.msisdn forKey:@"msisdn"];
    [dictionary setObject:self.number forKey:@"number"];
    
    return dictionary;
}
@end
