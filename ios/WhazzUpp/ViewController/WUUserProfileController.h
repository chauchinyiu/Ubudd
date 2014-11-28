//
//  WUUserProfileController.h
//  WhazzUpp
//
//  Created by Sahil.Khanna on 02/06/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import <SocialCommunication/SocialCommunication.h>
#import "WUInterestViewController.h"
#import "WUStatusSelectController.h"
#import <SocialCommunication/C2TapImageView.h>

@interface WUUserProfileController : SCUserProfileController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, WUInterestViewControllerDelegate, WUStatusSelectControllerDelegate, UIGestureRecognizerDelegate > {
    IBOutlet UITextField *txtDisplayName;
    IBOutlet UIButton *btnProfileImage;
    IBOutlet C2TapImageView *userImage;
    IBOutlet UITextField *txtDateofBirth;
    IBOutlet UIButton *btnGender;
    IBOutlet UIButton *btnInterest;
    IBOutlet UITextField *txtSubInterest;
    IBOutlet UIButton *btnStatus;
    IBOutlet UILabel *lblTelNo;
}

- (IBAction)btnSaveTapped;
- (IBAction)btnProfileImageTapped;
- (void)doneClicked:(id)sender;
- (IBAction)btnGenderTapped;
- (IBAction)txtSubInterestDone;
@end