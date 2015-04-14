//
//  WUUserProfileController.m
//  WhazzUpp
//
//  Created by Sahil.Khanna on 02/06/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//
#import <SocialCommunication/UIViewController+SCCustomViewController.h>
#import "WUUserProfileController.h"
#import "CommonMethods.h"
#import "WUAppDelegate.h"
#import "UpdateUserFieldDTO.h"
#import "UpdateUserField.h"
#import "WebServiceHandler.h"
#import "ResponseHandler.h"
#import "WUUserImageController.h"

@interface WUUserProfileController (){
    bool genderFemale;
    int interestID;
    NSDate* dob;
    BOOL hasPhoto;
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

    NSMutableString *stringts = [NSMutableString stringWithString:[self.userDefaults objectForKey:@"phoneNo"]];
    [stringts insertString:@"-" atIndex:4];
    if (stringts.length > 9) {
        [stringts insertString:@"-" atIndex:9];
    }
    
    
    [lblTelNo setText:[NSString stringWithFormat:NSLocalizedString(@"Tel No", @""), [self.userDefaults objectForKey:@"countryCode"], stringts]];
    SCUserProfile *userProfile = [SCUserProfile currentUser];
    if (userProfile.userImage) {
        hasPhoto = YES;
    }
    else{
        hasPhoto = NO;
    }
    
    userImage.layer.cornerRadius = 0.0;
    userImage.layer.masksToBounds = YES;
    [userImage setTapAction:^{
        SCUserProfile *userProfile = [SCUserProfile currentUser];
        if(hasPhoto){
            NSString * storyboardName = @"MainStoryboard";
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
            WUUserImageController * vc = [storyboard instantiateViewControllerWithIdentifier:@"SCUserImageController"];
            vc.viewImage = userImage.image;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else{
            [self btnProfileImageTapped];
        }
    }];
    if ([self.userDefaults boolForKey:kUserDefault_isWelcomeComplete]) {
        SCUserProfile *userProfile = [SCUserProfile currentUser];
        txtDisplayName.text = userProfile.firstname;
        if(userProfile.userImage){
            [userImage setImage:userProfile.userImage];
        }
        
        
    }
    else
        self.navigationItem.hidesBackButton = YES;
    
    
    
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    keyboardDoneButtonView.barStyle = UIBarStyleDefault;
    keyboardDoneButtonView.translucent = YES;
    keyboardDoneButtonView.tintColor = nil;
    [keyboardDoneButtonView sizeToFit];
    
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
        style:UIBarButtonItemStyleDone target:self
        action:@selector(doneClicked:)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    
    [btnStatus setTitle:[SCUserProfile currentUser].userStatus forState:UIControlStateNormal];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(hidekeybord)];
    [tap setDelegate:self];
    [self.view addGestureRecognizer:tap];
    
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.translucent = NO;
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
        [CommonMethods showAlertWithTitle:NSLocalizedString(@"Enter Details", @"") message:NSLocalizedString(@"Display Name cannot be empty", @"") delegate:nil];
    }
    else {
        [CommonMethods showLoading:YES title:nil message:NSLocalizedString(@"Saving", @"")];
        
        SCUserProfile *userProfile = [SCUserProfile currentUser];
        userProfile.firstname = txtDisplayName.text;
        userProfile.userStatus = [btnStatus titleForState:UIControlStateNormal];
        
        if (btnProfileImage.imageView.image) {
            [userProfile setUserImage:btnProfileImage.imageView.image withCompletionHandler:^(BOOL finished) {
                //Do nothing
            }];
        }
        
        [userProfile saveUserProfileWithCompletionHandler:^(BOOL success) {
            
            [CommonMethods showLoading:NO title:nil message:nil];
            
            [[ResponseHandler instance] checkPhoneNumberFromIndex:0];
            
            //save to user default
            self.userDefaults = [NSUserDefaults standardUserDefaults];

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

            updateUserFieldDTO.field = @"userName";
            updateUserFieldDTO.value = txtDisplayName.text;
            [serviceHandler execute:METHOD_UPDATE_USER_FIELD parameter:updateUserFieldDTO target:self action:@selector(updateUserFieldResponse:error:)];
            
            updateUserFieldDTO.field = @"status";
            if([btnStatus titleForState:UIControlStateNormal]){
                updateUserFieldDTO.value = [btnStatus titleForState:UIControlStateNormal];
            }
            else{
                updateUserFieldDTO.value = @"";
            }
            [serviceHandler execute:METHOD_UPDATE_USER_FIELD parameter:updateUserFieldDTO target:self action:@selector(updateUserFieldResponse:error:)];
            
            if (dob != nil) {
                updateUserFieldDTO.field = @"dob";
                NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:dob];
                updateUserFieldDTO.value = [NSString stringWithFormat:@"%d-%d-%d", (int)[components year] , (int)[components month],(int)[components day]];
                
                [serviceHandler execute:METHOD_UPDATE_USER_FIELD parameter:updateUserFieldDTO target:self action:@selector(updateUserFieldResponse:error:)];
            }
            
            if ([self.userDefaults boolForKey:kUserDefault_isWelcomeComplete])
                [CommonMethods showAlertWithTitle:nil message:NSLocalizedString(@"Profile updated", @"") delegate:nil];
            else
                [self performSegueWithIdentifier:@"WUWelcomeControllerSegue" sender:self];
        }];
    }
}


- (void)updateUserFieldResponse:(ResponseBase *)response error:(NSError *)error{
}

- (IBAction)btnProfileImageTapped {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select photo", @"") delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Select from Camera Roll", @"")];
    }
    
    if ([SIPPhone currentPhone].callStatus == SCCallStatusNone) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [actionSheet addButtonWithTitle:NSLocalizedString(@"Use Camera", @"")];
        }
    }
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;

    if (nil == self.tabBarController) {
        [actionSheet showInView:self.view];
    }
    else {
        [actionSheet showFromTabBar:self.tabBarController.tabBar];
    }
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.allowsEditing = YES;
    imagePickerController.delegate = self;
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Select from Camera Roll", @"")]) {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Use Camera", @"")]) {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        imagePickerController.showsCameraControls = YES;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [userImage setImage:[info objectForKey:@"UIImagePickerControllerEditedImage"]];
    hasPhoto = true;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"Status"]) {
        WUStatusSelectController *cvc = (WUStatusSelectController *)[segue destinationViewController];
        cvc.currentStatus = [btnStatus titleForState:UIControlStateNormal];
        cvc.delegate = self;
    }
}



-(void)selectedStatus:(NSString*)status{
    [btnStatus setTitle:status forState:UIControlStateNormal];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    NSLog(@"went here ...");
    
    if((![touch.view isKindOfClass:[UITextView class]])
       && (![touch.view isKindOfClass:[UITextField class]])){
        [self.view endEditing:YES];
    }
    return NO; // handle the touch
}

-(void)hidekeybord
{
    [self.view endEditing:YES];
}

@end