//
//  ResponseBase.h
//  UpBrink
//
//  Created by Sahil.Khanna on 29/05/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ResponseBaseProtocol <NSObject>

@optional
- (void)unwrapMessage:(NSDictionary *)message;

@end

@interface ResponseBase : NSObject <ResponseBaseProtocol>

@property (nonatomic, strong) NSString *message;
@property (nonatomic, assign) int errorCode;

@end