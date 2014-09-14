//
//  AddChatGroupDTO.h
//  WhazzUpp
//
//  Created by Ming Kei Wong on 14/9/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "RequestBase.h"

@interface AddChatGroupDTO : RequestBase

@property (nonatomic, strong) NSString *topicDescription, *groupAdmin, *interestID, *interestDescription, *c2CallID;

@end
