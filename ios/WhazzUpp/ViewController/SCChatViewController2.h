//
//  SCChatController.h
//  SimplePhone
//
//  Created by Michael Knecht on 21.04.13.
//  Copyright (c) 2013 C2Call GmbH. All rights reserved.
//
#import "WUBoardController.h"
#import <UIKit/UIKit.h>

/** Presents the standard C2Call SDK Rich Media/Text Chat Controller.
 
 The ChatController is embedding the SCBoardController for the chat history and implements a chat bar to enter text messages and to submit rich media items.
 */

@class SCBoardController, SCFlexibleToolbarView;

@interface SCChatViewController2 : UIViewController

/** @name Outlets */

/** Submit Message Button. */
@property(nonatomic, weak) IBOutlet UIButton                *submitButton;

/** Toggle Message Encryption Button. */
@property(nonatomic, weak) IBOutlet UIButton                *encryptMessageButton;

/** The Chat Bar Control. */
@property(nonatomic, weak) IBOutlet SCFlexibleToolbarView   *toolbarView;

/** Toolbar Bottom Contraint
 
 For internal use only
 */
@property(nonatomic, weak) IBOutlet NSLayoutConstraint      *toolbarBottomContraint;

/** UITextView chat message. */
@property(nonatomic, weak) IBOutlet UITextView              *chatInput;

/** @name properties */
/** References to the embedded SCBoardController. */
@property(nonatomic, weak) WUBoardController                *chatboard;

/** Targets userId or phone number for the chat. */
@property(nonatomic, strong) NSString                       *targetUserid;

/** Suppress Call Events in Chat History
 
 This option is set to YES by default
 */
@property (nonatomic) BOOL dontShowCallEvents;


/** Sets the focus on the chat input to start edit when the view appears. */
@property(nonatomic) BOOL                                   startEdit;

/** Corner radius for the UITextView chat input control.
 
 This is an UIAppearance Selector
 */
@property(nonatomic) CGFloat                                chatInputCornerRadius; UI_APPEARANCE_SELECTOR;

/** Border color for the UITextView chat input control.
 
 This is an UIAppearance Selector.
 */
@property(nonatomic, strong) UIColor                        *chatInputBorderColor; UI_APPEARANCE_SELECTOR;

/** Border width for the UITextView chat input control.
 
 This is an UIAppearance Selector.
 */
@property(nonatomic) CGFloat chatInputBorderWidth; UI_APPEARANCE_SELECTOR;

/** Handles the typing event when the remote party is typing.

 
 @param fromUserid - Userid of the user who is currently typing
 
 */
-(void) handleTypingEvent:(NSString *) fromUserid;

/** Handles an SMS PriceInfo Event and update UILabel smsCosts with the costs.
 */
-(void) updateSMSPriceInfo:(NSString *) priceInfo;

/** @name Actions */
/** Select Rich Message Action.
 
 
 @param sender - The initiator of the action
 */
-(IBAction)selectRichMessage:(id)sender;

/** Shows ABPeoplePickerNavigationController Action.
 
 Submits a VCARD, select from ABPeoplePickerNavigationController.
 
 @param sender - The initiator of the action
 */
-(IBAction)showPicker:(id)sender;

/** Hides Keyboard Action.
 
 @param sender - The initiator of the action
 */
-(IBAction)hideKeyboard:(id)sender;

/** Closes ViewController Action.
 
 @param sender - The initiator of the action
 */
-(IBAction) close:(id) sender;

/** Toggle encryption for message submit
 
 If the receiver has a public key, the message can be submitted 2048 bit encrypted.
 
 @param sender - The initiator of the action
 */
-(IBAction)toggleSecureMessageButton:(id)sender;

/** Submits Message Action.
 
 @param sender - The initiator of the action
 */
-(IBAction) submit:(id) sender;

-(void) resizeToolbar:(NSString *) newtext;

@end
