//
//  WUBoardController.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 30/8/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "WUBoardController.h"
#import <SocialCommunication/UIViewController+SCCustomViewController.h>
#import <SocialCommunication/MessageCell.h>
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
#import <SocialCommunication/C2TapImageView.h>
#import "CommonMethods.h"
#import "WUPhotoViewController.h"


@implementation WUCreateGroupCell

@synthesize nameLabel;

@end

@interface WUBoardController (){
    CGFloat messageInHeightOffset, messageOutHeightOffset, messageInMinHeight, messageOutMinHeight;
    
    int groupHeadType;
    NSMutableArray* friendList;
    BOOL isVisible;

}
@property (nonatomic, strong) NSMutableDictionary  *smallImageCache;
@property (nonatomic, strong) UIFont *textFieldInFont, *headerFieldInFont, *textFieldOutFont, *headerFieldOutFont;
@end


@implementation WUBoardController
@synthesize smallImageCache;
@synthesize textFieldInFont, textFieldOutFont, headerFieldInFont, headerFieldOutFont;

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

    if (!self.smallImageCache) {
        self.smallImageCache = [NSMutableDictionary dictionaryWithCapacity:50];
    }
    MessageCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MessageCellInStream"];
    self.textFieldInFont = [UIFont fontWithName:cell.textfield.font.fontName size:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline].pointSize * 2 - 14];

    self.headerFieldInFont = cell.headline.font;
    
    CGRect cellFrame = cell.frame;
    CGRect bubbleFrame = cell.bubbleView.frame;
    CGRect textFrame = cell.textfield.frame;
    
    messageInMinHeight = cellFrame.size.height;
    messageInHeightOffset = 0 + bubbleFrame.origin.y + textFrame.origin.y;
    messageInHeightOffset += cellFrame.size.height - (bubbleFrame.size.height + bubbleFrame.origin.y);
    messageInHeightOffset += bubbleFrame.size.height - (textFrame.size.height + textFrame.origin.y);
    
    
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"MessageCellOutStream"];
    self.textFieldOutFont = [UIFont fontWithName:cell.textfield.font.fontName size:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline].pointSize * 2 - 14];

    self.headerFieldOutFont = cell.headline.font;
    
    cellFrame = cell.frame;
    bubbleFrame = cell.bubbleView.frame;
    textFrame = cell.textfield.frame;
    
    messageOutMinHeight = cellFrame.size.height;
    messageOutHeightOffset = 0 + bubbleFrame.origin.y + textFrame.origin.y;
    messageOutHeightOffset += cellFrame.size.height - (bubbleFrame.size.height + bubbleFrame.origin.y);
    messageOutHeightOffset += bubbleFrame.size.height - (textFrame.size.height + textFrame.origin.y);
    groupHeadType = 0;
    friendList = [ResponseHandler instance].friendList;
    
}

-(void) viewWillAppear:(BOOL)animated{
    isVisible = YES;
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    isVisible = NO;
    
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


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.targetUserid) {
        if (groupHeadType == 0) {
            groupHeadType = 1;
            if (isGroup && ([[self.fetchedResultsController fetchedObjects] count] < 20)) {
                groupHeadType = 2;
            }
        }
        if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
            return 1 + (groupHeadType == 2 ? 1 : 0);
        }
        
        return [[self.fetchedResultsController sections] count] + (groupHeadType == 2 ? 1 : 0);
    }
    else{
        return 1;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.targetUserid) {
        if (groupHeadType == 2 && section == 0) {
            return 0;
        }
        else{
            if ([self.fetchedResultsController fetchedObjects].count == 0) {
                return 1;
            }
            
            id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section - (groupHeadType == 2 ? 1 : 0)];
            return [sectionInfo numberOfObjects];
        }
    }
    else{
        return [ResponseHandler instance].broadcastList.count;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(self.targetUserid){
        if (groupHeadType == 2) {
            if (section == 0) {
                return 44;
            }
            return [super tableView:tableView heightForHeaderInSection:section - 1];
        }
        return [super tableView:tableView heightForHeaderInSection:section];
    }
    else{
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(self.targetUserid){
        if (groupHeadType == 2 && section == 0) {
            WUCreateGroupCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"WUCreateGroupCell"];

            
            MOC2CallGroup* mg = [[SCDataManager instance] groupForGroupid:self.targetUserid];
            NSString* ownerName;
            NSDictionary* d = [[C2CallPhone currentPhone] getUserInfoForUserid:mg.groupOwner];
            ownerName = [d objectForKey:@"Firstname"];
            for (int i = 0; i < friendList.count; i++) {
                WUAccount* a = [friendList objectAtIndex:i];
                if ([a.c2CallID isEqualToString:mg.groupOwner]) {
                    ownerName = a.name;
                }
            }
            NSString* groupName = mg.groupName;
            NSMutableArray* groups = [[ResponseHandler instance] groupList];
            for (int i = 0; i < groups.count; i++) {
                WUAccount* a = [groups objectAtIndex:i];
                if ([a.c2CallID isEqualToString:self.targetUserid]) {
                    groupName = a.name;
                }
            }
            
            cell.nameLabel.text = [NSString stringWithFormat:@"%@ created an event %@", ownerName, groupName];
            return cell;
        }
        else{
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section - (groupHeadType == 2 ? 1 : 0)];
            MOC2CallEvent *elem = nil;
            @try {
                elem = [self.fetchedResultsController objectAtIndexPath:indexPath];
            }
            @catch (NSException *exception) {
            }
            NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"MMMM d HH:mm" options:0
                                                                      locale:[NSLocale currentLocale]];
            if (section == 0 && elem) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:formatString];
                //[dateFormatter setDateStyle:NSDateFormatterShortStyle];
                //[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
                self.firstHeaderLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:elem.timeStamp]];
                self.firstHeaderView.hidden = NO;
                return self.headerView;
            }
            
            if (elem) {
                if (self.timestampHeader) {
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:formatString];
                    //[dateFormatter setDateStyle:NSDateFormatterShortStyle];
                    //[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
                    
                    self.timestampLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:elem.timeStamp]];
                    
                    NSData *archivedViewData = [NSKeyedArchiver archivedDataWithRootObject: self.timestampHeader];
                    id clone = [NSKeyedUnarchiver unarchiveObjectWithData:archivedViewData];
                    return (UIView *) clone;
                }
                
                return nil;
            }
        
        }
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor colorWithWhite:0. alpha:0.];
        label.text = @"";
    
        return label;
    }
    else{
        return nil;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.targetUserid) {
        UITableViewCell* cell;
        NSIndexPath* ip = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - (groupHeadType == 2 ? 1 : 0)];
        
        cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[ImageCellInStream class]]) {
            return 208;
        }
        if ([cell isKindOfClass:[ImageCellOutStream class]]) {
            return 208;
        }
        return [super tableView:tableView heightForRowAtIndexPath:ip];
    }
    else{
        CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width - 90,9999);
        
        CGSize expectedLabelSize = [[[ResponseHandler instance].broadcastList objectAtIndex:indexPath.row] sizeWithFont:[CommonMethods getStdFontType:1]
                                         constrainedToSize:maximumLabelSize
                                             lineBreakMode:NSLineBreakByWordWrapping];
        
        CGFloat sz = expectedLabelSize.height + messageInHeightOffset;
        if (sz < messageInMinHeight)
            sz = messageInMinHeight;
        return sz;
    }
}


