//
//  RegisterUserDTO.h
//  WhazzUpp
//
//  Created by Sahil.Khanna on 29/05/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import "RequestBase.h"

@interface RegisterUserDTO : RequestBase

@property (nonatomic, strong) NSString *msisdn, *model, *uid, *os, *brand, *countryCode, *phoneNo;

@end