//
//  WUBoardController.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 30/8/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "WUBoardController.h"
#import "SocialCommunication/MessageCellOutStream.h"
#import "SocialCommunication/ImageCellOutStream.h"
#import "SocialCommunication/LocationCellOutStream.h"
#import "SocialCommunication/AudioCellOutStream.h"
#import "SocialCommunication/VideoCellOutStream.h"
#import "SocialCommunication/FriendCellOutStream.h"
#import "SocialCommunication/ContactCellOutStream.h"
#import "SocialCommunication/CallCellOutStream.h"

@interface WUBoardController ()

@end

@implementation WUBoardController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    [super configureCell:cell atIndexPath:indexPath];
    if ([cell isKindOfClass:[MessageCellOutStream class]]) {
        MessageCellOutStream *c = (MessageCellOutStream*)cell;
        [c.headline setText:@"me"];
    }
    if ([cell isKindOfClass:[ImageCellOutStream class]]) {
        ImageCellOutStream *c = (ImageCellOutStream*)cell;
        [c.headline setText:@"me"];
    }
    if ([cell isKindOfClass:[LocationCellOutStream class]]) {
        LocationCellOutStream *c = (LocationCellOutStream*)cell;
        [c.headline setText:@"me"];
    }
    if ([cell isKindOfClass:[AudioCellOutStream class]]) {
        AudioCellOutStream *c = (AudioCellOutStream*)cell;
        [c.headline setText:@"me"];
    }
    if ([cell isKindOfClass:[VideoCellOutStream class]]) {
        VideoCellOutStream *c = (VideoCellOutStream*)cell;
        [c.headline setText:@"me"];
    }
    if ([cell isKindOfClass:[FriendCellOutStream class]]) {
        FriendCellOutStream *c = (FriendCellOutStream*)cell;
        [c.headline setText:@"me"];
    }
    if ([cell isKindOfClass:[ContactCellOutStream class]]) {
        ContactCellOutStream *c = (ContactCellOutStream*)cell;
        [c.headline setText:@"me"];
    }
    if ([cell isKindOfClass:[CallCellOutStream class]]) {
        CallCellOutStream *c = (CallCellOutStream*)cell;
        [c.headline setText:@"me"];
    }

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
