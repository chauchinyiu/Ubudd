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
#import "ResponseHandler.h"
#import "WUInterestViewController.h"


#define kProfileImage_SelectFromCameraRoll @"Select from Camera Roll"
#define kProfileImage_UseCamera @"Use Camera"

@interface WUUserProfileController (){
    bool genderFemale;
    int interestID;
    NSDate* dob;
}

@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic, assign) BOOL isCameraSupported;

@end

@implementation WUUserProfileController

#pragma mark - UIViewController Delegate
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isCameraSupported = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    
    
    btnProfileImage.imageView.layer.cornerRadius = 42.0;
    btnProfileImage.imageView.layer.masksToBounds = YES;
    
    if ([self.userDefaults boolForKey:kUserDefault_isWelcomeComplete]) {
        SCUserProfile *userProfile = [SCUserProfile currentUser];
        txtDisplayName.text = userProfile.firstname;
        [btnProfileImage setImage:userProfile.userImage forState:UIControlStateNormal];
        
        //read for user default
        genderFemale = [self.userDefaults boolForKey:@"userIsFemale"];
        if (genderFemale) {
            [btnGender setTitle:@"Female" forState:UIControlStateNormal];
        }
        else{
            [btnGender setTitle:@"Male" forState:UIControlStateNormal];
        }
        
        if ([self.userDefaults boolForKey:@"userHasInterest"]) {
            interestID = [self.userDefaults integerForKey:@"userInterestID"];
            [btnInterest setTitle:[[ResponseHandler instance] getInterestNameForID:interestID] forState:UIControlStateNormal];
        }
        else{
            interestID = -1;
            [btnInterest setTitle:@"" forState:UIControlStateNormal];
        }

        if ([self.userDefaults boolForKey:@"userHasSubInterest"]) {
            txtSubInterest.text = [self.userDefaults objectForKey:@"userSubInterest"];
        }

        if ([self.userDefaults boolForKey:@"userHasDOB"]) {
            dob = [self.userDefaults objectForKey:@"userDOB"];
            txtDateofBirth.text = [NSDateFormatter localizedStringFromDate:dob
                                                                 dateStyle:NSDateFormatterMediumStyle
                                                                 timeStyle:NSDateFormatterNoStyle];
        }
        else{
            dob = nil;
        }
    }
    else
        self.navigationItem.hidesBackButton = YES;
    
    
    UIDatePicker* pickerView = [[UIDatePicker alloc] init];
    [pickerView sizeToFit];
    pickerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    pickerView.datePickerMode = UIDatePickerModeDate;
    
    txtDateofBirth.inputView = pickerView;
    
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    keyboardDoneButtonView.barStyle = UIBarStyleDefault;
    keyboardDoneButtonView.translucent = YES;
    keyboardDoneButtonView.tintColor = nil;
    [keyboardDoneButtonView sizeToFit];
    
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
        style:UIBarButtonItemStyleDone target:self
        action:@selector(doneClicked:)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    
    // Plug the keyboardDoneButtonView into the text field...
    txtDateofBirth.inputAccessoryView = keyboardDoneButtonView;
}

- (IBAction)btnGenderTapped{
    genderFemale = !genderFemale;
    if (genderFemale) {
        [btnGender setTitle:@"Female" forState:UIControlStateNormal];
    }
    else{
        [btnGender setTitle:@"Male" forState:UIControlStateNormal];
    }

}

- (IBAction)txtSubInterestDone{
    [txtSubInterest resignFirstResponder];
}

- (void)doneClicked:(id)sender {
    // Write out the date...
    dob = [(UIDatePicker*)txtDateofBirth.inputView date];
    txtDateofBirth.text = [NSDateFormatter localizedStringFromDate:dob
                                                         dateStyle:NSDateFormatterMediumStyle
                                                         timeStyle:NSDateFormatterNoStyle];
    [txtDateofBirth resignFirstResponder];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 3;
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
            
            [[ResponseHandler instance] checkPhoneNumber];
            
            //save to user default
            self.userDefaults = [NSUserDefaults standardUserDefaults];

            [self.userDefaults setBool:genderFemale forKey:@"userIsFemale"];
            if (interestID != -1) {
                [self.userDefaults setBool:YES forKey:@"userHasInterest"];
                [self.userDefaults setInteger:interestID forKey:@"userInterestID"];
            }
            if ([txtSubInterest.text length] > 0) {
                [self.userDefaults setBool:YES forKey:@"userHasSubInterest"];
                [self.userDefaults setObject:txtSubInterest.text forKey:@"userSubInterest"];
            }
            if (dob != nil) {
                [self.userDefaults setBool:YES forKey:@"userHasDOB"];
                [self.userDefaults setObject:dob forKey:@"userDOB"];
            }
            [self.userDefaults synchronize];
            
            //update c2call id and other details to server
            NSString *msdin = [[NSUserDefaults standardUserDefaults] objectForKey:@"msidn"];
            UpdateUserFieldDTO *updateUserFieldDTO = [[UpdateUserFieldDTO alloc] init];
            updateUserFieldDTO.msisdn = msdin;
            updateUserFieldDTO.field = @"c2CallID";
            updateUserFieldDTO.value = [[SCUserProfile currentUser] userid];
            
            WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
            [serviceHandler execute:METHOD_UPDATE_USER_FIELD parameter:updateUserFieldDTO target:self action:@selector(updateUserFieldResponse:error:)];

            updateUserFieldDTO.field = @"interestID";
            updateUserFieldDTO.value = [NSString stringWithFormat:@"%d" , interestID];
            [serviceHandler execute:METHOD_UPDATE_USER_FIELD parameter:updateUserFieldDTO target:self action:@selector(updateUserFieldResponse:error:)];

            updateUserFieldDTO.field = @"interestDescription";
            updateUserFieldDTO.value = txtSubInterest.text;
            [serviceHandler execute:METHOD_UPDATE_USER_FIELD parameter:updateUserFieldDTO target:self action:@selector(updateUserFieldResponse:error:)];
 
            updateUserFieldDTO.field = @"gender";
            updateUserFieldDTO.value = (genderFemale ? @"F" : @"M");
            [serviceHandler execute:METHOD_UPDATE_USER_FIELD parameter:updateUserFieldDTO target:self action:@selector(updateUserFieldResponse:error:)];
            
            if (dob != nil) {
                updateUserFieldDTO.field = @"dob";
                NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:dob];
                updateUserFieldDTO.value = [NSString stringWithFormat:@"%d-%d-%d", [components year], [components month], [components day]];
                [serviceHandler execute:METHOD_UPDATE_USER_FIELD parameter:updateUserFieldDTO target:self action:@selector(updateUserFieldResponse:error:)];
            }
            
            if ([self.userDefaults boolForKey:kUserDefault_isWelcomeComplete])
                [CommonMethods showAlertWithTitle:nil message:@"Profile updated" delegate:nil];
            else
                [self performSegueWithIdentifier:@"WUWelcomeControllerSegue" sender:self];
        }];
    }
}

- (void)updateUserFieldResponse:(ResponseBase *)response error:(NSError *)error{
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    WUInterestViewController *cvc = (WUInterestViewController *)[segue destinationViewController];
    cvc.delegate = self;
}

-(void)selectedInerestID:(int) i withName:(NSString*) name;{
    interestID = i;
    [btnInterest setTitle:name forState:UIControlStateNormal];
}


@end