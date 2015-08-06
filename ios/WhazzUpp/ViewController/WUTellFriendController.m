//
//  WUTellFriendController.m
//  WhazzUpp
//
//  Created by Sahil.Khanna on 24/06/14.
//  Copyright (c) 2014 3Embed Technologies. All rights reserved.
//

#import "WUTellFriendController.h"
#import "CommonMethods.h"
#import <Social/Social.h>

@implementation WUTellFriendController

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.translucent = NO;
}


- (void)composeMessage {
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
        messageController.body = NSLocalizedString(@"Tell Friend SMS", @"");
        messageController.messageComposeDelegate = self;
        [self presentViewController:messageController animated:YES completion:nil];
    }
    else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"sms:"]];
    }
}

- (void)composeEmail {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *emailController = [[MFMailComposeViewController alloc] init];
        [emailController setSubject:@"UBudd: iOS + Android"];
        [emailController setMessageBody:NSLocalizedString(@"Tell Friend Email", @"") isHTML:NO];
        emailController.mailComposeDelegate = self;
        [self presentViewController:emailController animated:YES completion:nil];
    }
    else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:"]];
    }
}

- (void)shareFacebook{
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
    [controller setInitialText:NSLocalizedString(@"First post from my iPhone app", @"")];
    [self presentViewController:controller animated:YES completion:Nil];
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0)
        [self composeEmail];
    else if (indexPath.row == 1)
        [self composeMessage];
    else if (indexPath.row == 2)
        [self shareFacebook];
}

#pragma mark - MFMessageComposeViewController Delegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MFMailComposeViewController Delegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end