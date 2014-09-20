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
#import "SocialCommunication/MessageCellInStream.h"
#import "SocialCommunication/ImageCellInStream.h"
#import "SocialCommunication/LocationCellInStream.h"
#import "SocialCommunication/AudioCellInStream.h"
#import "SocialCommunication/VideoCellInStream.h"
#import "SocialCommunication/FriendCellInStream.h"
#import "SocialCommunication/ContactCellInStream.h"
#import "SocialCommunication/CallCellInStream.h"

@interface WUBoardController ()
@end


@implementation WUBoardController
static BOOL isGroup = YES;

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
        [c.headline setTextColor:[UIColor blackColor]];
        [c.headline setHidden:!isGroup];
        [(SCBubbleViewOut*)(c.bubbleView) setTextColor:[UIColor blackColor]];
        [(SCBubbleViewOut*)(c.bubbleView) setTextFont:[UIFont systemFontOfSize:18]];
    }
    if ([cell isKindOfClass:[ImageCellOutStream class]]) {
        ImageCellOutStream *c = (ImageCellOutStream*)cell;
        [c.headline setText:@"me"];
        [c.headline setTextColor:[UIColor blackColor]];
        [c.headline setHidden:!isGroup];
    }
    if ([cell isKindOfClass:[LocationCellOutStream class]]) {
        LocationCellOutStream *c = (LocationCellOutStream*)cell;
        [c.headline setText:@"me"];
        [c.headline setTextColor:[UIColor blackColor]];
        [c.headline setHidden:!isGroup];
    }
    if ([cell isKindOfClass:[AudioCellOutStream class]]) {
        AudioCellOutStream *c = (AudioCellOutStream*)cell;
        [c.headline setText:@"me"];
        [c.headline setTextColor:[UIColor blackColor]];
        [c.headline setHidden:!isGroup];
    }
    if ([cell isKindOfClass:[VideoCellOutStream class]]) {
        VideoCellOutStream *c = (VideoCellOutStream*)cell;
        [c.headline setText:@"me"];
        [c.headline setTextColor:[UIColor blackColor]];
        [c.headline setHidden:!isGroup];
    }
    if ([cell isKindOfClass:[FriendCellOutStream class]]) {
        FriendCellOutStream *c = (FriendCellOutStream*)cell;
        [c.headline setText:@"me"];
        [c.headline setTextColor:[UIColor blackColor]];
        [c.headline setHidden:!isGroup];
    }
    if ([cell isKindOfClass:[ContactCellOutStream class]]) {
        ContactCellOutStream *c = (ContactCellOutStream*)cell;
        [c.headline setText:@"me"];
        [c.headline setTextColor:[UIColor blackColor]];
        [c.headline setHidden:!isGroup];
    }
    if ([cell isKindOfClass:[CallCellOutStream class]]) {
        CallCellOutStream *c = (CallCellOutStream*)cell;
        [c.headline setText:@"me"];
        [c.headline setTextColor:[UIColor blackColor]];
        [c.headline setHidden:!isGroup];
    }
    
    if ([cell isKindOfClass:[MessageCellInStream class]]) {
        MessageCellInStream *c = (MessageCellInStream*)cell;
        [c.imageNewIndicator setHidden:YES];
        [c.headline setTextColor:[UIColor blackColor]];
        [c.headline setHidden:!isGroup];
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        c.headline.attributedText = [[NSAttributedString alloc] initWithString:c.headline.text
                                                                 attributes:underlineAttribute];
        
        
        [(SCBubbleViewIn*)(c.bubbleView) setTextColor:[UIColor blackColor]];
        [(SCBubbleViewIn*)(c.bubbleView) setTextFont:[UIFont systemFontOfSize:18]];
    }
    if ([cell isKindOfClass:[ImageCellInStream class]]) {
        ImageCellInStream *c = (ImageCellInStream*)cell;
        [c.imageNewIndicator setHidden:YES];
        [c.messageImage setFrame:CGRectMake(c.messageImage.frame.origin.x, c.messageImage.frame.origin.y, 100, 100) ];
        [c.headline setTextColor:[UIColor blackColor]];
        [c.headline setHidden:!isGroup];
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        c.headline.attributedText = [[NSAttributedString alloc] initWithString:c.headline.text
                                                                    attributes:underlineAttribute];
    }
    if ([cell isKindOfClass:[LocationCellInStream class]]) {
        LocationCellInStream *c = (LocationCellInStream*)cell;
        [c.imageNewIndicator setHidden:YES];
        [c.headline setTextColor:[UIColor blackColor]];
        [c.headline setHidden:!isGroup];
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        c.headline.attributedText = [[NSAttributedString alloc] initWithString:c.headline.text
                                                                    attributes:underlineAttribute];
    }
    if ([cell isKindOfClass:[AudioCellInStream class]]) {
        AudioCellInStream *c = (AudioCellInStream*)cell;
        [c.imageNewIndicator setHidden:YES];
        [c.headline setTextColor:[UIColor blackColor]];
        [c.headline setHidden:!isGroup];
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        c.headline.attributedText = [[NSAttributedString alloc] initWithString:c.headline.text
                                                                    attributes:underlineAttribute];
    }
    if ([cell isKindOfClass:[VideoCellInStream class]]) {
        VideoCellInStream *c = (VideoCellInStream*)cell;
        [c.imageNewIndicator setHidden:YES];
        [c.headline setTextColor:[UIColor blackColor]];
        [c.headline setHidden:!isGroup];
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        c.headline.attributedText = [[NSAttributedString alloc] initWithString:c.headline.text
                                                                    attributes:underlineAttribute];
    }
    if ([cell isKindOfClass:[FriendCellInStream class]]) {
        FriendCellInStream *c = (FriendCellInStream*)cell;
        [c.imageNewIndicator setHidden:YES];
        [c.headline setTextColor:[UIColor blackColor]];
        [c.headline setHidden:!isGroup];
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        c.headline.attributedText = [[NSAttributedString alloc] initWithString:c.headline.text
                                                                    attributes:underlineAttribute];
    }
    if ([cell isKindOfClass:[ContactCellInStream class]]) {
        ContactCellInStream *c = (ContactCellInStream*)cell;
        [c.imageNewIndicator setHidden:YES];
        [c.headline setTextColor:[UIColor blackColor]];
        [c.headline setHidden:!isGroup];
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        c.headline.attributedText = [[NSAttributedString alloc] initWithString:c.headline.text
                                                                    attributes:underlineAttribute];
    }
    if ([cell isKindOfClass:[CallCellInStream class]]) {
        CallCellInStream *c = (CallCellInStream*)cell;
        [c.imageNewIndicator setHidden:YES];
        [c.headline setTextColor:[UIColor blackColor]];
        [c.headline setHidden:!isGroup];
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        c.headline.attributedText = [[NSAttributedString alloc] initWithString:c.headline.text
                                                                    attributes:underlineAttribute];
    }

}

+(void)setIsGroup:(BOOL)b{
    isGroup = b;
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
