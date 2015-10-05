//
//  UpdateAPNSTokenDTO.h
//  UpBrink
//
//  Created by Ming Kei Wong on 12/8/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "RequestBase.h"

@interface UpdateAPNSTokenDTO : RequestBase
@property(nonatomic,strong)NSString *msisdn;
@property(nonatomic,strong)NSData *token;
@end
