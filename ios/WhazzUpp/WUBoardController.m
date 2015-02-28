//
//  WUBoardController.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 30/8/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
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
#import <SocialCommunication/FCLocation.h>

#import "CommonMethods.h"
#import "WUPhotoViewController.h"


@implementation WUCreateGroupCell
@synthesize nameLabel, timeLabel, sectiontimeLabel, sectiontimeview, showPreviousMsgView, createGroupView;
@end


@implementation WUMessageInCell
@synthesize textLabel, timeLabel, shadowImage;
@end

@implementation WUMessageOutCell
@synthesize textLabel, timeLabel, shadowImage;
@end

@implementation WUImageInCell
@synthesize eventImage;
@end

@implementation WUImageOutCell
@synthesize eventImage, shadowImage;
@end

@implementation WULocationInCell
@synthesize timeLabel;
@end

@implementation WUAudioInCell
@synthesize timeLabel;
@end

@implementation WUVideoInCell
@synthesize timeLabel;
@end

@implementation WUContactInCell
@synthesize timeLabel;
@end

@implementation WUFriendInCell
@synthesize timeLabel;
@end

@implementation WUCallInCell
@synthesize timeLabel;
@end

@implementation WULocationOutCell
@synthesize shadowImage;
@end

@implementation WUAudioOutCell
@synthesize shadowImage;
@end

@implementation WUVideoOutCell
@synthesize shadowImage;
@end

@implementation WUContactOutCell
@synthesize shadowImage;
@end

@implementation WUFriendOutCell
@synthesize shadowImage;
@end

@implementation WUCallOutCell
@synthesize shadowImage;
@end



@interface WUBoardController (){
    int groupHeadType;
    NSMutableArray* friendList;
    BOOL isVisible;
}

@property (nonatomic, strong) NSMutableDictionary  *smallImageCache;
@property (nonatomic, strong) UIFont *textFieldInFont, *headerFieldInFont, *textFieldOutFont, *headerFieldOutFont;
@end


@implementation WUBoardController
@synthesize smallImageCache, textFieldInFont, textFieldOutFont, headerFieldInFont, headerFieldOutFont;

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
    groupHeadType = 0;
    friendList = [ResponseHandler instance].friendList;
    
}

-(void) viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.translucent = NO;
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
    if (self.targetUserid && [[self.fetchedResultsController fetchedObjects] count] > 0) {
        return [[self.fetchedResultsController sections] count];
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
            
            id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
            return [sectionInfo numberOfObjects];
        }
    }
    else{
        return [ResponseHandler instance].broadcastList.count;
    }
}







- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    [super tableView:tableView heightForHeaderInSection:section];
    if(self.targetUserid){
        CGFloat h = 0.;
        if (isGroup && section == 0) {
            h += 72;
        }
        if (section == 0 && !self.previousMessagesButton.hidden) {
            h += 40;
        }
        if ([[self.fetchedResultsController fetchedObjects] count] > 0) {
            h += 28;
        }
        return h;
    }
    else{
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if(self.targetUserid){
        WUCreateGroupCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"WUCreateGroupCell"];
        CGFloat h = 0;
        CGRect f;
        
        if (isGroup && section == 0) {
            cell.createGroupView.hidden = NO;
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
            NSDate* createTime;
            NSMutableArray* groups = [[ResponseHandler instance] groupList];
            for (int i = 0; i < groups.count; i++) {
                WUAccount* a = [groups objectAtIndex:i];
                if ([a.c2CallID isEqualToString:self.targetUserid]) {
                    groupName = a.name;
                    createTime = a.createTime;
                }
            }
            
            if (createTime) {
                NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"MMMM d HH:mm" options:0
                                                                          locale:[NSLocale currentLocale]];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
                [dateFormatter setDateFormat:formatString];
                cell.timeLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:createTime]];
            }
            
            cell.nameLabel.text = [NSString stringWithFormat:@"%@ created a group %@", ownerName, groupName];
            
            f = cell.createGroupView.frame;
            f.origin.x = (self.view.frame.size.width - f.size.width) / 2;
            cell.createGroupView.frame = f;
            
            h += 72.;
        }
        else{
            cell.createGroupView.hidden = YES;
        }
        
        if (section == 0 && !self.previousMessagesButton.hidden) {
            cell.showPreviousMsgView.hidden = NO;
            f = cell.showPreviousMsgView.frame;
            f.origin.x = (self.view.frame.size.width - f.size.width) / 2;
            f.origin.y = h;
            cell.showPreviousMsgView.frame = f;
            h += 40.;
        }
        else{
            cell.showPreviousMsgView.hidden = YES;
        }
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
        MOC2CallEvent *elem = nil;
        @try {
            elem = [self.fetchedResultsController objectAtIndexPath:indexPath];
        }
        @catch (NSException *exception) {
        }
        
        NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"MMMM d HH:mm" options:0
                                                                  locale:[NSLocale currentLocale]];
        if (elem) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:formatString];
            cell.sectiontimeLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:elem.timeStamp]];
            cell.sectiontimeview.hidden = NO;
            
            f = cell.sectiontimeview.frame;
            f.origin.x = (self.view.frame.size.width - f.size.width) / 2;
            f.origin.y = h;
            cell.sectiontimeview.frame = f;
        }
        else{
            cell.sectiontimeview.hidden = YES;
        }
        return cell;
        
        
    }
    else{
        return nil;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.targetUserid) {
        UITableViewCell* cell;
        NSIndexPath* ip = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
        
        cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[ImageCellInStream class]]) {
            return 228;
        }
        if ([cell isKindOfClass:[ImageCellOutStream class]]) {
            return 228;
        }
        if ([cell isKindOfClass:[LocationCellIn class]]) {
            return 152;
        }
        if ([cell isKindOfClass:[LocationCellOut class]]) {
            return 152;
        }
        if ([cell isKindOfClass:[AudioCellIn class]]) {
            return 132;
        }
        if ([cell isKindOfClass:[AudioCellOut class]]) {
            return 132;
        }
        if ([cell isKindOfClass:[VideoCellIn class]]) {
            return 133;
        }
        if ([cell isKindOfClass:[VideoCellOut class]]) {
            return 133;
        }
        if ([cell isKindOfClass:[FriendCellIn class]]) {
            return 121;
        }
        if ([cell isKindOfClass:[FriendCellOut class]]) {
            return 121;
        }
        if ([cell isKindOfClass:[ContactCellIn class]]) {
            return 111;
        }
        if ([cell isKindOfClass:[ContactCellOut class]]) {
            return 111;
        }
        if ([cell isKindOfClass:[CallCellIn class]]) {
            return 105;
        }
        if ([cell isKindOfClass:[CallCellOut class]]) {
            return 105;
        }
        
        return [super tableView:tableView heightForRowAtIndexPath:ip];
    }
    else{
        WUBroadcast* b = [[ResponseHandler instance].broadcastList objectAtIndex:indexPath.row];
                             
        if(b.isImage){
            return 228;
        }
        else{
            CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width - 120,9999);
            CGSize expectedLabelSize = [b.message sizeWithFont:[CommonMethods getStdFontType:1]
                                             constrainedToSize:maximumLabelSize
                                                 lineBreakMode:NSLineBreakByWordWrapping];
            
            CGFloat sz = expectedLabelSize.height + 48;
            return sz;
        }
    }
}


