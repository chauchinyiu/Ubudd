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
#import "SocialCommunication/LocationCellInStream.h"
#import "SocialCommunication/AudioCellInStream.h"
#import "SocialCommunication/VideoCellInStream.h"
#import "SocialCommunication/FriendCellInStream.h"
#import "SocialCommunication/ContactCellInStream.h"
#import "SocialCommunication/CallCellInStream.h"

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
@property(nonatomic, weak) IBOutlet UILabel *sectiontimeLabel;
@property(nonatomic, weak) IBOutlet UIView *createGroupView;
@property(nonatomic, weak) IBOutlet UIView *showPreviousMsgView;
@property(nonatomic, weak) IBOutlet UIView *sectiontimeview;

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
@property(nonatomic, weak) IBOutlet UILabel *timeLabel;
@end


@interface WUImageOutCell : ImageCellOutStream
@property(nonatomic, weak) IBOutlet UIImageView *eventImage;
@property(nonatomic, weak) IBOutlet UILabel *timeLabel;
@property(nonatomic, weak) IBOutlet UIImageView *shadowImage;
@end

@interface WULocationInCell : LocationCellInStream
@property(nonatomic, weak) IBOutlet UILabel *timeLabel;
@end

@interface WUAudioInCell : AudioCellInStream
@property(nonatomic, weak) IBOutlet UILabel *timeLabel;
@property(nonatomic, weak) IBOutlet UIButton *playButton;
@property(nonatomic, weak) IBOutlet UISlider *playSlider;
@property(nonatomic, weak) IBOutlet UIView *playView;
@property BOOL isPlaying;
@property NSTimer *timer;
@property AVAudioPlayer *player;

- (IBAction)playBtnDown:(id)sender;
- (IBAction)playBtnPress:(id)sender;
- (IBAction)playBtnUp:(id)sender;
- (IBAction)sliderMove:(id)sender;
@end

@interface WUVideoInCell : VideoCellInStream
@property(nonatomic, weak) IBOutlet UILabel *timeLabel;
@end

@interface WUFriendInCell : FriendCellInStream
@property(nonatomic, weak) IBOutlet UILabel *timeLabel;
@end

@interface WUContactInCell : ContactCellInStream
@property(nonatomic, weak) IBOutlet UILabel *timeLabel;
@end

@interface WUCallInCell : CallCellInStream
@property(nonatomic, weak) IBOutlet UILabel *timeLabel;
@end

@interface WULocationOutCell : LocationCellOutStream
@property(nonatomic, weak) IBOutlet UILabel *timeLabel;
@property(nonatomic, weak) IBOutlet UIImageView *shadowImage;
@end

@interface WUAudioOutCell : AudioCellOutStream
@property(nonatomic, weak) IBOutlet UILabel *timeLabel;
@property(nonatomic, weak) IBOutlet UIImageView *shadowImage;
@property(nonatomic, weak) IBOutlet UIButton *playButton;
@property(nonatomic, weak) IBOutlet UISlider *playSlider;
@property(nonatomic, weak) IBOutlet UIView *playView;
@property BOOL isPlaying;
@property NSTimer *timer;
@property AVAudioPlayer *player;

- (IBAction)playBtnDown:(id)sender;
- (IBAction)playBtnPress:(id)sender;
- (IBAction)playBtnUp:(id)sender;
- (IBAction)sliderMove:(id)sender;

@end

@interface WUVideoOutCell : VideoCellOutStream
@property(nonatomic, weak) IBOutlet UILabel *timeLabel;
@property(nonatomic, weak) IBOutlet UIImageView *shadowImage;
@end

@interface WUFriendOutCell : FriendCellOutStream
@property(nonatomic, weak) IBOutlet UILabel *timeLabel;
@property(nonatomic, weak) IBOutlet UIImageView *shadowImage;
@end

@interface WUContactOutCell : ContactCellOutStream
@property(nonatomic, weak) IBOutlet UILabel *timeLabel;
@property(nonatomic, weak) IBOutlet UIImageView *shadowImage;
@end

@interface WUCallOutCell : CallCellOutStream
@property(nonatomic, weak) IBOutlet UILabel *timeLabel;
@property(nonatomic, weak) IBOutlet UIImageView *shadowImage;
@end


@interface WUBoardController : SCBoardController<WUReadBroadcastDelegate>

+(void)setIsGroup:(BOOL)b;

@end
