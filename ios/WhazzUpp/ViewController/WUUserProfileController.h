//
//  WUUserProfileController.h
//  WhazzUpp
//
//  Created by Sahil.Khanna on 02/06/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import <SocialCommunication/SocialCommunication.h>

@interface WUUserProfileController : SCUserProfileController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    IBOutlet UITextField *txtDisplayName;
    IBOutlet UIButton *btnProfileImage;
}

- (IBAction)btnSaveTapped;
- (IBAction)btnProfileImageTapped;

@end