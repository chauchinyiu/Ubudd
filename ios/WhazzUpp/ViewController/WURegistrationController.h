//
//  WURegistrationController1.h
//  WhazzUpp
//
//  Created by Sahil.Khanna on 30/05/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import <SocialCommunication/SocialCommunication.h>

@interface WURegistrationController : SCRegistrationController {
    IBOutlet UILabel *lblCountryCode;
    IBOutlet UIImageView *countryBG;
}

- (IBAction)btnDoneTapped;

@end