-(void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* ip = indexPath;
    MOC2CallEvent *elem = [self.fetchedResultsController objectAtIndexPath:ip];

    [[cell viewWithTag:1000] removeFromSuperview];

    [super configureCell:cell atIndexPath:ip];
    
    
    NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"hh:mm a" options:0
                                                              locale:[NSLocale currentLocale]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatString];
    
    if ([cell isKindOfClass:[WULocationOutCell class]]) {
        WULocationOutCell *c = (WULocationOutCell*)cell;
        [c.headline setHidden:YES];
        [c.locationAddress setTextColor:[UIColor blackColor]];
        [c.contactName setTextColor:[UIColor blackColor]];
        [c.info setTextColor:[UIColor blackColor]];
        [c.locationTitle setTitle:NSLocalizedString(@"Current location", @"") forState:UIControlStateNormal];
        
        CGRect frame = c.bubbleView.frame;
        frame.origin.x = self.view.frame.size.width - frame.size.width;
        [c.bubbleView setFrame:frame];
        
        frame = c.shadowImage.frame;
        frame.origin.x = c.bubbleView.frame.origin.x + 8;
        [c.shadowImage setFrame:frame];
        c.timeLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:elem.timeStamp]];
        
    }
    else if ([cell isKindOfClass:[WUAudioOutCell class]]) {
        WUAudioOutCell *c = (WUAudioOutCell*)cell;
        [c.headline setHidden:YES];

        CGRect frame = c.bubbleView.frame;
        frame.origin.x = self.view.frame.size.width - frame.size.width;
        [c.bubbleView setFrame:frame];
        
        frame = c.shadowImage.frame;
        frame.origin.x = c.bubbleView.frame.origin.x + 8;
        [c.shadowImage setFrame:frame];
        c.timeLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:elem.timeStamp]];
        
    }
    else if ([cell isKindOfClass:[WUVideoOutCell class]]) {
        WUVideoOutCell *c = (WUVideoOutCell*)cell;
        [c.headline setHidden:YES];
        
        CGRect frame = c.bubbleView.frame;
        frame.origin.x = self.view.frame.size.width - frame.size.width;
        [c.bubbleView setFrame:frame];
        
        frame = c.shadowImage.frame;
        frame.origin.x = c.bubbleView.frame.origin.x + 8;
        [c.shadowImage setFrame:frame];
        c.timeLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:elem.timeStamp]];
        
    }
    else if ([cell isKindOfClass:[WUFriendOutCell class]]) {
        WUFriendOutCell *c = (WUFriendOutCell*)cell;
        [c.headline setHidden:YES];
        
        CGRect frame = c.bubbleView.frame;
        frame.origin.x = self.view.frame.size.width - frame.size.width;
        [c.bubbleView setFrame:frame];
        
        frame = c.shadowImage.frame;
        frame.origin.x = c.bubbleView.frame.origin.x + 8;
        [c.shadowImage setFrame:frame];
        c.timeLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:elem.timeStamp]];
        
    }
    else if ([cell isKindOfClass:[WUContactOutCell class]]) {
        WUContactOutCell *c = (WUContactOutCell*)cell;
        [c.headline setHidden:YES];
        
        CGRect frame = c.bubbleView.frame;
        frame.origin.x = self.view.frame.size.width - frame.size.width;
        [c.bubbleView setFrame:frame];
        
        frame = c.shadowImage.frame;
        frame.origin.x = c.bubbleView.frame.origin.x + 8;
        [c.shadowImage setFrame:frame];
        c.timeLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:elem.timeStamp]];
        
    }
    else if ([cell isKindOfClass:[WUCallOutCell class]]) {
        WUCallOutCell *c = (WUCallOutCell*)cell;
        [c.headline setHidden:YES];
        
        CGRect frame = c.bubbleView.frame;
        frame.origin.x = self.view.frame.size.width - frame.size.width;
        [c.bubbleView setFrame:frame];
        
        frame = c.shadowImage.frame;
        frame.origin.x = c.bubbleView.frame.origin.x + 8;
        [c.shadowImage setFrame:frame];
        c.timeLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:elem.timeStamp]];
        
    }
    else if ([cell isKindOfClass:[WULocationInCell class]]) {
        WULocationInCell *c = (WULocationInCell*)cell;
        [c.imageNewIndicator setHidden:YES];
        [c.headline setTextColor:[UIColor blackColor]];
        c.headline.font = [CommonMethods getStdFontType:3];
        [c.locationAddress setTextColor:[UIColor blackColor]];
        [c.locationTitle  setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [c.locationTitle setTitle:NSLocalizedString(@"Current location", @"") forState:UIControlStateNormal];
        [c.headline setHidden:!isGroup];
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        c.headline.attributedText = [[NSAttributedString alloc] initWithString:c.headline.text
                                                                    attributes:underlineAttribute];
        c.timeLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:elem.timeStamp]];
    }
    else if ([cell isKindOfClass:[WUAudioInCell class]]) {
        WUAudioInCell *c = (WUAudioInCell*)cell;
        [c.imageNewIndicator setHidden:YES];
        [c.headline setTextColor:[UIColor blackColor]];
        c.headline.font = [CommonMethods getStdFontType:3];
        [c.locationAddress setTextColor:[UIColor blackColor]];
        [c.contactName setTextColor:[UIColor blackColor]];
        [c.info setTextColor:[UIColor blackColor]];
        [c.headline setHidden:!isGroup];
        [c.downloadButton setTitle:NSLocalizedString(@"Download", @"") forState:UIControlStateNormal];
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        c.headline.attributedText = [[NSAttributedString alloc] initWithString:c.headline.text
                                                                    attributes:underlineAttribute];
        c.timeLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:elem.timeStamp]];
    }
    else if ([cell isKindOfClass:[WUVideoInCell class]]) {
        WUVideoInCell *c = (WUVideoInCell*)cell;
        [c.imageNewIndicator setHidden:YES];
        [c.headline setTextColor:[UIColor blackColor]];
        c.headline.font = [CommonMethods getStdFontType:3];
        [c.headline setHidden:!isGroup];
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        c.headline.attributedText = [[NSAttributedString alloc] initWithString:c.headline.text
                                                                    attributes:underlineAttribute];
        c.timeLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:elem.timeStamp]];
    }
    else if ([cell isKindOfClass:[WUFriendInCell class]]) {
        WUFriendInCell *c = (WUFriendInCell*)cell;
        [c.imageNewIndicator setHidden:YES];
        [c.headline setTextColor:[UIColor blackColor]];
        c.headline.font = [CommonMethods getStdFontType:3];
        [c.headline setHidden:!isGroup];
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        c.headline.attributedText = [[NSAttributedString alloc] initWithString:c.headline.text
                                                                    attributes:underlineAttribute];
        c.timeLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:elem.timeStamp]];
    }
    else if ([cell isKindOfClass:[WUContactInCell class]]) {
        WUContactInCell *c = (WUContactInCell*)cell;
        [c.imageNewIndicator setHidden:YES];
        [c.headline setTextColor:[UIColor blackColor]];
        c.headline.font = [CommonMethods getStdFontType:3];
        [c.headline setHidden:!isGroup];
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        c.headline.attributedText = [[NSAttributedString alloc] initWithString:c.headline.text
                                                                    attributes:underlineAttribute];
        c.timeLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:elem.timeStamp]];
    }
    else if ([cell isKindOfClass:[WUCallInCell class]]) {
        WUCallInCell *c = (WUCallInCell*)cell;
        [c.imageNewIndicator setHidden:YES];
        [c.headline setTextColor:[UIColor blackColor]];
        c.headline.font = [CommonMethods getStdFontType:3];
        [c.headline setHidden:!isGroup];
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        c.headline.attributedText = [[NSAttributedString alloc] initWithString:c.headline.text
                                                                    attributes:underlineAttribute];
        c.timeLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:elem.timeStamp]];
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

