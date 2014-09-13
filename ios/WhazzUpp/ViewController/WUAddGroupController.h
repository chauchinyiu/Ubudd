//
//  WUAddGroupController.h
//  WhazzUpp
//
//  Created by Sahil.Khanna on 09/06/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import <SocialCommunication/SocialCommunication.h>
#import "WUInterestViewController.h"

@interface WUAddGroupController : SCAddGroupController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, WUInterestViewControllerDelegate> {
    IBOutlet UIButton *btnGroupImage;
    
    IBOutlet UITextField *txtTopic;
    IBOutlet UITextField *txtTopic2;
    IBOutlet UIButton *btnInterest;
    IBOutlet UITextField *txtSubInterest;
    
}

@property (nonatomic, strong) id parentController;

- (IBAction)btnPhotoTapped:(id)sender;
- (IBAction)txtSubInterestDone;
- (IBAction)txtTopicDone;
- (IBAction)txtTopic2Done;

@end