//
//  WUNewChatViewController.h
//  WhazzUpp
//
//  Created by Ming Kei Wong on 2/9/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import <SocialCommunication/SocialCommunication.h>

@protocol WUTargetSelectControllerDelegate <NSObject>
@required
-(void)selectTarget:(NSString*)c2callID;
@end


@interface WUNewChatCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UILabel     *nameLabel, *statusLabel, *onlineLabel;
@property (nonatomic, weak) IBOutlet UIImageView *userImg;
@property (nonatomic, weak) IBOutlet UIButton *userBtn;
@property (nonatomic, weak) IBOutlet UIButton *infoBtn;

@end

@interface WUNewChatViewController : UITableViewController
-(IBAction)showFriendInfo:(id)sender;

-(void)switchToSelectionMode:(id<WUTargetSelectControllerDelegate>)delegate;

@end
