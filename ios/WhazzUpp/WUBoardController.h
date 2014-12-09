//
//  WUBoardController.h
//  WhazzUpp
//
//  Created by Ming Kei Wong on 30/8/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import <SocialCommunication/SocialCommunication.h>

@class MOC2CallUser, MessageCell, MOC2CallEvent, C2TapImageView;


@interface WUCreateGroupCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UILabel *nameLabel;

@end


@interface WUBoardController : SCBoardController

+(void)setIsGroup:(BOOL)b;

@end
