//
//  WUBoardController.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 30/8/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//
#import <UIKit/UIKit.h>
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keywordShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keywordShown:(NSNotification *)notification
{
 
    NSInteger lastSection = self.tableView.numberOfSections - 1 ;
    NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:([self.tableView numberOfRowsInSection:lastSection] - 1) inSection:lastSection];
    [[self tableView] scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[MessageCellOutStream class]]) {
        MessageCellOutStream *c = (MessageCellOutStream*)cell;
        SCBubbleViewOut* view = (SCBubbleViewOut*)(c.bubbleView);
        
        CGSize maximumSize = CGSizeMake(self.view.frame.size.width - 90, 9999);
        CGSize myStringSize = [view.chatText sizeWithFont:[UIFont systemFontOfSize:18]
                                        constrainedToSize:maximumSize
                                            lineBreakMode:NSLineBreakByWordWrapping];
        
        return myStringSize.height + (isGroup? 30 : 18);
    }
    else if ([cell isKindOfClass:[MessageCellInStream class]]) {
        MessageCellInStream *c = (MessageCellInStream*)cell;
        SCBubbleViewIn* view = (SCBubbleViewIn*)(c.bubbleView);
        
        CGSize maximumSize = CGSizeMake(self.view.frame.size.width - 90, 9999);
        CGSize myStringSize = [view.chatText sizeWithFont:[UIFont systemFontOfSize:18]
                                        constrainedToSize:maximumSize
                                            lineBreakMode:NSLineBreakByWordWrapping];
        
        return myStringSize.height + (isGroup? 30 : 18);
    }
    else{
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}


