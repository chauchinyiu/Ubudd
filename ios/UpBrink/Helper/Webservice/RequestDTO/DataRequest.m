//
//  DataRequest.m
//  UpBrink
//
//  Created by Ming Kei Wong on 29/8/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "DataRequest.h"



@implementation DataRequest

@synthesize values, requestName;

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:self.values];
    [dictionary setObject:self.requestName forKey:@"requestName"];
    return dictionary;
}
@end