-(void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* ip = indexPath;

    [super configureCell:cell atIndexPath:ip];
    if ([cell isKindOfClass:[MessageCellOutStream class]]) {
        MessageCellOutStream *c = (MessageCellOutStream*)cell;
        [c.headline setHidden:YES];
        
        SCBubbleViewOut* view = (SCBubbleViewOut*)(c.bubbleView);
        [view setTextColor:[UIColor blackColor]];
        if (!isGroup) {
            [view setTextOffsetTop:[NSNumber numberWithFloat:0]];
        }
        
    }
    else if ([cell isKindOfClass:[ImageCellOutStream class]]) {
        ImageCellOutStream *c = (ImageCellOutStream*)cell;
        [c.headline setHidden:YES];
    }
    else if ([cell isKindOfClass:[LocationCellOutStream class]]) {
        LocationCellOutStream *c = (LocationCellOutStream*)cell;
        [c.headline setHidden:YES];
        [c.locationAddress setTextColor:[UIColor blackColor]];
        [c.contactName setTextColor:[UIColor blackColor]];
        [c.info setTextColor:[UIColor blackColor]];
    }
    else if ([cell isKindOfClass:[AudioCellOutStream class]]) {
        AudioCellOutStream *c = (AudioCellOutStream*)cell;
        [c.headline setHidden:YES];
    }
    else if ([cell isKindOfClass:[VideoCellOutStream class]]) {
        VideoCellOutStream *c = (VideoCellOutStream*)cell;
        [c.headline setHidden:YES];
    }
    else if ([cell isKindOfClass:[FriendCellOutStream class]]) {
        FriendCellOutStream *c = (FriendCellOutStream*)cell;
        [c.headline setHidden:YES];
    }
    else if ([cell isKindOfClass:[ContactCellOutStream class]]) {
        ContactCellOutStream *c = (ContactCellOutStream*)cell;
        [c.headline setHidden:YES];
    }
    else if ([cell isKindOfClass:[CallCellOutStream class]]) {
        CallCellOutStream *c = (CallCellOutStream*)cell;
        [c.headline setHidden:YES];
    }
    
    else if ([cell isKindOfClass:[MessageCellInStream class]]) {
        MessageCellInStream *c = (MessageCellInStream*)cell;
        [c.imageNewIndicator setHidden:YES];
        [c.headline setTextColor:[UIColor blackColor]];
        [c.headline setHidden:!isGroup];
        c.headline.font = [CommonMethods getStdFontType:3];
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        c.headline.attributedText = [[NSAttributedString alloc] initWithString:c.headline.text
                                                                 attributes:underlineAttribute];
        
        SCBubbleViewIn* view = (SCBubbleViewIn*)(c.bubbleView);
        [view setTextColor:[UIColor blackColor]];
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
        c.headline.font = [CommonMethods getStdFontType:3];
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        c.headline.attributedText = [[NSAttributedString alloc] initWithString:c.headline.text
                                                                    attributes:underlineAttribute];
    }
    else if ([cell isKindOfClass:[LocationCellInStream class]]) {
        LocationCellInStream *c = (LocationCellInStream*)cell;
        [c.imageNewIndicator setHidden:YES];
        [c.headline setTextColor:[UIColor blackColor]];
        c.headline.font = [CommonMethods getStdFontType:3];
        [c.locationAddress setTextColor:[UIColor blackColor]];
        [c.locationTitle  setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [c.headline setHidden:!isGroup];
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        c.headline.attributedText = [[NSAttributedString alloc] initWithString:c.headline.text
                                                                    attributes:underlineAttribute];
    }
    else if ([cell isKindOfClass:[AudioCellInStream class]]) {
        AudioCellInStream *c = (AudioCellInStream*)cell;
        [c.imageNewIndicator setHidden:YES];
        [c.headline setTextColor:[UIColor blackColor]];
        c.headline.font = [CommonMethods getStdFontType:3];
        [c.locationAddress setTextColor:[UIColor blackColor]];
        [c.contactName setTextColor:[UIColor blackColor]];
        [c.info setTextColor:[UIColor blackColor]];
        [c.headline setHidden:!isGroup];
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        c.headline.attributedText = [[NSAttributedString alloc] initWithString:c.headline.text
                                                                    attributes:underlineAttribute];
    }
    else if ([cell isKindOfClass:[VideoCellInStream class]]) {
        VideoCellInStream *c = (VideoCellInStream*)cell;
        [c.imageNewIndicator setHidden:YES];
        [c.headline setTextColor:[UIColor blackColor]];
        c.headline.font = [CommonMethods getStdFontType:3];
        [c.headline setHidden:!isGroup];
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        c.headline.attributedText = [[NSAttributedString alloc] initWithString:c.headline.text
                                                                    attributes:underlineAttribute];
    }
    else if ([cell isKindOfClass:[FriendCellInStream class]]) {
        FriendCellInStream *c = (FriendCellInStream*)cell;
        [c.imageNewIndicator setHidden:YES];
        [c.headline setTextColor:[UIColor blackColor]];
        c.headline.font = [CommonMethods getStdFontType:3];
        [c.headline setHidden:!isGroup];
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        c.headline.attributedText = [[NSAttributedString alloc] initWithString:c.headline.text
                                                                    attributes:underlineAttribute];
    }
    else if ([cell isKindOfClass:[ContactCellInStream class]]) {
        ContactCellInStream *c = (ContactCellInStream*)cell;
        [c.imageNewIndicator setHidden:YES];
        [c.headline setTextColor:[UIColor blackColor]];
        c.headline.font = [CommonMethods getStdFontType:3];
        [c.headline setHidden:!isGroup];
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        c.headline.attributedText = [[NSAttributedString alloc] initWithString:c.headline.text
                                                                    attributes:underlineAttribute];
    }
    else if ([cell isKindOfClass:[CallCellInStream class]]) {
        CallCellInStream *c = (CallCellInStream*)cell;
        [c.imageNewIndicator setHidden:YES];
        [c.headline setTextColor:[UIColor blackColor]];
        c.headline.font = [CommonMethods getStdFontType:3];
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

-(void) configureImageCellIn:(__weak ImageCellInStream *) cell forEvent:(MOC2CallEvent *) elem atIndexPath:(NSIndexPath *) indexPath
{
    NSString *text = elem.text;
    cell.headline.text = elem.senderName?elem.senderName : [[C2CallPhone currentPhone] nameForUserid:elem.contact];
    
    cell.userImage.image = [self imageForElement:elem];
    [self setUserImageAction:cell.userImage forElement:elem];
    cell.imageNewIndicator.hidden = ![elem.missedDisplay boolValue];
    
    if ([[C2CallPhone currentPhone] hasObjectForKey:text]) {
        cell.messageImage.image = [[C2CallPhone currentPhone] imageForKey:elem.text];
        [cell.progress setHidden:YES];
        [cell setTapAction:^{
            [self showImage:text];
        }];
        
        [cell setLongpressAction:^{
            UIMenuController *menu = [UIMenuController sharedMenuController];
            NSMutableArray *menulist = [NSMutableArray arrayWithCapacity:5];
            
            UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Share", @"MenuItem") action:@selector(shareAction:)];
            [cell setShareAction:^{
                [self shareRichMessageForKey:text];
            }];
            [menulist addObject:item];
            
            item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Copy", @"MenuItem") action:@selector(copyAction:)];
            [cell setCopyAction:^{
                [self copyImageForKey:text];
            }];
            [menulist addObject:item];
            
            item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Save", @"MenuItem") action:@selector(saveAction:)];
            [cell setSaveAction:^{
                [[C2CallAppDelegate appDelegate] waitIndicatorWithTitle:NSLocalizedString(@"Saving Image to Photo Album", @"Title") andWaitMessage:nil];
                
                [[C2CallPhone currentPhone] saveToAlbum:text withCompletionHandler:^(NSURL *assetURL, NSError *error) {
                    [[C2CallAppDelegate appDelegate] waitIndicatorStop];
                }];
            }];
            [menulist addObject:item];
            
            menu.menuItems = menulist;
            CGRect rect = cell.messageImage.frame;
            rect = [cell convertRect:rect fromView:cell.messageImage];
            [menu setTargetRect:rect inView:cell];
            [cell becomeFirstResponder];
            [menu setMenuVisible:YES animated:YES];
        }];
    } else {
        if ([[C2CallPhone currentPhone] downloadStatusForKey:text]) {
            [cell.downloadButton setHidden:YES];
            [cell monitorDownloadForKey:text];
        } else if ([[C2CallPhone currentPhone] failedDownloadStatusForKey:text]) {
            // We need a broken link image here and a download button
            cell.messageImage.image = [UIImage imageNamed:@"ico_broken_image.png"];
            [cell setLongpressAction:^{
                UIMenuController *menu = [UIMenuController sharedMenuController];
                NSMutableArray *menulist = [NSMutableArray arrayWithCapacity:5];
                
                UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Retransmit", @"MenuItem") action:@selector(retransmitAction:)];
                [cell setRetransmitAction:^{
                    [cell download:nil];
                }];
                [menulist addObject:item];
                
                menu.menuItems = menulist;
                
                CGRect rect = cell.messageImage.frame;
                rect = [cell convertRect:rect fromView:cell.messageImage];
                [menu setTargetRect:rect inView:cell];
                [cell becomeFirstResponder];
                [menu setMenuVisible:YES animated:YES];
            }];
            
        } else {
            [cell startDownloadForKey:text];
        }
    }
    
}

-(void) configureImageCellOut:(__weak ImageCellOutStream *) cell forEvent:(MOC2CallEvent *) elem atIndexPath:(NSIndexPath *) indexPath
{
    cell.userImage.image = [self ownUserImage];
    [self setUserImageAction:cell.userImage forElement:elem];
    
    NSString *sendername = elem.senderName?elem.senderName : [[C2CallPhone currentPhone] nameForUserid:elem.contact];
    cell.headline.text = [NSString stringWithFormat:@"@%@",  sendername];
    
    if ([elem.eventType isEqualToString:@"MessageSubmit"]) {
        cell.messageImage.image = [[C2CallPhone currentPhone] imageForKey:elem.text];
        int status = [elem.status intValue];
        if (status == 3) {
            cell.iconSubmitted.image = [UIImage imageNamed:@"ico_notdelivered.png"];
            [cell.iconSubmitted setHidden:NO];
            
            [cell setLongpressAction:^{
                [self setRetransmitActionForCell:cell withKey:elem.text andUserid:elem.contact];
            }];
            
            return;
        }
        
        cell.iconSubmitted.image = nil;
        [cell monitorUploadForKey:elem.text];
        return;
    }
    
    NSString *text = elem.text;
    if ([[C2CallPhone currentPhone] hasObjectForKey:text]) {
        cell.messageImage.image = [[C2CallPhone currentPhone] imageForKey:text];
        [cell.progress setHidden:YES];
        [cell setTapAction:^{
            [self showImage:text];
        }];
        
        [cell setLongpressAction:^{
            UIMenuController *menu = [UIMenuController sharedMenuController];
            NSMutableArray *menulist = [NSMutableArray arrayWithCapacity:5];
            
            UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Share", @"MenuItem") action:@selector(shareAction:)];
            [cell setShareAction:^{
                [self shareRichMessageForKey:text];
            }];
            [menulist addObject:item];
            
            item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Copy", @"MenuItem") action:@selector(copyAction:)];
            [cell setCopyAction:^{
                [self copyImageForKey:text];
            }];
            [menulist addObject:item];
            
            item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Save", @"MenuItem") action:@selector(saveAction:)];
            [cell setSaveAction:^{
                [[C2CallAppDelegate appDelegate] waitIndicatorWithTitle:NSLocalizedString(@"Saving Image to Photo Album", @"Title") andWaitMessage:nil];
                
                [[C2CallPhone currentPhone] saveToAlbum:text withCompletionHandler:^(NSURL *assetURL, NSError *error) {
                    [[C2CallAppDelegate appDelegate] waitIndicatorStop];
                }];
            }];
            [menulist addObject:item];
            
            menu.menuItems = menulist;
            CGRect rect = cell.messageImage.frame;
            rect = [cell convertRect:rect fromView:cell.messageImage];
            [menu setTargetRect:rect inView:cell];
            [cell becomeFirstResponder];
            [menu setMenuVisible:YES animated:YES];
        }];
    } else {
        if ([[C2CallPhone currentPhone] downloadStatusForKey:text]) {
            [cell.downloadButton setHidden:YES];
            [cell monitorDownloadForKey:text];
        } else if ([[C2CallPhone currentPhone] failedDownloadStatusForKey:text]) {
            // We need a broken link image here and a download button
            cell.messageImage.image = [UIImage imageNamed:@"ico_broken_image.png"];
            [cell setLongpressAction:^{
                UIMenuController *menu = [UIMenuController sharedMenuController];
                NSMutableArray *menulist = [NSMutableArray arrayWithCapacity:5];
                
                UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Retransmit", @"MenuItem") action:@selector(retransmitAction:)];
                [cell setRetransmitAction:^{
                    [cell download:nil];
                }];
                [menulist addObject:item];
                
                menu.menuItems = menulist;
                
                CGRect rect = cell.messageImage.frame;
                rect = [cell convertRect:rect fromView:cell.messageImage];
                [menu setTargetRect:rect inView:cell];
                [cell becomeFirstResponder];
                [menu setMenuVisible:YES animated:YES];
            }];
            
        } else {
            [cell startDownloadForKey:text];
        }
    }
    
    [self setSubmittedStatusIcon:cell forStatus:[elem.status intValue]];
}

-(BOOL) dataDetectorAction:(MOC2CallEvent *) elem
{
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink | NSTextCheckingTypePhoneNumber error:nil];
    NSArray *matches = [detector matchesInString:elem.text
                                         options:0
                                           range:NSMakeRange(0, [elem.text length])];
    
    NSMutableArray *links = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray *numbers = [NSMutableArray arrayWithCapacity:10];
    
    for (NSTextCheckingResult *match in matches) {
        if ([match resultType] == NSTextCheckingTypeLink) {
            NSURL *url = [match URL];
            [links addObject:url];
        } else if ([match resultType] == NSTextCheckingTypePhoneNumber) {
            NSString *phoneNumber = [match phoneNumber];
            [numbers addObject:phoneNumber];
        }
    }
    
    return NO;
}

-(void) showMessagesForUser:(NSString *) userid
{
    if (!userid)
        return;
    
    UIView *responderView = [self findFirstResponder:self.view];
    [responderView resignFirstResponder];
    
}


-(void) configureMessageCellIn:(__weak MessageCellInStream *) cell forEvent:(MOC2CallEvent *) elem atIndexPath:(NSIndexPath *) indexPath
{
    NSString *text = elem.text;
    cell.userImage.image = [self imageForElement:elem];
    [self setUserImageAction:cell.userImage forElement:elem];
    
    NSString *sendername = elem.senderName?elem.senderName : [[C2CallPhone currentPhone] nameForUserid:elem.contact];
    cell.headline.text = sendername;
    
    if ([cell.bubbleView isKindOfClass:[SCBubbleViewIn class]]) {
        SCBubbleViewIn *bv = (SCBubbleViewIn *) cell.bubbleView;
        bv.chatText = text;
        bv.textFont = [CommonMethods getStdFontType:1];
        bv.textColor = cell.textfield.textColor;
        cell.textfield.hidden = YES;
    } else {
        cell.textfield.text = text;
        [cell.textfield setContentInset:UIEdgeInsetsMake(-8, 0, -8, 0)];
    }
    
    cell.imageNewIndicator.hidden = ![elem.missedDisplay boolValue];
    
    [cell setTapAction:^(){
        if (![self dataDetectorAction:elem]) {
            [self showMessagesForUser:elem.contact];
        }
    }];
    
    [cell setLongpressAction:^{
        UIMenuController *menu = [UIMenuController sharedMenuController];
        NSMutableArray *menulist = [NSMutableArray arrayWithCapacity:5];
        
        UIMenuItem *item = nil;
        item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Forward", @"MenuItem") action:@selector(forwardAction:)];
        [cell setForwardAction:^{
            [self forwardMessage:text];
        }];
        [menulist addObject:item];
        
        item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Copy", @"MenuItem") action:@selector(copyAction:)];
        [cell setCopyAction:^{
            [self copyText:text];
        }];
        [menulist addObject:item];
        
        menu.menuItems = menulist;
        CGRect rect = cell.bubbleView.frame;
        rect = [cell convertRect:rect fromView:cell.bubbleView];
        [menu setTargetRect:rect inView:cell];
        [cell becomeFirstResponder];
        [menu setMenuVisible:YES animated:YES];
    }];
    
    // Textfield size
    CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width - 90,9999);
    
    //    dispatch_async(dispatch_get_main_queue(), ^(){
    CGSize expectedLabelSize = [text sizeWithFont:self.textFieldInFont
                                constrainedToSize:maximumLabelSize
                                    lineBreakMode:NSLineBreakByWordWrapping];
    
    CGRect frame = cell.bubbleView.frame;
    CGRect inset = CGRectZero;
    if ([cell.bubbleView isKindOfClass:[SCBubbleViewIn class]]) {
        SCBubbleViewIn *bv = (SCBubbleViewIn *)cell.bubbleView;
        SCBubbleType_In t = bv.bubbleTypeIn;
        inset = [SCBubbleViewIn insetForBubbleType:t];
        
        frame.origin.x += inset.origin.x;
        frame.origin.y += inset.origin.y;
        frame.size.width -= inset.size.width;
        frame.size.height -= inset.size.height;
    }
    
    CGRect textframe = cell.textfield.frame;
    CGRect headerFrame = cell.headline.frame;
    
    CGFloat diffLeft = textframe.origin.x - frame.origin.x;
    CGFloat diffRight = frame.size.width - (diffLeft + textframe.size.width);
    CGFloat diffHeaderLeft = headerFrame.origin.x - frame.origin.x;
    CGFloat diffHeaderRight = frame.size.width - (diffHeaderLeft + headerFrame.size.width);
    
    CGFloat width = expectedLabelSize.width + diffLeft + diffRight + 16;
    
    if (sendername && cell.headline) {
        CGSize sendernameSize = [sendername sizeWithFont:self.headerFieldInFont
                                       constrainedToSize:maximumLabelSize
                                           lineBreakMode:NSLineBreakByWordWrapping];
        sendernameSize.width += diffHeaderLeft + diffHeaderRight;
        
        if (sendernameSize.width > width) {
            width = sendernameSize.width;
        }
    }
    
    if (width < 67.0)
        width = 67.0;
    
    
    if (frame.size.width != width) {
        SCBubbleViewIn *bubble = nil;
        if ([cell.bubbleView isKindOfClass:[SCBubbleViewIn class]]) {
            bubble = (SCBubbleViewIn *) cell.bubbleView;
        }
        
        frame.size.width = width;
        
        // Re-apply inset
        frame.origin.x -= inset.origin.x;
        frame.origin.y -= inset.origin.y;
        frame.size.width += inset.size.width;
        frame.size.height += inset.size.height;
        
        if (bubble.width) {
            bubble.width.constant = frame.size.width;
            bubble.left.constant = frame.origin.x;
            bubble.top.constant = frame.origin.y;
        } else {
            cell.bubbleView.frame = frame;
        }
        
        
        [cell.bubbleView layoutIfNeeded];
        [cell.bubbleView setNeedsDisplay];
        [cell setNeedsLayout];
    }
    
}


-(void) configureMessageCellOut:(__weak MessageCellOutStream *) cell forEvent:(MOC2CallEvent *) elem atIndexPath:(NSIndexPath *) indexPath
{
    NSString *text = elem.text;
    cell.userImage.image = [self ownUserImage];
    [self setUserImageAction:cell.userImage forElement:elem];
    
    NSString *sendername = elem.senderName?elem.senderName : [[C2CallPhone currentPhone] nameForUserid:elem.contact];
    sendername = [NSString stringWithFormat:@"@%@",  sendername];
    cell.headline.text = sendername;
    
    SCBubbleViewOut *bv = (SCBubbleViewOut *)[self findBubbleView:cell];
    
    if (bv) {
        bv.chatText = text;
        bv.textFont = [CommonMethods getStdFontType:1];
        bv.textColor = cell.textfield.textColor;
        cell.textfield.hidden = YES;
    } else {
        cell.textfield.text = text;
        [cell.textfield setContentInset:UIEdgeInsetsMake(-8, 0, -8, 0)];
    }
    
    
    [cell setTapAction:^(){
        if (![self dataDetectorAction:elem]) {
            [self showMessagesForUser:elem.contact];
        }
    }];
    
    [cell setLongpressAction:^{
        UIMenuController *menu = [UIMenuController sharedMenuController];
        NSMutableArray *menulist = [NSMutableArray arrayWithCapacity:5];
        
        UIMenuItem *item = nil;
        item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Forward", @"MenuItem") action:@selector(forwardAction:)];
        [cell setForwardAction:^{
            [self forwardMessage:text];
        }];
        [menulist addObject:item];
        
        item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Copy", @"MenuItem") action:@selector(copyAction:)];
        [cell setCopyAction:^{
            [self copyText:text];
        }];
        [menulist addObject:item];
        
        menu.menuItems = menulist;
        CGRect rect = cell.bubbleView.frame;
        rect = [cell convertRect:rect fromView:cell.bubbleView];
        [menu setTargetRect:rect inView:cell];
        [cell becomeFirstResponder];
        [menu setMenuVisible:YES animated:YES];
    }];
    
    // Textfield size
    CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width - 90,9999);
    
    //    dispatch_async(dispatch_get_main_queue(), ^(){
    CGSize expectedLabelSize = [text sizeWithFont:self.textFieldOutFont
                                constrainedToSize:maximumLabelSize
                                    lineBreakMode:NSLineBreakByWordWrapping];
    
    CGRect frame = cell.bubbleView.frame;
    
    CGRect inset = CGRectZero;
    if ([cell.bubbleView isKindOfClass:[SCBubbleViewOut class]]) {
        SCBubbleViewOut *bv = (SCBubbleViewOut *)cell.bubbleView;
        SCBubbleType_Out t = bv.bubbleTypeOut;
        inset = [SCBubbleViewOut insetForBubbleType:t];
        
        frame.origin.x += inset.origin.x;
        frame.origin.y += inset.origin.y;
        frame.size.width -= inset.size.width;
        frame.size.height -= inset.size.height;
    }
    
    CGRect textframe = cell.textfield.frame;
    CGRect headerFrame = cell.headline.frame;
    
    CGFloat diffLeft = textframe.origin.x - frame.origin.x;
    CGFloat diffRight = frame.size.width - (diffLeft + textframe.size.width);
    CGFloat diffHeaderLeft = headerFrame.origin.x - frame.origin.x;
    CGFloat diffHeaderRight = frame.size.width - (diffHeaderLeft + headerFrame.size.width);
    
    CGFloat width = expectedLabelSize.width + diffLeft + diffRight + 16;
    
    if (sendername && cell.headline) {
        CGSize sendernameSize = [sendername sizeWithFont:self.headerFieldOutFont
                                       constrainedToSize:maximumLabelSize
                                           lineBreakMode:NSLineBreakByWordWrapping];
        sendernameSize.width += diffHeaderLeft + diffHeaderRight;
        
        if (sendernameSize.width > width) {
            width = sendernameSize.width;
        }
    }
    
    
    //    if ([elem.missedDisplay boolValue])
    //        width += 5;
    
    if (width < 67.0)
        width = 67.0;
    
    
    CGFloat diff = frame.size.width - width;
    if (diff != .0) {
        SCBubbleViewOut *bubble = nil;
        if ([cell.bubbleView isKindOfClass:[SCBubbleViewOut class]]) {
            bubble = (SCBubbleViewOut *) cell.bubbleView;
        }
        
        frame.size.width = width;
        frame.origin.x += diff;
        
        // Re-apply inset
        frame.origin.x -= inset.origin.x;
        frame.origin.y -= inset.origin.y;
        frame.size.width += inset.size.width;
        frame.size.height += inset.size.height;
        
        if (bubble.width) {
            
            bubble.width.constant = frame.size.width;
            bubble.left.constant = frame.origin.x;
            bubble.top.constant = frame.origin.y;
        } else {
            cell.bubbleView.frame = frame;
        }
    }
    
    [self setSubmittedStatusIcon:cell forStatus:[elem.status intValue]];
}


