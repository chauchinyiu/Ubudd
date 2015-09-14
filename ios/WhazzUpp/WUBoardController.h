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

#import "WUNewChatViewController.h"

@class MOC2CallUser, MessageCell, MOC2CallEvent, C2TapImageView;



@interface WUMessageTimeCell : UITableViewCell
@property(nonatomic, weak) IBOutlet UILabel *timeLabel;
@property(nonatomic, weak) IBOutlet UIView *bgView;
@end

@interface WUMemberJoinCell : UITableViewCell
@property(nonatomic, weak) IBOutlet UILabel *timeLabel;
@property(nonatomic, weak) IBOutlet UIView *bgView;
@end


@interface WUCreateGroupCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UILabel *nameLabel;
@property(nonatomic, weak) IBOutlet UILabel *timeLabel;
@property(nonatomic, weak) IBOutlet UIView *createGroupView;
@property(nonatomic, weak) IBOutlet UIView *showPreviousMsgView;
@property(nonatomic, weak) IBOutlet UIView *nameBGView;
@property(nonatomic, weak) IBOutlet UIView *timeBGView;


@end


@interface WUMessageInCell : MessageCellInStream
@property(nonatomic, weak) IBOutlet UILabel *textLabel;
@end

@interface WUMessageOutCell : MessageCellOutStream
@property(nonatomic, weak) IBOutlet UILabel *textLabel;
@end


@interface WUImageInCell : ImageCellInStream
@property(nonatomic, weak) IBOutlet UIImageView *eventImage;
@end


@interface WUImageOutCell : ImageCellOutStream
@property(nonatomic, weak) IBOutlet UIImageView *eventImage;
@end

@interface WULocationInCell : LocationCellInStream
@end

@interface WUAudioInCell : AudioCellInStream
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
@end

@interface WUFriendInCell : FriendCellInStream
@end

@interface WUContactInCell : ContactCellInStream
@end

@interface WUCallInCell : CallCellInStream
@end

@interface WULocationOutCell : LocationCellOutStream
@end

@interface WUAudioOutCell : AudioCellOutStream
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
@end

@interface WUFriendOutCell : FriendCellOutStream
@end

@interface WUContactOutCell : ContactCellOutStream
@end

@interface WUCallOutCell : CallCellOutStream
@end


@interface WUBoardController : SCBoardController<WUReadBroadcastDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, WUTargetSelectControllerDelegate>

+(void)setIsGroup:(BOOL)b;
- (void)keywordShown:(NSNotification *)notification;

@property NSString* chatTitle;
@end
