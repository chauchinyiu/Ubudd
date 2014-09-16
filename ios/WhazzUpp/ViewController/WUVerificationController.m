//
//  WUVerificationController.m
//  WhazzUpp
//
//  Created by Sahil.Khanna on 13/06/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import "WUVerificationController.h"
#import "Constant.h"
#import "WebserviceHandler.h"
#import "ServiceURL.h"
#import "ResponseBase.h"
#import "CommonMethods.h"
#import "VerifyUser.h"
#import "VerifyUserDTO.h"
#import "ResponseHandler.h"

@implementation WUVerificationController

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIViewController Delegate
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    
    [txtCode becomeFirstResponder];
    [[ResponseHandler instance] readInterests];

}
-(IBAction)nextButtonClicked:(id)sender{
    
    if (txtCode.text.length > 0) {
        
        
        NSString *msdin = [[NSUserDefaults standardUserDefaults] objectForKey:@"msidn"];
        
        
        VerifyUserDTO *verifyUserDTO = [[VerifyUserDTO alloc] init];
        verifyUserDTO.msisdn = msdin;
        verifyUserDTO.number = txtCode.text;

      
        
        WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
        [serviceHandler execute:METHOD_VERIFICATIONCODE parameter:verifyUserDTO target:self action:@selector(verificationCodeResponse:error:)];
         
        
        //[self performSegueWithIdentifier:@"WUUserProfileControllerSegue" sender:nil];
    }
    
   
}
#pragma mark - Webservice Response
- (void)verificationCodeResponse:(ResponseBase *)response error:(NSError *)error {
    [CommonMethods showLoading:NO title:nil message:nil];
    
    VerifyUser *user = (VerifyUser *)response;
    
    if (error)
        [CommonMethods showAlertWithTitle:@"Registration Error" message:[error localizedDescription] delegate:nil];
    else if (user.errorCode == 1)
        [CommonMethods showAlertWithTitle:@"Registration Error" message:user.message delegate:nil];
    else {
        [self performSegueWithIdentifier:@"WUUserProfileControllerSegue" sender:nil];
    }
}


@end