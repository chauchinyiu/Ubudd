//
//  AddChatGroupDTO.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 14/9/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "AddChatGroupDTO.h"

@implementation AddChatGroupDTO
@synthesize topicDescription, groupAdmin, interestID, interestDescription, c2CallID, location, latCoord, longCoord, topic, members, isPublic;

-(id)init{
    members = [[NSMutableArray alloc] init];
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:@"" forKey:@"topicDescription"];
    [dictionary setObject:groupAdmin forKey:@"groupAdmin"];
    [dictionary setObject:interestID forKey:@"interestID"];
    [dictionary setObject:interestDescription forKey:@"interestDescription"];
    [dictionary setObject:c2CallID forKey:@"c2CallID"];
    [dictionary setObject:location forKey:@"location"];
    [dictionary setObject:[NSNumber numberWithFloat:latCoord] forKey:@"latCoord"];
    [dictionary setObject:[NSNumber numberWithFloat:longCoord] forKey:@"longCoord"];
    [dictionary setObject:topic forKey:@"topic"];
    [dictionary setObject:[NSNumber numberWithBool:isPublic] forKey:@"isPublic"];
    
    [dictionary setObject:[NSNumber numberWithInteger:members.count] forKey:@"memberCnt"];
    for (int i = 0; i < members.count; i++) {
        [dictionary setObject:[members objectAtIndex:i] forKey:[NSString stringWithFormat:@"memberID%d", i + 1]];
    }
    
    return dictionary;
}

@end
