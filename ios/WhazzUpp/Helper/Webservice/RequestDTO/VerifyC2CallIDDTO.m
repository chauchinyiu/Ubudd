//
//  VerifyC2CallIDDTO.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 2/9/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "VerifyC2CallIDDTO.h"

@implementation VerifyC2CallIDDTO
@synthesize c2CallID;
- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:self.c2CallID forKey:@"c2CallID"];
    
    return dictionary;
}
@end
