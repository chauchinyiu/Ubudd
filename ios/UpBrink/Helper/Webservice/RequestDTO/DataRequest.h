//
//  DataRequest.h
//  UpBrink
//
//  Created by Ming Kei Wong on 29/8/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "RequestBase.h"

@interface DataRequest : RequestBase
@property(nonatomic,strong)NSString *requestName;
@property(nonatomic,strong)NSDictionary *values;

@end
