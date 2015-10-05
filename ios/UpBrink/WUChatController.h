//
//  WUChatController.h
//  UpBrink
//
//  Created by Michael Knecht on 02.06.13.
//  Copyright (c) 2013 C2Call GmbH. All rights reserved.
//

#import <SocialCommunication/SocialCommunication.h>
#import <SocialCommunication/SCAudioPlayerController.h>
#import "SCChatViewController2.h"

@interface WUChatController : SCChatViewController2 <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UITextViewDelegate>

- (IBAction)openProfile:(id)sender;
- (IBAction)btnRichMessageTapped:(id)sender;
- (IBAction)btnImageTapped:(id)sender;
- (IBAction)btnSendTapped:(id)sender;
- (IBAction)recordBtnPress:(id)sender;
- (IBAction)recordBtnUnpress:(id)sender;

@property (nonatomic, assign) bool sendWelcomeText;
@property(nonatomic, weak) IBOutlet UIButton* titleButton;
@property(nonatomic, weak) IBOutlet UIButton* imageBtn;
@property(nonatomic, weak) IBOutlet UIButton* recordButton;
@property(nonatomic, weak) IBOutlet UILabel* lblRecording;
@property(nonatomic, weak) IBOutlet UIView *broadContainer;
@property(nonatomic, weak) IBOutlet UIButton* attachButton;


@end
