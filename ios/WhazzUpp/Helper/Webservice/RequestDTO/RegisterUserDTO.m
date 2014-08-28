//
//  RegisterUserDTO.m
//  WhazzUpp
//
//  Created by Sahil.Khanna on 29/05/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import "RegisterUserDTO.h"

@implementation RegisterUserDTO

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:self.brand forKey:@"brand"];
    [dictionary setObject:self.model forKey:@"model"];
    [dictionary setObject:self.os forKey:@"os"];
    [dictionary setObject:self.uid forKey:@"uid"];
    [dictionary setObject:self.msisdn forKey:@"msisdn"];
    [dictionary setObject:self.countryCode forKey:@"countryCode"];
    [dictionary setObject:self.phoneNo forKey:@"phoneNo"];
    
    return dictionary;
}

@end