//
//  WUVerificationController.m
//  UpBrink
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
#import "DataRequest.h"
#import "DataResponse.h"


@implementation WUVerificationController{
    BOOL requestingResend;

}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIViewController Delegate
- (void)viewDidLoad {
    [super viewDidLoad];
    requestingResend = false;
    self.navigationItem.hidesBackButton = YES;
    
    [txtCode setFont:[CommonMethods getStdFontType:1]];
    [btnResend.titleLabel setFont:[CommonMethods getStdFontType:1]];
    [lblNote setFont:[CommonMethods getStdFontType:1]];
    
    [txtCode becomeFirstResponder];
    [[ResponseHandler instance] readInterests];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"VerifyComplete"]){
        [self performSegueWithIdentifier:@"WUUserProfileControllerSegue" sender:nil];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(hidekeybord)];
    [tap setDelegate:self];
    [self.view addGestureRecognizer:tap];

}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.translucent = NO;
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
        [CommonMethods showAlertWithTitle:NSLocalizedString(@"Registration Error", @"") message:[error localizedDescription] delegate:nil];
    else if (user.errorCode == 1)
        [CommonMethods showAlertWithTitle:NSLocalizedString(@"Registration Error", @"") message:user.message delegate:nil];
    else {
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:false forKey:kUserDefault_isWelcomeComplete];
        [userDefaults setBool:true forKey:@"VerifyComplete"];
        [userDefaults synchronize];
        
        [self performSegueWithIdentifier:@"WUUserProfileControllerSegue" sender:nil];
    }
}

- (IBAction)btnResendTapped{
    if (requestingResend) {
        return;
    }
    else{
        requestingResend = true;
        NSString *msdin = [[NSUserDefaults standardUserDefaults] objectForKey:@"msidn"];
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setObject:msdin forKey:@"msisdn"];
        
        DataRequest *dataRequest = [[DataRequest alloc] init];
        dataRequest.requestName = @"sendVerification";
        dataRequest.values = dictionary;
        
        WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
        [serviceHandler execute:METHOD_DATA_REQUEST parameter:dataRequest target:self action:@selector(sendVerification:error:)];
    }
}

- (void)sendVerification:(ResponseBase *)response error:(NSError *)error {
    if (error){
        
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Resend verification code", @"")
                                                        message:NSLocalizedString(@"Verification code sent", @"")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
        [alert show];

    }
    requestingResend = false;
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
    
}
@end