-(void) configureImageCellIn:(__weak WUImageInCell *) cell forEvent:(MOC2CallEvent *) elem atIndexPath:(NSIndexPath *) indexPath
{
    NSString *text = elem.text;
    if ([[C2CallPhone currentPhone] hasObjectForKey:text]) {
        cell.eventImage.image = [[C2CallPhone currentPhone] imageForKey:elem.text];
        
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
            CGRect rect = cell.bubbleView.frame;
            rect = [cell convertRect:rect fromView:cell.bubbleView];
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
                
                CGRect rect = cell.bubbleView.frame;
                rect = [cell convertRect:rect fromView:cell.bubbleView];
                [menu setTargetRect:rect inView:cell];
                [cell becomeFirstResponder];
                [menu setMenuVisible:YES animated:YES];
            }];
            
        } else {
            [cell startDownloadForKey:text];
        }
    }
    
}

-(void) configureImageCellOut:(__weak WUImageOutCell *) cell forEvent:(MOC2CallEvent *) elem atIndexPath:(NSIndexPath *) indexPath
{
    NSString *text = elem.text;
    
    CGRect frame = cell.bubbleView.frame;
    frame.origin.x = self.view.frame.size.width - frame.size.width;
    [cell.bubbleView setFrame:frame];
    
    frame = cell.shadowImage.frame;
    frame.origin.x = cell.bubbleView.frame.origin.x + 8;
    [cell.shadowImage setFrame:frame];
    
    if ([elem.eventType isEqualToString:@"MessageSubmit"]) {
        cell.eventImage.image = [[C2CallPhone currentPhone] imageForKey:elem.text];
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
    
    if ([[C2CallPhone currentPhone] hasObjectForKey:text]) {
        cell.eventImage.image = [[C2CallPhone currentPhone] imageForKey:text];
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

            item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete", @"MenuItem") action:@selector(answerAction:)];
            [cell setAnswerAction:^{
                [[SCDataManager instance] removeDatabaseObject:elem];
            }];
            [menulist addObject:item];
            
            menu.menuItems = menulist;
            CGRect rect = cell.bubbleView.frame;
            rect = [cell convertRect:rect fromView:cell.bubbleView];
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
                
                item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete", @"MenuItem") action:@selector(answerAction:)];
                [cell setAnswerAction:^{
                    [[SCDataManager instance] removeDatabaseObject:elem];
                }];
                [menulist addObject:item];
                
                [menulist addObject:item];
                
                menu.menuItems = menulist;
                
                CGRect rect = cell.bubbleView.frame;
                rect = [cell convertRect:rect fromView:cell.bubbleView];
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


-(void) configureMessageCellIn:(__weak WUMessageInCell *) cell forEvent:(MOC2CallEvent *) elem atIndexPath:(NSIndexPath *) indexPath
{
    NSString *text = elem.text;
    [cell.textLabel setText:text];
    [cell.textLabel setFont:[CommonMethods getStdFontType:1]];

    // Textfield size
    CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width - 120,9999);
    CGSize expectedLabelSize = [text sizeWithFont:[CommonMethods getStdFontType:1]
                                constrainedToSize:maximumLabelSize
                                    lineBreakMode:NSLineBreakByWordWrapping];
    CGRect frame = CGRectMake(0, 8, expectedLabelSize.width + 90, expectedLabelSize.height + 20);
    [cell.bubbleView setFrame:frame];
    
    frame = CGRectMake(12, 8, expectedLabelSize.width, expectedLabelSize.height);
    [cell.textLabel setFrame:frame];

    frame = CGRectMake(12, expectedLabelSize.height, expectedLabelSize.width + 74, 30);
    [cell.shadowImage setFrame:frame];

    
    NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"hh:mm a" options:0
                                                              locale:[NSLocale currentLocale]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatString];
    cell.timeLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:elem.timeStamp]];
    frame = CGRectMake(expectedLabelSize.width + 10, expectedLabelSize.height - 14, 64, 21);
    [cell.timeLabel setFrame:frame];
    
    
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
    

    
}


