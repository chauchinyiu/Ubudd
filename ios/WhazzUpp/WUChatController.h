//
//  WUChatController.h
//  WhazzUpp
//
//  Created by Michael Knecht on 02.06.13.
//  Copyright (c) 2013 C2Call GmbH. All rights reserved.
//

#import <SocialCommunication/SocialCommunication.h>
#import <SocialCommunication/SCAudioPlayerController.h>

@interface WUChatController : SCChatController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UITextViewDelegate>

- (IBAction)openProfile:(id)sender;
- (IBAction)btnCallTapped;
- (IBAction)btnRichMessageTapped:(id)sender;
- (IBAction)btnImageTapped:(id)sender;
- (IBAction)btnSendTapped:(id)sender;
- (IBAction)recordBtnPress:(id)sender;
- (IBAction)recordBtnUnpress:(id)sender;

@property (nonatomic, assign) bool sendWelcomeText;
@property(nonatomic, weak) IBOutlet UIButton* titleButton;
@property(nonatomic, weak) IBOutlet UIButton* imageBtn;
@property(nonatomic, weak) SCAudioRecorderController *audioView;
@property(nonatomic, weak) IBOutlet UIView *audioContainer;
@property(nonatomic, weak) IBOutlet UIButton* recordButton;
@property(nonatomic, weak) IBOutlet UILabel* lblRecording;

@end
