//
//  WUWelcomeController.m
//  UpBrink
//
//  Created by Sahil.Khanna on 13/06/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import "WUWelcomeController.h"
#import "Constant.h"
#import "../WUAppDelegate.h"
#import "ResponseHandler.h"

@interface WUWelcomeController(){
    ResponseHandler *resHandler;
}
@end

@implementation WUWelcomeController

#pragma mark - UIButton Action
- (IBAction)btnContinueTapped {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefault_isWelcomeComplete];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UITabBarController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"InitController"];
    [[UIApplication sharedApplication].keyWindow setRootViewController:rootViewController];
    
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    [[C2CallPhone currentPhone] transferAddressBook:NO];
    
    WUAppDelegate *appDelegate = (WUAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate registerPushNotifications];
    
    
    resHandler = [ResponseHandler instance];
    [resHandler verifyNewC2CallID];
    
}

#pragma mark - UIViewController Delegate
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBarHidden = YES;
}




@end