-(void) showImage:(NSString *) key
{
    @try {
        NSMutableArray *imageList = [NSMutableArray array];
        for (MOC2CallEvent *elem in [self.fetchedResultsController fetchedObjects]) {
            if ([elem.text hasPrefix:@"image://"]) {
                NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:3];
                [info setObject:elem.text forKey:@"image"];
                [info setObject:elem.eventId forKey:@"eventId"];
                [info setObject:elem.timeStamp forKey:@"timeStamp"];
                [info setObject:elem.eventType forKey:@"eventType"];
                if (elem.senderName)
                    [info setObject:elem.senderName forKey:@"senderName"];
                
                [imageList addObject:info];
            }
        }
        
        NSString * storyboardName = @"MainStoryboard";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        WUPhotoViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"WUPhotoViewController"];
        [vc showPhotos:imageList currentPhoto:key];
        [self.navigationController pushViewController:vc animated:YES];
        
        //[self showPhotos:imageList currentPhoto:key];
        
    }
    @catch (NSException *exception) {
        
    }
}

-(UIImage *) ownUserImage
{
    UIImage *image = [self.smallImageCache objectForKey:[SCUserProfile currentUser].userid];
    if (image)
        return image;
    
    image = [[C2CallPhone currentPhone] userimageForUserid:[SCUserProfile currentUser].userid];
    if (image) {
        [self.smallImageCache setObject:image forKey:[SCUserProfile currentUser].userid];
        return image;
    }
    
    image = [UIImage imageNamed:@"btn_ico_avatar.png"];
    [self.smallImageCache setObject:image forKey:[SCUserProfile currentUser].userid];
    return image;
}


