//
//  VerifyUserDTO.h
//  WriteMe
//
//  Created by Rahul Sharma on 30/07/14.
//  Copyright (c) 2014 3Embed Technologies. All rights reserved.
//

#import "RequestBase.h"

@interface VerifyUserDTO : RequestBase
@property(nonatomic,strong)NSString *msisdn,*number;
@end