-(void) configureMessageCellOut:(__weak WUMessageOutCell *) cell forEvent:(MOC2CallEvent *) elem atIndexPath:(NSIndexPath *) indexPath
{
    NSString *text = elem.text;
    [cell.textLabel setText:text];
    [cell.textLabel setFont:[CommonMethods getStdFontType:1]];
    
    // Textfield size
    CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width - 120,9999);
    CGSize expectedLabelSize = [text sizeWithFont:[CommonMethods getStdFontType:1]
                                constrainedToSize:maximumLabelSize
                                    lineBreakMode:NSLineBreakByWordWrapping];
    CGRect frame = CGRectMake(self.view.frame.size.width - expectedLabelSize.width - 90, 8, expectedLabelSize.width + 90, expectedLabelSize.height + 20);
    [cell.bubbleView setFrame:frame];
    
    frame = CGRectMake(8, 8, expectedLabelSize.width, expectedLabelSize.height);
    [cell.textLabel setFrame:frame];
    
    frame = CGRectMake(self.view.frame.size.width - expectedLabelSize.width - 90 + 8, expectedLabelSize.height, expectedLabelSize.width + 74, 30);
    [cell.shadowImage setFrame:frame];

    NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"hh:mm a" options:0
                                                              locale:[NSLocale currentLocale]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatString];
    cell.timeLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:elem.timeStamp]];
    frame = CGRectMake(expectedLabelSize.width + 6, expectedLabelSize.height - 14, 64, 21);
    [cell.timeLabel setFrame:frame];
    
    frame = CGRectMake(expectedLabelSize.width + 20 - 14 - 4, 0, 14, 14);
    [cell.iconSubmitted setFrame:frame];
    
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
        
        item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete", @"MenuItem") action:@selector(answerAction:)];
        [cell setAnswerAction:^{
            [[SCDataManager instance] removeDatabaseObject:elem];
        }];
        [menulist addObject:item];
        
        
        menu.menuItems = menulist;
        CGRect rect = cell.bubbleView.frame;
        rect = [cell convertRect:rect fromView:cell.bubbleView];
        [menu setTargetRect:rect inView:cell];
        [cell becomeFirstResponder];
        [menu setMenuVisible:YES animated:YES];
    }];
    
    [self setSubmittedStatusIcon:cell forStatus:[elem.status intValue]];
    
}


