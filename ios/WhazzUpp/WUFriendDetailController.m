//
//  WUFriendDetailController.m
//  WhazzUpp
//
//  Created by Michael Knecht on 03.06.13.
//  Copyright (c) 2013 C2Call GmbH. All rights reserved.
//

#import "WUFriendDetailController.h"
#import "WUChatController.h"
#import <SocialCommunication/UDUserInfoCell.h>
#import <SocialCommunication/C2TapImageView.h>

#import <SocialCommunication/UIViewController+SCCustomViewController.h>
#import "WUBoardController.h"

@implementation WUFriendDetailController

#pragma mark - UIViewController Delegate
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userInfoCell.userImage.layer.cornerRadius = 35.0;
    self.userInfoCell.userImage.layer.masksToBounds = YES;
}

-(IBAction)chat:(id)sender
{
    int idx = [self.navigationController.viewControllers indexOfObject:self];
    if (idx != NSNotFound && idx > 0) {
        UIViewController *previousController = [self.navigationController.viewControllers objectAtIndex:idx - 1];
        if ([previousController isKindOfClass:[WUChatController class]]) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
    }
    
    MOC2CallUser *user = [self currentUser];
    if ([user.userType intValue] == 2) {
        [WUBoardController setIsGroup:YES];
    } else {
        [WUBoardController setIsGroup:NO];
    }
    [self showChatForUserid:user.userid];
}

@end