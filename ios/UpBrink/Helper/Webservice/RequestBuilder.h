//
//  RequestBuilder.h
//  UpBrink
//
//  Created by Sahil.Khanna on 29/05/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceURL.h"

@interface RequestBuilder : NSObject

+ (NSMutableURLRequest *)requestForMethod:(ServiceMethod)method parameter:(id)parameter;

@end