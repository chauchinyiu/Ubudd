//
//  SCRegistrationController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 14.04.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import "SCCountrySelectionController.h"

@class EditCell, C2TapImageView;

/** Presents a Registration Controller to the user to register with the C2Call Service.
 
 */
@interface SCRegistrationController : UITableViewController<SCCountrySelectionDelegate>

/** @name Outlets */
/** The Users Email Address.
 */
@property(nonatomic, weak) IBOutlet EditCell            *email;

/** The Users Phone Number.
 */
@property(nonatomic, weak) IBOutlet EditCell            *phoneNumber;

/** The Users Password.
 */
@property(nonatomic, weak) IBOutlet EditCell            *password1;

/** The Users Password (re-enter).
 */
@property(nonatomic, weak) IBOutlet EditCell            *password2;

/** The Users Country (automatically determined).
 */
@property(nonatomic, weak) IBOutlet UITableViewCell     *country;

/** The Users Firstname.
 */
@property(nonatomic, weak) IBOutlet UITextField         *firstName;

/** The Users Lastname.
 */
@property(nonatomic, weak) IBOutlet UITextField         *lastName;

/** The Users Profile Image.
 */
@property(nonatomic, weak) IBOutlet UIButton            *imageButton;

/** @name Actions */
/** Register User Action.
 @param sender - The initiator of the action
 */
-(IBAction) registerUser:(id) sender;

/** Shows Terms Action.
 @param sender - The initiator of the action
 */
-(IBAction) showTerms:(id) sender;

/** Sets FristResponder Action.
 @param sender - The initiator of the action
 */
-(IBAction) setFirstResponder:(id)sender;

/** Selects User Profile Image Action.
 @param sender - The initiator of the action
 */
-(IBAction) selectPhoto:(id)sender;

/** @name Complete Actions */
/** Sets an Action Block to be called after registration is done.
 @param action - The Action Block
 */
-(void) setRegisterDoneAction:(void (^)())action;


@end