-(void) configureVideoCellOut:(__weak VideoCellOutStream *) cell forEvent:(MOC2CallEvent *) elem atIndexPath:(NSIndexPath *) indexPath
{
    NSString *text = elem.text;
    
    cell.userImage.image = [self ownUserImage];
    [self setUserImageAction:cell.userImage forElement:elem];
    
    NSString *sendername = elem.senderName?elem.senderName : [[C2CallPhone currentPhone] nameForUserid:elem.contact];
    cell.headline.text = [NSString stringWithFormat:@"@%@",  sendername];
    
    // Special Handling for current submissions
    if ([elem.eventType isEqualToString:@"MessageSubmit"]) {
        cell.messageImage.image = [[C2CallPhone currentPhone] thumbnailForKey:text];
        cell.duration.text = [[C2CallPhone currentPhone] durationForKey:text];
        
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
        [cell monitorUploadForKey:text];
        return;
    }
    
    BOOL failed = NO, hasVideo = NO;
    if ([[C2CallPhone currentPhone] downloadStatusForKey:text]) {
        hasVideo = YES;
        cell.messageImage.image = [[C2CallPhone currentPhone] thumbnailForKey:text];
        cell.duration.text = [[C2CallPhone currentPhone] durationForKey:text];
        
        [cell.progress setHidden:YES];
    } else {
        UIImage *thumb = [[C2CallPhone currentPhone] thumbnailForKey:text];
        
        if (thumb) {
            cell.messageImage.image = thumb;
            cell.duration.text = [[C2CallPhone currentPhone] durationForKey:text];
        }
        
        cell.downloadKey = text;
        
        if ([[C2CallPhone currentPhone] downloadStatusForKey:text]) {
            [cell.downloadButton setHidden:YES];
            [cell monitorDownloadForKey:text];
        } else if ([[C2CallPhone currentPhone] failedDownloadStatusForKey:text]) {
            // We need a broken link image here and a download button
            cell.messageImage.image = [UIImage imageNamed:@"ico_video.png"];
            [cell.downloadButton setHidden:YES];
            [cell setLongpressAction:^{
                UIMenuController *menu = [UIMenuController sharedMenuController];
                NSMutableArray *menulist = [NSMutableArray arrayWithCapacity:5];
                
                UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Retransmit", @"MenuItem") action:@selector(retransmitAction:)];
                [cell setRetransmitAction:^{
                    [cell download:nil];
                }];
                [menulist addObject:item];
                
                item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete", @"MenuItem") action:@selector(answerAction:)];
                [cell setAnswerAction:^{
                    [[SCDataManager instance] removeDatabaseObject:elem];
                }];
                [menulist addObject:item];
                
                menu.menuItems = menulist;
                
                CGRect rect = cell.bubbleView.frame;
                rect = [cell convertRect:rect fromView:cell.bubbleView];
                [menu setTargetRect:rect inView:cell];
                [cell becomeFirstResponder];
                [menu setMenuVisible:YES animated:YES];
            }];
            failed = YES;
        } else {
            if (!thumb) {
                [cell retrieveVideoThumbnailForKey:text];
            } else {
                [cell.downloadButton setHidden:NO];
            }
            [cell.progress setHidden:YES];
        }
    }
    
    if (!failed) {
        [cell setTapAction:^{
            [self showVideo:text];
        }];
        
        [cell setLongpressAction:^{
            UIMenuController *menu = [UIMenuController sharedMenuController];
            NSMutableArray *menulist = [NSMutableArray arrayWithCapacity:5];
            
            UIMenuItem *item = nil;
            if (hasVideo) {
                item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Share", @"MenuItem") action:@selector(shareAction:)];
                [cell setShareAction:^{
                    [self shareRichMessageForKey:text];
                }];
                
                [menulist addObject:item];
                
                
                /*
                 item = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(copyAction:)];
                 [cell setCopyAction:^{
                 [self copyMovieForKey:text];
                 }];
                 [menulist addObject:item];
                 
                 */
                
                item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Save", @"MenuItem") action:@selector(saveAction:)];
                [cell setSaveAction:^{
                    [[C2CallAppDelegate appDelegate] waitIndicatorWithTitle:NSLocalizedString(@"Saving Video to Photo Album", @"Title") andWaitMessage:nil];
                    
                    [[C2CallPhone currentPhone] saveToAlbum:text withCompletionHandler:^(NSURL *assetURL, NSError *error) {
                        [[C2CallAppDelegate appDelegate] waitIndicatorStop];
                    }];
                }];
                [menulist addObject:item];
                
            } else {
                item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Retrieve", @"MenuItem") action:@selector(retransmitAction:)];
                [cell setRetransmitAction:^{
                    [cell download:nil];
                }];
                [menulist addObject:item];
                
            }
            
            item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete", @"MenuItem") action:@selector(answerAction:)];
            [cell setAnswerAction:^{
                [[SCDataManager instance] removeDatabaseObject:elem];
            }];
            [menulist addObject:item];
            
            menu.menuItems = menulist;
            CGRect rect = cell.bubbleView.frame;
            rect = [cell convertRect:rect fromView:cell.bubbleView];
            [menu setTargetRect:rect inView:cell];
            [cell becomeFirstResponder];
            [menu setMenuVisible:YES animated:YES];
        }];
    }
    
    [self setSubmittedStatusIcon:cell forStatus:[elem.status intValue]];
}


