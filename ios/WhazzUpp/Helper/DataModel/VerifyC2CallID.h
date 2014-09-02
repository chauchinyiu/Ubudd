//
//  VerifyC2CallID.h
//  WhazzUpp
//
//  Created by Ming Kei Wong on 2/9/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "ResponseBase.h"

@interface VerifyC2CallID : ResponseBase
@property (nonatomic, strong) NSString *c2CallID;
@property (nonatomic, assign) int resultCode;

@end
