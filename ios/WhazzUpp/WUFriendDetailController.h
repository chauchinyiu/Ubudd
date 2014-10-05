//
//  WUFriendDetailController.h
//  WhazzUpp
//
//  Created by Michael Knecht on 03.06.13.
//  Copyright (c) 2013 C2Call GmbH. All rights reserved.
//

#import <SocialCommunication/SocialCommunication.h>
#import <SocialCommunication/UDUserInfoCell.h>

@interface WUUserInfoCell : UDUserInfoCell
@property(nonatomic, weak) IBOutlet UILabel *lblGender, *lblDateOfBirth, *lblInterest, *lblSubinterest, *lblTelNo;
@end

@interface WUFriendDetailController : SCFriendDetailController
    -(IBAction)phoneCall:(id)sender;

@end