-(void) configureLocationCellOut:(__weak LocationCellOutStream *) cell forEvent:(MOC2CallEvent *) elem atIndexPath:(NSIndexPath *) indexPath
{
    NSString *text = elem.text;
    
    cell.userImage.image = [self ownUserImage];
    [self setUserImageAction:cell.userImage forElement:elem];
    
    NSString *sendername = elem.senderName?elem.senderName : [[C2CallPhone currentPhone] nameForUserid:elem.contact];
    cell.headline.text = [NSString stringWithFormat:@"@%@",  sendername];
    
    FCLocation *loc = [[FCLocation alloc] initWithKey:text];
    [cell retrieveLocation:loc];
    
    [cell setOpenLocationAction:^{
        if (cell.locationUrl) {
            NSString *name = [loc.place objectForKey:@"name"];
            [self openBrowserWithUrl:cell.locationUrl andTitle:name];
        }
    }];
    
    
    [cell setTapAction:^{
        [self showLocation:text forUser:NSLocalizedString(@"Me", "Title")];
    }];
    
    [cell setLongpressAction:^{
        UIMenuController *menu = [UIMenuController sharedMenuController];
        NSMutableArray *menulist = [NSMutableArray arrayWithCapacity:5];
        
        UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Forward", @"MenuItem") action:@selector(forwardAction:)];
        [cell setForwardAction:^{
            [self forwardMessage:text];
        }];
        [menulist addObject:item];
        
        
        item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Copy", @"MenuItem") action:@selector(copyAction:)];
        [cell setCopyAction:^{
            [self copyLocationForKey:text];
        }];
        [menulist addObject:item];
        
        item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete", @"MenuItem") action:@selector(answerAction:)];
        [cell setAnswerAction:^{
            [[SCDataManager instance] removeDatabaseObject:elem];
        }];
        [menulist addObject:item];
        
        menu.menuItems = menulist;
        CGRect rect = cell.bubbleView.frame;
        rect = [cell convertRect:rect fromView:cell.bubbleView];
        [menu setTargetRect:rect inView:cell];
        [cell becomeFirstResponder];
        [menu setMenuVisible:YES animated:YES];
    }];
    
    [self setSubmittedStatusIcon:cell forStatus:[elem.status intValue]];
}


-(void) configureAudioCellOut:(__weak AudioCellOutStream *) cell forEvent:(MOC2CallEvent *) elem atIndexPath:(NSIndexPath *) indexPath
{
    NSString *text = elem.text;
    
    cell.userImage.image = [self ownUserImage];
    [self setUserImageAction:cell.userImage forElement:elem];
    
    NSString *sendername = elem.senderName?elem.senderName : [[C2CallPhone currentPhone] nameForUserid:elem.contact];
    cell.headline.text = [NSString stringWithFormat:@"@%@",  sendername];
    
    // Special Handling for current submissions
    if ([elem.eventType isEqualToString:@"MessageSubmit"]) {
        cell.duration.text = [[C2CallPhone currentPhone] durationForKey:text];
        
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
        [cell monitorUploadForKey:text];
        return;
    }
    
    BOOL failed = NO, hasAudio = NO;
    
    if ([[C2CallPhone currentPhone] hasObjectForKey:text]) {
        hasAudio = YES;
        cell.duration.text = [[C2CallPhone currentPhone] durationForKey:text];
        
        [cell.progress setHidden:YES];
        [cell setTapAction:^{
            [self showVoiceMail:text];
        }];
    } else {
        cell.downloadKey = text;
        
        if ([[C2CallPhone currentPhone] downloadStatusForKey:text]) {
            [cell.downloadButton setHidden:YES];
            [cell monitorDownloadForKey:text];
        } else if ([[C2CallPhone currentPhone] failedDownloadStatusForKey:text]) {
            // We need a broken link image here and a download button
            cell.messageImage.image = [UIImage imageNamed:@"ico_broken_voice_msg.png"];
            [cell.downloadButton setHidden:YES];
            [cell setLongpressAction:^{
                UIMenuController *menu = [UIMenuController sharedMenuController];
                NSMutableArray *menulist = [NSMutableArray arrayWithCapacity:5];
                
                UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Retransmit", @"MenuItem") action:@selector(retransmitAction:)];
                [cell setRetransmitAction:^{
                    [cell download:nil];
                }];
                [menulist addObject:item];
                
                item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete", @"MenuItem") action:@selector(answerAction:)];
                [cell setAnswerAction:^{
                    [[SCDataManager instance] removeDatabaseObject:elem];
                }];
                [menulist addObject:item];
                
                menu.menuItems = menulist;
                
                CGRect rect = cell.bubbleView.frame;
                rect = [cell convertRect:rect fromView:cell.bubbleView];
                [menu setTargetRect:rect inView:cell];
                [cell becomeFirstResponder];
                [menu setMenuVisible:YES animated:YES];
            }];
            failed = YES;
        } else {
            cell.messageImage.image = [UIImage imageNamed:@"ico_broken_voice_msg.png"];
            [cell.downloadButton setHidden:NO];
            [cell.progress setHidden:YES];
            [cell setTapAction:^{
                [cell download:cell.downloadButton];
            }];
        }
    }
    
    if (!failed) {
        [cell setLongpressAction:^{
            UIMenuController *menu = [UIMenuController sharedMenuController];
            NSMutableArray *menulist = [NSMutableArray arrayWithCapacity:5];
            
            UIMenuItem *item = nil;
            item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Forward", @"MenuItem") action:@selector(forwardAction:)];
            if (hasAudio) {
                [cell setForwardAction:^{
                    [self forwardMessage:text];
                }];
                [menulist addObject:item];
                
            } else {
                UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Retrieve", @"MenuItem") action:@selector(retransmitAction:)];
                [cell setRetransmitAction:^{
                    [cell download:nil];
                }];
                [menulist addObject:item];
                
            }
            
            item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete", @"MenuItem") action:@selector(answerAction:)];
            [cell setAnswerAction:^{
                [[SCDataManager instance] removeDatabaseObject:elem];
            }];
            [menulist addObject:item];
            
            menu.menuItems = menulist;
            CGRect rect = cell.bubbleView.frame;
            rect = [cell convertRect:rect fromView:cell.bubbleView];
            [menu setTargetRect:rect inView:cell];
            [cell becomeFirstResponder];
            [menu setMenuVisible:YES animated:YES];
        }];
    }
    
    [self setSubmittedStatusIcon:cell forStatus:[elem.status intValue]];
}


