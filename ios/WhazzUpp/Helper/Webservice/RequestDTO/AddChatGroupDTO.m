//
//  AddChatGroupDTO.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 14/9/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "AddChatGroupDTO.h"

@implementation AddChatGroupDTO

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:self.topicDescription forKey:@"topicDescription"];
    [dictionary setObject:self.groupAdmin forKey:@"groupAdmin"];
    [dictionary setObject:self.interestID forKey:@"interestID"];
    [dictionary setObject:self.interestDescription forKey:@"interestDescription"];
    [dictionary setObject:self.c2CallID forKey:@"c2CallID"];
    
    return dictionary;
}

@end
