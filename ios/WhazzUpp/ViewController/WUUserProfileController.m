//
//  WUUserProfileController.m
//  WhazzUpp
//
//  Created by Sahil.Khanna on 02/06/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import "WUUserProfileController.h"
#import "CommonMethods.h"
#import "WUAppDelegate.h"
#import "UpdateUserFieldDTO.h"
#import "UpdateUserField.h"
#import "WebServiceHandler.h"


#define kProfileImage_SelectFromCameraRoll @"Select from Camera Roll"
#define kProfileImage_UseCamera @"Use Camera"

@interface WUUserProfileController ()

@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic, assign) BOOL isCameraSupported;

@end

@implementation WUUserProfileController

#pragma mark - UIViewController Delegate
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isCameraSupported = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    
    
    btnProfileImage.imageView.layer.cornerRadius = 40.0;
    btnProfileImage.imageView.layer.masksToBounds = YES;
    
    if ([self.userDefaults boolForKey:kUserDefault_isWelcomeComplete]) {
        SCUserProfile *userProfile = [SCUserProfile currentUser];
        txtDisplayName.text = userProfile.firstname;
        [btnProfileImage setImage:userProfile.userImage forState:UIControlStateNormal];
    }
    else
        self.navigationItem.hidesBackButton = YES;
}

#pragma mark - UIButton Action
- (IBAction)btnSaveTapped {
    txtDisplayName.text = [CommonMethods trimText:txtDisplayName.text];
    
    if (txtDisplayName.text.length == 0) {
        [CommonMethods showAlertWithTitle:@"Enter Details" message:@"Display Name cannot be empty" delegate:nil];
    }
    else {
        [CommonMethods showLoading:YES title:nil message:@"Saving"];
        
        SCUserProfile *userProfile = [SCUserProfile currentUser];
        userProfile.firstname = txtDisplayName.text;
        
        if (btnProfileImage.imageView.image) {
            [userProfile setUserImage:btnProfileImage.imageView.image withCompletionHandler:^(BOOL finished) {
                //Do nothing
            }];
        }
        
        [userProfile saveUserProfileWithCompletionHandler:^(BOOL success) {
            
            [CommonMethods showLoading:NO title:nil message:nil];
            
            //update c2call id to server
            NSString *msdin = [[NSUserDefaults standardUserDefaults] objectForKey:@"msidn"];
            UpdateUserFieldDTO *updateUserFieldDTO = [[UpdateUserFieldDTO alloc] init];
            updateUserFieldDTO.msisdn = msdin;
            updateUserFieldDTO.field = @"c2CallID";
            updateUserFieldDTO.value = [[SCUserProfile currentUser] userid];

            
            WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
            [serviceHandler execute:METHOD_UPDATE_USER_FIELD parameter:updateUserFieldDTO target:self action:@selector(updateUserFieldResponse:error:)];
            
            
            if ([self.userDefaults boolForKey:kUserDefault_isWelcomeComplete])
                [CommonMethods showAlertWithTitle:nil message:@"Profile updated" delegate:nil];
            else
                [self performSegueWithIdentifier:@"WUWelcomeControllerSegue" sender:self];
        }];
    }
}

- (IBAction)btnProfileImageTapped {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select photo" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [actionSheet addButtonWithTitle:kProfileImage_SelectFromCameraRoll];
    }
    
    if ([SIPPhone currentPhone].callStatus == SCCallStatusNone) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [actionSheet addButtonWithTitle:kProfileImage_UseCamera];
        }
    }
    
    [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.allowsEditing = YES;
    imagePickerController.delegate = self;
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kProfileImage_SelectFromCameraRoll]) {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kProfileImage_UseCamera]) {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        imagePickerController.showsCameraControls = YES;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [btnProfileImage setImage:[info objectForKey:@"UIImagePickerControllerEditedImage"] forState:UIControlStateNormal];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end