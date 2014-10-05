//
//  WUUbuddListController.h
//  WhazzUpp
//
//  Created by Ming Kei Wong on 27/9/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import <SocialCommunication/SocialCommunication.h>

@interface WUUbuddListCell : UITableViewCell
@property(nonatomic, weak) IBOutlet UILabel     *nameLabel, *statusLabel, *onlineLabel;
@property (nonatomic, weak) IBOutlet UIImageView *userImg;
@property (nonatomic, weak) IBOutlet UIButton *userBtn;

@end

@interface WUUbuddListController : UITableViewController
-(IBAction)toggleEditing:(id)sender;
-(IBAction)showFriendInfo:(id)sender;

@end
