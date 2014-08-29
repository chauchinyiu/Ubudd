//
//  DataResponse.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 29/8/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "DataResponse.h"

@implementation DataResponse

- (void)unwrapMessage:(NSDictionary *)message {
    self.errorCode = [[message objectForKey:@"error"] intValue];
    self.message = [message objectForKey:@"message"];
    
    self.data = [message objectForKey:@"data"];
}
@end
