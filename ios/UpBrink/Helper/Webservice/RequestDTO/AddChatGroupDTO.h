//
//  AddChatGroupDTO.h
//  UpBrink
//
//  Created by Ming Kei Wong on 14/9/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "RequestBase.h"

@interface AddChatGroupDTO : RequestBase

@property (nonatomic, strong) NSString *topicDescription, *groupAdmin, *interestID, *interestDescription, *c2CallID, *location, *topic;
@property float latCoord, longCoord;
@property BOOL isPublic;
@property (nonatomic, strong) NSMutableArray *members;

@end
