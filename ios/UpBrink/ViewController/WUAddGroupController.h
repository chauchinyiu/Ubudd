//
//  WUAddGroupController.h
//  UpBrink
//
//  Created by Sahil.Khanna on 09/06/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import <SocialCommunication/SocialCommunication.h>
#import "WUInterestViewController.h"
#import "WULocationSearchController.h"
#import "WUUserSelectionController.h"
#import <SocialCommunication/C2TapImageView.h>

@interface WUGroupMemberCell : UITableViewCell
    @property(nonatomic, weak) IBOutlet UILabel *nameLabel;
    @property (nonatomic, weak) IBOutlet UIImageView *userImg;
@end

@interface WUAddGroupController : SCAddGroupController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
    WUInterestViewControllerDelegate, WULocationSelectControllerDelegate, UIGestureRecognizerDelegate, WUUserSelectClientDelegate> {
    IBOutlet UIButton *btnGroupImage;
    
    IBOutlet UITextField *txtTopic;
    IBOutlet UIButton *btnInterest;
    IBOutlet UIButton *btnLocation;
    IBOutlet UIButton *btnIsPublic;
    IBOutlet UIBarButtonItem *btnDone;
    IBOutlet C2TapImageView *btnPhoto;
    
}

@property (nonatomic, strong) id parentController;

- (IBAction)btnPhotoTapped:(id)sender;
- (IBAction)btnIsPublicTapped:(id)sender;
- (IBAction)btnAddGroupClicked:(id)sender;

- (IBAction)editEnded;

@end