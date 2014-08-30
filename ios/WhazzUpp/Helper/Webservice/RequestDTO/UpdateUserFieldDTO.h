//
//  UpdateUserFieldDTO.h
//  WhazzUpp
//
//  Created by Ming Kei Wong on 29/8/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "RequestBase.h"

@interface UpdateUserFieldDTO : RequestBase
@property(nonatomic,strong)NSString *msisdn;
@property(nonatomic,strong)NSString *field;
@property(nonatomic,strong)NSString *value;

@end
