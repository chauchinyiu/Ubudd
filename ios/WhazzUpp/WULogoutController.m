//
//  WULogoutController.m
//  WhazzUpp
//
//  Created by Michael Knecht on 17.06.13.
//  Copyright (c) 2013 C2Call GmbH. All rights reserved.
//

#import "WULogoutController.h"
#import "WUAppDelegate.h"

@interface WULogoutController ()

@end

@implementation WULogoutController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.translucent = NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)logout:(id)sender
{
    [[WUAppDelegate appDelegate] logoutUser];
    self.tabBarController.selectedIndex = 0;
}

@end
