//
//  WUTellFriendController.m
//  WhazzUpp
//
//  Created by Sahil.Khanna on 24/06/14.
//  Copyright (c) 2014 3Embed Technologies. All rights reserved.
//

#import "WUTellFriendController.h"
#import "CommonMethods.h"

@implementation WUTellFriendController

- (void)composeMessage {
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
        messageController.body = @"Check out \"Sup?\" Messenger for your smartphone. Download it today from http://appscrip.com/whatsapp-clone-wechat-clone-script/";
        messageController.messageComposeDelegate = self;
        [self presentViewController:messageController animated:YES completion:nil];
    }
    else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"sms:"]];
}

- (void)composeEmail {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *emailController = [[MFMailComposeViewController alloc] init];
        [emailController setSubject:@"Sup? Messenger: iOS + Android"];
        [emailController setMessageBody:[NSString stringWithFormat:@"Hey,\n\nI just downloaded Sup? Messenger on my %@.\n\nIt's a Messenger for smartphones which replaces SMS. This app even lets me send pictures, videos and other multimedia.\n\nSup? Messenger is available for iOS and Android devices and there is no PIN or username to remember - it works just like SMS and uses internet data plan\n\nGet it now from http://appscrip.com/whatsapp-clone-wechat-clone-script/ and say good-bye to SMS.", [UIDevice currentDevice].model] isHTML:NO];
        emailController.mailComposeDelegate = self;
        [self presentViewController:emailController animated:YES completion:nil];
    }
    else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:"]];
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0)
        [self composeEmail];
    else if (indexPath.row == 1)
        [self composeMessage];
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