-(void) configureFriendCellOut:(__weak FriendCellOutStream *) cell forEvent:(MOC2CallEvent *) elem atIndexPath:(NSIndexPath *) indexPath
{
    NSString *text = elem.text;
    
    cell.userImage.image = [self ownUserImage];
    [self setUserImageAction:cell.userImage forElement:elem];
    
    NSString *sendername = elem.senderName?elem.senderName : [[C2CallPhone currentPhone] nameForUserid:elem.contact];
    cell.headline.text = [NSString stringWithFormat:@"@%@",  sendername];
    
    if ([cell isKindOfClass:[FriendCellIn class]]) {
        [(FriendCellIn *)cell setFriend:text];
    }
    if ([cell isKindOfClass:[FriendCellOut class]]) {
        [(FriendCellOut *)cell setFriend:text];
    }
    
    [cell setTapAction:^{
    }];
    
    [cell setLongpressAction:^{
        UIMenuController *menu = [UIMenuController sharedMenuController];
        NSMutableArray *menulist = [NSMutableArray arrayWithCapacity:5];
        
        UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Forward", @"MenuItem") action:@selector(forwardAction:)];
        [cell setForwardAction:^{
            [self forwardMessage:text];
        }];
        [menulist addObject:item];
        
        item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete", @"MenuItem") action:@selector(answerAction:)];
        [cell setAnswerAction:^{
            [[SCDataManager instance] removeDatabaseObject:elem];
        }];
        [menulist addObject:item];
        
        menu.menuItems = menulist;
        CGRect rect = cell.bubbleView.frame;
        rect = [cell convertRect:rect fromView:cell.bubbleView];
        [menu setTargetRect:rect inView:cell];
        [cell becomeFirstResponder];
        [menu setMenuVisible:YES animated:YES];
    }];
    
    [self setSubmittedStatusIcon:cell forStatus:[elem.status intValue]];
    
}


-(void) configureContactCellOut:(__weak ContactCellOutStream *) cell forEvent:(MOC2CallEvent *) elem atIndexPath:(NSIndexPath *) indexPath
{
    NSString *text = elem.text;
    
    cell.userImage.image = [self ownUserImage];
    [self setUserImageAction:cell.userImage forElement:elem];
    
    NSString *sendername = elem.senderName?elem.senderName : [[C2CallPhone currentPhone] nameForUserid:elem.contact];
    cell.headline.text = [NSString stringWithFormat:@"@%@",  sendername];
    
    [cell setVCard:text];
    
    [cell setTapAction:^{
        [self showContact:text];
    }];
    
    [cell setLongpressAction:^{
        UIMenuController *menu = [UIMenuController sharedMenuController];
        NSMutableArray *menulist = [NSMutableArray arrayWithCapacity:5];
        
        UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Forward", @"MenuItem") action:@selector(forwardAction:)];
        [cell setForwardAction:^{
            [self forwardMessage:text];
        }];
        [menulist addObject:item];
        
        
        item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Copy", @"MenuItem") action:@selector(copyAction:)];
        [cell setCopyAction:^{
            [self copyVCard:text];
        }];
        [menulist addObject:item];
        
        
        item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete", @"MenuItem") action:@selector(answerAction:)];
        [cell setAnswerAction:^{
            [[SCDataManager instance] removeDatabaseObject:elem];
        }];
        [menulist addObject:item];

        menu.menuItems = menulist;
        CGRect rect = cell.bubbleView.frame;
        rect = [cell convertRect:rect fromView:cell.bubbleView];
        [menu setTargetRect:rect inView:cell];
        [cell becomeFirstResponder];
        [menu setMenuVisible:YES animated:YES];
    }];
    
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
    CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width - 120,9999);
    
    CGSize expectedLabelSize = [elem.text sizeWithFont:[CommonMethods getStdFontType:1]
                                     constrainedToSize:maximumLabelSize
                                         lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat sz = expectedLabelSize.height + 34;
    if (sz < 30)
        sz = 30;
    
    return sz;
}

