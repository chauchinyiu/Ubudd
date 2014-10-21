//
//  WUAddGroupController.h
//  WhazzUpp
//
//  Created by Sahil.Khanna on 09/06/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import <SocialCommunication/SocialCommunication.h>
#import "WUInterestViewController.h"
#import "WULocationSearchController.h"

@interface WUAddGroupController : SCAddGroupController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
    WUInterestViewControllerDelegate, WULocationSelectControllerDelegate, UIGestureRecognizerDelegate> {
    IBOutlet UIButton *btnGroupImage;
    
    IBOutlet UITextField *txtTopic;
    IBOutlet UITextField *txtTopic2;
    IBOutlet UIButton *btnInterest;
    IBOutlet UITextField *txtSubInterest;
    IBOutlet UIButton *btnLocation;
    IBOutlet UIButton *btnIsPublic;
    
}

@property (nonatomic, strong) id parentController;

- (IBAction)btnPhotoTapped:(id)sender;
- (IBAction)txtSubInterestDone;
- (IBAction)txtTopicDone;
- (IBAction)txtTopic2Done;
- (IBAction)btnIsPublicTapped:(id)sender;

@end