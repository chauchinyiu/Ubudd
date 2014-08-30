//
//  UpdateUserFieldDTO.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 29/8/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "UpdateUserFieldDTO.h"

@implementation UpdateUserFieldDTO
@synthesize msisdn,field,value;
- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:self.msisdn forKey:@"msisdn"];
    [dictionary setObject:self.field forKey:@"field"];
    [dictionary setObject:self.value forKey:@"value"];
    
    return dictionary;
}
@end
