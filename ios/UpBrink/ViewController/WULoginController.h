//
//  WULoginController.h
//  UpBrink
//
//  Created by Sahil.Khanna on 18/05/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import <SocialCommunication/SocialCommunication.h>

@interface WULoginController : SCLoginController {
    IBOutlet UITextField *txtMobile;
    IBOutlet UITextField *txtEmail, *txtPassword;
}

@end