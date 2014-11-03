//
//  WUMediaViewController.h
//  WhazzUpp
//
//  Created by Ming Kei Wong on 3/11/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import <SocialCommunication/SocialCommunication.h>

@interface WUMediaViewController : SCDataTableViewController

@property (nonatomic, strong) NSString *targetUserid;
@property(nonatomic, strong) IBOutlet UIButton              *previousMessagesButton;

@end
