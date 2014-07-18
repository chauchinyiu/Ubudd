//
//  WULaunchScreenController.m
//  WhazzUpp
//
//  Created by Sahil.Khanna on 01/06/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import "WULaunchScreenController.h"
#import "WUAppDelegate.h"

@implementation WULaunchScreenController

- (void)viewDidAppear:(BOOL)animated {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"registerStatus"]) {
        [self performSegueWithIdentifier:@"SCRegistrationControllerSegue" sender:self];
    }
}

@end