-(UIImage *) imageForElement:(MOC2CallEvent *) elem
{
    UIImage *image = [self.smallImageCache objectForKey:elem.contact];
    if (image)
        return image;
    
    image = [[C2CallPhone currentPhone] userimageForUserid:elem.contact];
    if (image) {
        [self.smallImageCache setObject:image forKey:elem.contact];
        return image;
    }
    
    if ([self isPhoneNumber:elem.contact]) {
        image = [UIImage imageNamed:@"btn_ico_adressbook_contact.png"];
        [self.smallImageCache setObject:image forKey:elem.contact];
        return image;
    }
    
    MOC2CallUser *user = [[SCDataManager instance] userForUserid:elem.contact];
    if ([user.userType intValue] == 2) {
        image = [UIImage imageNamed:@"btn_ico_avatar_group.png"];
        [self.smallImageCache setObject:image forKey:elem.contact];
        return image;
        
    }
    
    image = [UIImage imageNamed:@"btn_ico_avatar.png"];
    [self.smallImageCache setObject:image forKey:elem.contact];
    return image;
}

-(BOOL) isPhoneNumber:(NSString *) uid
{
    if ([uid hasPrefix:@"+"] && [uid rangeOfString:@"@"].location == NSNotFound) {
        return YES;
    }
    return NO;
}

