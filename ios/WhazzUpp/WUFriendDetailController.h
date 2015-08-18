//
//  WUFriendDetailController.h
//  WhazzUpp
//
//  Created by Michael Knecht on 03.06.13.
//  Copyright (c) 2013 C2Call GmbH. All rights reserved.
//

#import <SocialCommunication/SocialCommunication.h>
#import <SocialCommunication/UDUserInfoCell.h>

@interface WUUserInfoCell : UITableViewCell
@property(nonatomic, weak) IBOutlet UILabel *lblName, *lblTelNo, *lblStatus;
@property(nonatomic, weak) IBOutlet C2TapImageView* userImage;
@property(nonatomic, weak) IBOutlet UIButton *btnSendMessage, *btnViewMedia, *btnClearChat;
@end

@interface WUFriendDetailController : SCFriendDetailController
-(IBAction)phoneCall:(id)sender;
+(void)setPhoneNo:(NSString*)p;
+(void)setC2CallID:(NSString*)p;
@end