//
//  User.h
//  UpBrink
//
//  Created by Sahil.Khanna on 29/05/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import "ResponseBase.h"

@interface User : ResponseBase

@property (nonatomic, strong) NSString *msisdn, *email, *password;

@end