- (UIView *)findBubbleView:(UIView *) startView
{
    if ([startView isKindOfClass:[SCBubbleViewIn class]] || [startView isKindOfClass:[SCBubbleViewOut class]]) {
        return startView;
    }
    
    for (UIView *subView in startView.subviews) {
        UIView *v = [self findBubbleView:subView];
        
        if (v != nil) {
            return v;
        }
    }
    
    return nil;
}

-(CGFloat) messageCellInHeight:(MOC2CallEvent *) elem font:(UIFont *) font
{
    CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width - 90,9999);
    
    CGSize expectedLabelSize = [elem.text sizeWithFont:[CommonMethods getStdFontType:1]
                                     constrainedToSize:maximumLabelSize
                                         lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat sz = expectedLabelSize.height + messageInHeightOffset;
    if (sz < messageInMinHeight)
        sz = messageInMinHeight;
    
    return sz;
}

-(CGFloat) messageCellOutHeight:(MOC2CallEvent *) elem font:(UIFont *) font
{
    CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width - 90,9999);
    
    CGSize expectedLabelSize = [elem.text sizeWithFont:[CommonMethods getStdFontType:1]
                                     constrainedToSize:maximumLabelSize
                                         lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat sz = expectedLabelSize.height + messageOutHeightOffset;
    if (sz < messageOutMinHeight)
        sz = messageOutMinHeight;
    
    
    return sz;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.targetUserid) {
        NSIndexPath* ip = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - (groupHeadType == 2 ? 1 : 0)];
        UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:ip];
        
        MOC2CallEvent *elem = nil;
        @try {
            elem = [self.fetchedResultsController objectAtIndexPath:ip];
            [[SCDataManager instance] markAsRead:elem];
        }
        @catch (NSException *exception) {
        }
        return cell;
    }
    else{
        MessageCellInStream* cell = [self.tableView dequeueReusableCellWithIdentifier:@"MessageCellInStream"];
        NSString *text = [[ResponseHandler instance].broadcastList objectAtIndex:indexPath.row];
        cell.userImage.image = nil;
        cell.headline.text = @"";
        
        if ([cell.bubbleView isKindOfClass:[SCBubbleViewIn class]]) {
            SCBubbleViewIn *bv = (SCBubbleViewIn *) cell.bubbleView;
            bv.chatText = text;
            bv.textFont = [CommonMethods getStdFontType:1];
            bv.textColor = cell.textfield.textColor;
            cell.textfield.hidden = YES;
        } else {
            cell.textfield.text = text;
            [cell.textfield setContentInset:UIEdgeInsetsMake(-8, 0, -8, 0)];
        }
        
        cell.imageNewIndicator.hidden = YES;
        
        // Textfield size
        CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width - 90,9999);
        
        //    dispatch_async(dispatch_get_main_queue(), ^(){
        CGSize expectedLabelSize = [text sizeWithFont:self.textFieldInFont
                                    constrainedToSize:maximumLabelSize
                                        lineBreakMode:NSLineBreakByWordWrapping];
        
        CGRect frame = cell.bubbleView.frame;
        CGRect inset = CGRectZero;
        if ([cell.bubbleView isKindOfClass:[SCBubbleViewIn class]]) {
            SCBubbleViewIn *bv = (SCBubbleViewIn *)cell.bubbleView;
            SCBubbleType_In t = bv.bubbleTypeIn;
            inset = [SCBubbleViewIn insetForBubbleType:t];
            
            frame.origin.x += inset.origin.x;
            frame.origin.y += inset.origin.y;
            frame.size.width -= inset.size.width;
            frame.size.height -= inset.size.height;
        }
        
        CGRect textframe = cell.textfield.frame;
        CGRect headerFrame = cell.headline.frame;
        
        CGFloat diffLeft = textframe.origin.x - frame.origin.x;
        CGFloat diffRight = frame.size.width - (diffLeft + textframe.size.width);
        CGFloat diffHeaderLeft = headerFrame.origin.x - frame.origin.x;
        CGFloat diffHeaderRight = frame.size.width - (diffHeaderLeft + headerFrame.size.width);
        
        CGFloat width = expectedLabelSize.width + diffLeft + diffRight + 16;
        
        if (cell.headline) {
            CGSize sendernameSize = [@"Admin" sizeWithFont:self.headerFieldInFont
                                           constrainedToSize:maximumLabelSize
                                               lineBreakMode:NSLineBreakByWordWrapping];
            sendernameSize.width += diffHeaderLeft + diffHeaderRight;
            
            if (sendernameSize.width > width) {
                width = sendernameSize.width;
            }
        }
        
        if (width < 67.0)
            width = 67.0;
        
        
        if (frame.size.width != width) {
            SCBubbleViewIn *bubble = nil;
            if ([cell.bubbleView isKindOfClass:[SCBubbleViewIn class]]) {
                bubble = (SCBubbleViewIn *) cell.bubbleView;
            }
            
            frame.size.width = width;
            
            // Re-apply inset
            frame.origin.x -= inset.origin.x;
            frame.origin.y -= inset.origin.y;
            frame.size.width += inset.size.width;
            frame.size.height += inset.size.height;
            
            if (bubble.width) {
                bubble.width.constant = frame.size.width;
                bubble.left.constant = frame.origin.x;
                bubble.top.constant = frame.origin.y;
            } else {
                cell.bubbleView.frame = frame;
            }
            
            
            [cell.bubbleView layoutIfNeeded];
            [cell.bubbleView setNeedsDisplay];
            [cell setNeedsLayout];
        }
        
        MessageCellInStream *c = (MessageCellInStream*)cell;
        [c.imageNewIndicator setHidden:YES];
        [c.headline setTextColor:[UIColor blackColor]];
        [c.headline setHidden:!isGroup];
        c.headline.font = [CommonMethods getStdFontType:3];
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        c.headline.attributedText = [[NSAttributedString alloc] initWithString:c.headline.text
                                                                    attributes:underlineAttribute];
        
        SCBubbleViewIn* view = (SCBubbleViewIn*)(c.bubbleView);
        [view setTextColor:[UIColor blackColor]];
        if (!isGroup) {
            [view setTextOffsetTop:[NSNumber numberWithFloat:0]];
        }
        
        return cell;
        
    }
    

    
}


@end