-(void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    [super configureCell:cell atIndexPath:indexPath];
    if ([cell isKindOfClass:[MessageCellOutStream class]]) {
        MessageCellOutStream *c = (MessageCellOutStream*)cell;
        [c.headline setText:@"me"];
        [c.headline setTextColor:[UIColor blackColor]];
        [c.headline setHidden:!isGroup];
        SCBubbleViewOut* view = (SCBubbleViewOut*)(c.bubbleView);
        [view setTextColor:[UIColor blackColor]];
        [view setTextFont:[UIFont systemFontOfSize:18]];
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        CGSize maximumSize = CGSizeMake(self.view.frame.size.width - 90, 9999);
        CGSize myStringSize = [view.chatText sizeWithFont:[UIFont systemFontOfSize:18]
                                   constrainedToSize:maximumSize
                                       lineBreakMode:NSLineBreakByWordWrapping];
        
        NSString* conStr = [NSString stringWithFormat:@"H:[view(==%d)]", (int)roundf(myStringSize.width + 30)];
        NSArray* cstin = [NSLayoutConstraint constraintsWithVisualFormat:conStr options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)];
        [view removeConstraint:view.width];
        [view setWidth:[cstin objectAtIndex:0]];
        [view addConstraints:cstin];
        if (!isGroup) {
            [view setTextOffsetTop:[NSNumber numberWithFloat:0]];
        }
        
    }
    else if ([cell isKindOfClass:[ImageCellOutStream class]]) {
        ImageCellOutStream *c = (ImageCellOutStream*)cell;
        [c.headline setText:@"me"];
        [c.headline setTextColor:[UIColor blackColor]];
        [c.headline setHidden:!isGroup];
    }
    else if ([cell isKindOfClass:[LocationCellOutStream class]]) {
        LocationCellOutStream *c = (LocationCellOutStream*)cell;
        [c.headline setText:@"me"];
        [c.headline setTextColor:[UIColor blackColor]];
        [c.headline setHidden:!isGroup];
    }
    else if ([cell isKindOfClass:[AudioCellOutStream class]]) {
        AudioCellOutStream *c = (AudioCellOutStream*)cell;
        [c.headline setText:@"me"];
        [c.headline setTextColor:[UIColor blackColor]];
        [c.headline setHidden:!isGroup];
    }
    else if ([cell isKindOfClass:[VideoCellOutStream class]]) {
        VideoCellOutStream *c = (VideoCellOutStream*)cell;
        [c.headline setText:@"me"];
        [c.headline setTextColor:[UIColor blackColor]];
        [c.headline setHidden:!isGroup];
    }
    else if ([cell isKindOfClass:[FriendCellOutStream class]]) {
        FriendCellOutStream *c = (FriendCellOutStream*)cell;
        [c.headline setText:@"me"];
        [c.headline setTextColor:[UIColor blackColor]];
        [c.headline setHidden:!isGroup];
    }
    else if ([cell isKindOfClass:[ContactCellOutStream class]]) {
        ContactCellOutStream *c = (ContactCellOutStream*)cell;
        [c.headline setText:@"me"];
        [c.headline setTextColor:[UIColor blackColor]];
        [c.headline setHidden:!isGroup];
    }
    else if ([cell isKindOfClass:[CallCellOutStream class]]) {
        CallCellOutStream *c = (CallCellOutStream*)cell;
        [c.headline setText:@"me"];
        [c.headline setTextColor:[UIColor blackColor]];
        [c.headline setHidden:!isGroup];
    }
    
    else if ([cell isKindOfClass:[MessageCellInStream class]]) {
        MessageCellInStream *c = (MessageCellInStream*)cell;
        [c.imageNewIndicator setHidden:YES];
        [c.headline setTextColor:[UIColor blackColor]];
        [c.headline setHidden:!isGroup];
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        c.headline.attributedText = [[NSAttributedString alloc] initWithString:c.headline.text
                                                                 attributes:underlineAttribute];
        
        
        SCBubbleViewIn* view = (SCBubbleViewIn*)(c.bubbleView);
        [view setTextColor:[UIColor blackColor]];
        [view setTextFont:[UIFont systemFontOfSize:18]];
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        CGSize maximumSize = CGSizeMake(self.view.frame.size.width - 90, 9999);
        CGSize myStringSize = [view.chatText sizeWithFont:[UIFont systemFontOfSize:18]
                                        constrainedToSize:maximumSize
                                            lineBreakMode:NSLineBreakByWordWrapping];
        
        NSString* conStr = [NSString stringWithFormat:@"H:[view(==%d)]", (int)roundf(myStringSize.width + 30)];
        NSArray* cstin = [NSLayoutConstraint constraintsWithVisualFormat:conStr options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)];
        [view removeConstraint:view.width];
        [view setWidth:[cstin objectAtIndex:0]];
        [view addConstraints:cstin];
        if (!isGroup) {
            [view setTextOffsetTop:[NSNumber numberWithFloat:0]];
        }
    }
    else if ([cell isKindOfClass:[ImageCellInStream class]]) {
        ImageCellInStream *c = (ImageCellInStream*)cell;
        [c.imageNewIndicator setHidden:YES];
        [c.messageImage setFrame:CGRectMake(c.messageImage.frame.origin.x, c.messageImage.frame.origin.y, 100, 100) ];
        [c.headline setTextColor:[UIColor blackColor]];
        [c.headline setHidden:!isGroup];
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        c.headline.attributedText = [[NSAttributedString alloc] initWithString:c.headline.text
                                                                    attributes:underlineAttribute];
    }
    else if ([cell isKindOfClass:[LocationCellInStream class]]) {
        LocationCellInStream *c = (LocationCellInStream*)cell;
        [c.imageNewIndicator setHidden:YES];
        [c.headline setTextColor:[UIColor blackColor]];
        [c.headline setHidden:!isGroup];
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        c.headline.attributedText = [[NSAttributedString alloc] initWithString:c.headline.text
                                                                    attributes:underlineAttribute];
    }
    else if ([cell isKindOfClass:[AudioCellInStream class]]) {
        AudioCellInStream *c = (AudioCellInStream*)cell;
        [c.imageNewIndicator setHidden:YES];
        [c.headline setTextColor:[UIColor blackColor]];
        [c.headline setHidden:!isGroup];
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        c.headline.attributedText = [[NSAttributedString alloc] initWithString:c.headline.text
                                                                    attributes:underlineAttribute];
    }
    else if ([cell isKindOfClass:[VideoCellInStream class]]) {
        VideoCellInStream *c = (VideoCellInStream*)cell;
        [c.imageNewIndicator setHidden:YES];
        [c.headline setTextColor:[UIColor blackColor]];
        [c.headline setHidden:!isGroup];
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        c.headline.attributedText = [[NSAttributedString alloc] initWithString:c.headline.text
                                                                    attributes:underlineAttribute];
    }
    else if ([cell isKindOfClass:[FriendCellInStream class]]) {
        FriendCellInStream *c = (FriendCellInStream*)cell;
        [c.imageNewIndicator setHidden:YES];
        [c.headline setTextColor:[UIColor blackColor]];
        [c.headline setHidden:!isGroup];
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        c.headline.attributedText = [[NSAttributedString alloc] initWithString:c.headline.text
                                                                    attributes:underlineAttribute];
    }
    else if ([cell isKindOfClass:[ContactCellInStream class]]) {
        ContactCellInStream *c = (ContactCellInStream*)cell;
        [c.imageNewIndicator setHidden:YES];
        [c.headline setTextColor:[UIColor blackColor]];
        [c.headline setHidden:!isGroup];
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        c.headline.attributedText = [[NSAttributedString alloc] initWithString:c.headline.text
                                                                    attributes:underlineAttribute];
    }
    else if ([cell isKindOfClass:[CallCellInStream class]]) {
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
