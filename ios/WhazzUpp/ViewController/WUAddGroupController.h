//
//  WUAddGroupController.h
//  WhazzUpp
//
//  Created by Sahil.Khanna on 09/06/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import <SocialCommunication/SocialCommunication.h>

@interface WUAddGroupController : SCAddGroupController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    IBOutlet UIButton *btnGroupImage;
}

@property (nonatomic, strong) id parentController;

- (IBAction)btnPhotoTapped:(id)sender;

@end