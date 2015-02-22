//
//  WUBoardController.h
//  WhazzUpp
//
//  Created by Ming Kei Wong on 30/8/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import <SocialCommunication/SocialCommunication.h>
#import "ResponseHandler.h"
#import <SocialCommunication/MessageCellInStream.h>
#import <SocialCommunication/ImageCellInStream.h>

#import <SocialCommunication/MessageCellOutStream.h>
#import <SocialCommunication/ImageCellOutStream.h>
#import "SocialCommunication/LocationCellOutStream.h"
#import "SocialCommunication/AudioCellOutStream.h"
#import "SocialCommunication/VideoCellOutStream.h"
#import "SocialCommunication/FriendCellOutStream.h"
#import "SocialCommunication/ContactCellOutStream.h"
#import "SocialCommunication/CallCellOutStream.h"

@class MOC2CallUser, MessageCell, MOC2CallEvent, C2TapImageView;


@interface WUCreateGroupCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UILabel *nameLabel;
@property(nonatomic, weak) IBOutlet UILabel *timeLabel;

@end


@interface WUMessageInCell : MessageCellInStream
@property(nonatomic, weak) IBOutlet UILabel *textLabel;
@property(nonatomic, weak) IBOutlet UILabel *timeLabel;
@property(nonatomic, weak) IBOutlet UIImageView *shadowImage;
@end

@interface WUMessageOutCell : MessageCellOutStream
@property(nonatomic, weak) IBOutlet UILabel *textLabel;
@property(nonatomic, weak) IBOutlet UILabel *timeLabel;
@property(nonatomic, weak) IBOutlet UIImageView *shadowImage;
@end


@interface WUImageInCell : ImageCellInStream
@property(nonatomic, weak) IBOutlet UIImageView *eventImage;
@end


@interface WUImageOutCell : ImageCellOutStream
@property(nonatomic, weak) IBOutlet UIImageView *eventImage;
@property(nonatomic, weak) IBOutlet UIImageView *shadowImage;
@end

@interface WULocationOutCell : LocationCellOutStream
@property(nonatomic, weak) IBOutlet UIImageView *shadowImage;
@end

@interface WUAudioOutCell : AudioCellOutStream
@property(nonatomic, weak) IBOutlet UIImageView *shadowImage;
@end

@interface WUVideoOutCell : VideoCellOutStream
@property(nonatomic, weak) IBOutlet UIImageView *shadowImage;
@end

@interface WUFriendOutCell : FriendCellOutStream
@property(nonatomic, weak) IBOutlet UIImageView *shadowImage;
@end

@interface WUContactOutCell : ContactCellOutStream
@property(nonatomic, weak) IBOutlet UIImageView *shadowImage;
@end

@interface WUCallOutCell : CallCellOutStream
@property(nonatomic, weak) IBOutlet UIImageView *shadowImage;
@end


@interface WUBoardController : SCBoardController<WUReadBroadcastDelegate>

+(void)setIsGroup:(BOOL)b;

@end
