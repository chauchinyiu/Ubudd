//
//  WUUserProfileController.h
//  UpBrink
//
//  Created by Sahil.Khanna on 02/06/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import <SocialCommunication/SocialCommunication.h>
#import "WUInterestViewController.h"
#import "WUStatusSelectController.h"
#import <SocialCommunication/C2TapImageView.h>

@interface WUUserProfileController : SCUserProfileController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, WUStatusSelectControllerDelegate, UIGestureRecognizerDelegate > {
    IBOutlet UITextField *txtDisplayName;
    IBOutlet UIButton *btnProfileImage;
    IBOutlet C2TapImageView *userImage;
    IBOutlet UIButton *btnStatus;
    IBOutlet UILabel *lblTelNo;
    IBOutlet UILabel *lblEditName;
}

- (IBAction)btnSaveTapped;
- (IBAction)btnProfileImageTapped;
@end