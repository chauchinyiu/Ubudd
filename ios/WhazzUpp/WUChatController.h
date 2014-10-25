//
//  WUChatController.h
//  WhazzUpp
//
//  Created by Michael Knecht on 02.06.13.
//  Copyright (c) 2013 C2Call GmbH. All rights reserved.
//

#import <SocialCommunication/SocialCommunication.h>

@interface WUChatController : SCChatController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>

- (IBAction)openProfile:(id)sender;
- (IBAction)btnCallTapped;
- (IBAction)btnRichMessageTapped:(id)sender;

@property (nonatomic, assign) bool sendWelcomeText;
@property(nonatomic, weak) IBOutlet UIButton* titleButton;

@end
