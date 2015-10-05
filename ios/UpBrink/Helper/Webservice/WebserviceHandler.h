//
//  WebserviceHandler.h
//  UpBrink
//
//  Created by Sahil.Khanna on 29/05/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceURL.h"

@interface WebserviceHandler : NSObject

- (void)execute:(ServiceMethod)_method parameter:(id)parameter target:(id)_target action:(SEL)_action;

@end