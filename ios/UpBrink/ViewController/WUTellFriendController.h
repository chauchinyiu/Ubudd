//
//  WUTellFriendController.h
//  UpBrink
//
//  Created by Sahil.Khanna on 24/06/14.
//  Copyright (c) 2014 3Embed Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface WUTellFriendController : UITableViewController <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>
    @property(nonatomic, weak) IBOutlet UILabel *emailLabel, *smsLabel, *facebookLabel;

@end