-(CGFloat) messageCellOutHeight:(MOC2CallEvent *) elem font:(UIFont *) font
{
    CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width - 120,9999);
    
    CGSize expectedLabelSize = [elem.text sizeWithFont:[CommonMethods getStdFontType:1]
                                     constrainedToSize:maximumLabelSize
                                         lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat sz = expectedLabelSize.height + 34;
    if (sz < 30)
        sz = 30;
    
    
    return sz;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (self.targetUserid) {
        NSIndexPath* ip = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
        
        UITableViewCell* cell;
        
        if ([self.fetchedResultsController fetchedObjects].count == 0) {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"SCNoMessagesCell"];
        }
        else{
            MOC2CallEvent *elem = [self.fetchedResultsController objectAtIndexPath:ip];
            NSString *eventType = elem.eventType;
            NSString *text = elem.text;
            
            if ([eventType isEqualToString:@"MessageIn"]) {
                if ([text hasPrefix:@"image://"]){
                    cell = [self.tableView dequeueReusableCellWithIdentifier:@"WUImageInCell"];
                    [self configureImageCellIn:cell forEvent:elem atIndexPath:ip];
                }
                else if([text hasPrefix:@"video://"] ||
                    [text hasPrefix:@"audio://"] ||
                    [text hasPrefix:@"file://"] ||
                    [text hasPrefix:@"loc://"] ||
                    [text hasPrefix:@"BEGIN:VCARD"] ||
                    [text hasPrefix:@"vcard://"] ||
                    [text hasPrefix:@"friend://"]) {
                    cell = [super tableView:tableView cellForRowAtIndexPath:ip];
                }
                else{
                    cell = [self.tableView dequeueReusableCellWithIdentifier:@"WUMessageInCell"];
                    [self configureMessageCellIn:cell forEvent:elem atIndexPath:ip];
                }
            }
            else{
                if ([text hasPrefix:@"image://"]){
                    cell = [self.tableView dequeueReusableCellWithIdentifier:@"WUImageOutCell"];
                    [self configureImageCellOut:cell forEvent:elem atIndexPath:ip];
                }
                else if([text hasPrefix:@"video://"] ||
                        [text hasPrefix:@"audio://"] ||
                        [text hasPrefix:@"file://"] ||
                        [text hasPrefix:@"loc://"] ||
                        [text hasPrefix:@"BEGIN:VCARD"] ||
                        [text hasPrefix:@"vcard://"] ||
                        [text hasPrefix:@"friend://"]) {
                    cell = [super tableView:tableView cellForRowAtIndexPath:ip];
                }
                else{
                    cell = [self.tableView dequeueReusableCellWithIdentifier:@"WUMessageOutCell"];
                    [self configureMessageCellOut:cell forEvent:elem atIndexPath:ip];
                }
                
            }
            
            @try {
                
                [[SCDataManager instance] markAsRead:elem];
            }
            @catch (NSException *exception) {
            }
        }
        return cell;

    }
    else{
        WUBroadcast* b = [[ResponseHandler instance].broadcastList objectAtIndex:indexPath.row];
        if(b.isImage){
            
            WUImageInCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"WUImageInCell"];
            
            cell.eventImage.image = [UIImage imageWithData:b.imgData];
            [cell setTapAction:^{
                NSMutableArray *imageList = [NSMutableArray array];
                for (int i = 0; i < [ResponseHandler instance].broadcastList.count; i++) {
                    WUBroadcast *c = [[ResponseHandler instance].broadcastList objectAtIndex:i];
                    if (c.isImage) {
                        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:3];
                        [info setValue:@"YES" forKey:@"IsBroadcast"];
                        [info setObject:[NSString stringWithFormat:@"%d", i] forKey:@"image"];
                        [imageList addObject:info];
                    }
                }
                
                NSString * storyboardName = @"MainStoryboard";
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                WUPhotoViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"WUPhotoViewController"];
                [vc showPhotos:imageList currentPhoto:[NSString stringWithFormat:@"%d", indexPath.row]];
                [self.navigationController pushViewController:vc animated:YES];
                
            }];
            
            if (!b.imgData) {
                [ResponseHandler instance].bcdelegate = self;
            }
            
            return cell;
        }
        else{
            WUMessageInCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"WUMessageInCell"];

            NSString *text = b.message;
            [cell.textLabel setText:text];
            [cell.textLabel setFont:[CommonMethods getStdFontType:1]];
            
            // Textfield size
            CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width - 120,9999);
            CGSize expectedLabelSize = [text sizeWithFont:[CommonMethods getStdFontType:1]
                                        constrainedToSize:maximumLabelSize
                                            lineBreakMode:NSLineBreakByWordWrapping];
            CGRect frame = CGRectMake(0, 8, expectedLabelSize.width + 20, expectedLabelSize.height + 20);
            [cell.bubbleView setFrame:frame];
            
            frame = CGRectMake(12, 8, expectedLabelSize.width, expectedLabelSize.height);
            [cell.textLabel setFrame:frame];

            NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"hh:mm a" options:0
                                                                      locale:[NSLocale currentLocale]];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:formatString];
            cell.timeLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:b.postTime]];
            frame = CGRectMake(expectedLabelSize.width + 10, expectedLabelSize.height - 14, 64, 21);
            [cell.timeLabel setFrame:frame];
            
            frame = CGRectMake(12, expectedLabelSize.height, expectedLabelSize.width + 74, 30);
            [cell.shadowImage setFrame:frame];
            
            return cell;
        }
    }
}



-(void)readBroadcastCompleted{
    [self.tableView reloadData];
}

-(void)readBroadcastImgCompleted{
    [self.tableView reloadData];
}

-(void) copyVCard:(NSString *) vcard
{
    @autoreleasepool {
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        
        NSData *data = [vcard dataUsingEncoding:NSUTF8StringEncoding];
        [pasteBoard setData:data forPasteboardType:(NSString*)kUTTypeVCard];
    }
}
@end
