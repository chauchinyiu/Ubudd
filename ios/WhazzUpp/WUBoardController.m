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

#import "WUPhotoViewController.h"
#import "DataRequest.h"
#import "WebserviceHandler.h"
#import "ResponseBase.h"
#import "DataResponse.h"
#import "CommonMethods.h"


@implementation WUMessageTimeCell
@synthesize timeLabel;
@end

@implementation WUMemberJoinCell
@synthesize timeLabel;
@end


@implementation WUCreateGroupCell
@synthesize nameLabel, timeLabel, showPreviousMsgView, createGroupView;
@end


@implementation WUMessageInCell
@synthesize textLabel;
@end

@implementation WUMessageOutCell
@synthesize textLabel;
@end

@implementation WUImageInCell
@synthesize eventImage;
@end

@implementation WUImageOutCell
@synthesize eventImage;
@end

@implementation WULocationInCell
@end


@implementation WUAudioInCell
@synthesize playButton, playSlider, playView, isPlaying, timer, player;

- (IBAction)playBtnPress:(id)sender{
    if (!isPlaying) {
        NSURL *audioUrl = [[C2CallPhone currentPhone] mediaUrlForKey:self.downloadKey];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioUrl error:nil];
        player.numberOfLoops = 1;
        player.currentTime = playSlider.value;
        playSlider.maximumValue = player.duration + 0.1;
        [player play];
        timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
        isPlaying = YES;
        [playButton setImage:[UIImage imageNamed:@"pause_unpress.png"] forState:UIControlStateNormal];
    }
    else{
        [player stop];
        isPlaying = NO;
        [playButton setImage:[UIImage imageNamed:@"play_unpress.png"] forState:UIControlStateNormal];
        [timer invalidate];
    }
}

-(void)updateTime:(NSTimer *)ptimer
{
    playSlider.value += ptimer.timeInterval;
    NSInteger tempMinute = playSlider.value / 60;
    NSInteger tempSecond = playSlider.value - (tempMinute * 60);
    
    NSString *minute = [[NSNumber numberWithInteger:tempMinute] stringValue];
    NSString *second = [[NSNumber numberWithInteger:tempSecond] stringValue];
    if (tempMinute < 10) {
        minute = [@"0" stringByAppendingString:minute];
    }
    if (tempSecond < 10) {
        second = [@"0" stringByAppendingString:second];
    }
    self.duration.text = [NSString stringWithFormat:@"%@:%@", minute, second];
    
    if (playSlider.value >= player.duration) {
        playSlider.value = 0.;
        [self duration].text = [[C2CallPhone currentPhone] durationForKey:self.downloadKey];
        [player stop];
        isPlaying = NO;
        [playButton setImage:[UIImage imageNamed:@"play_unpress.png"] forState:UIControlStateNormal];
        [ptimer invalidate];
    }
}


- (IBAction)playBtnDown:(id)sender{
    if (isPlaying) {
        [sender setImage:[UIImage imageNamed:@"pause_press.png"] forState:UIControlStateNormal];
    }
    else{
        [sender setImage:[UIImage imageNamed:@"play_press.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)playBtnUp:(id)sender{
    if (isPlaying) {
        [sender setImage:[UIImage imageNamed:@"pause_unpress.png"] forState:UIControlStateNormal];
    }
    else{
        [sender setImage:[UIImage imageNamed:@"play_unpress.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)sliderMove:(id)sender{
    if (isPlaying) {
        [player pause];
        player.currentTime = playSlider.value;
        [player play];
    }
}
@end

@implementation WUVideoInCell
@end

@implementation WUContactInCell
@end

@implementation WUFriendInCell
@end

@implementation WUCallInCell
@end

@implementation WULocationOutCell
@end

@implementation WUAudioOutCell
@synthesize playButton, playSlider, playView, isPlaying, timer, player;

- (IBAction)playBtnPress:(id)sender{
    if (!isPlaying) {
        NSURL *audioUrl = [[C2CallPhone currentPhone] mediaUrlForKey:self.downloadKey];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioUrl error:nil];
        player.numberOfLoops = 1;
        player.currentTime = playSlider.value;
        playSlider.maximumValue = player.duration + 0.1;
        [player play];
        timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
        isPlaying = YES;
        [playButton setImage:[UIImage imageNamed:@"pause_unpress.png"] forState:UIControlStateNormal];
    }
    else{
        [player stop];
        isPlaying = NO;
        [playButton setImage:[UIImage imageNamed:@"play_unpress.png"] forState:UIControlStateNormal];
        [timer invalidate];
    }
}

-(void)updateTime:(NSTimer *)ptimer
{
    playSlider.value += ptimer.timeInterval;
    NSInteger tempMinute = playSlider.value / 60;
    NSInteger tempSecond = playSlider.value - (tempMinute * 60);
    
    NSString *minute = [[NSNumber numberWithInteger:tempMinute] stringValue];
    NSString *second = [[NSNumber numberWithInteger:tempSecond] stringValue];
    if (tempMinute < 10) {
        minute = [@"0" stringByAppendingString:minute];
    }
    if (tempSecond < 10) {
        second = [@"0" stringByAppendingString:second];
    }
    self.duration.text = [NSString stringWithFormat:@"%@:%@", minute, second];
    
    if (playSlider.value >= player.duration) {
        [player stop];
        isPlaying = NO;
        [playButton setImage:[UIImage imageNamed:@"play_unpress.png"] forState:UIControlStateNormal];
        playSlider.value = 0.;
        [self duration].text = [[C2CallPhone currentPhone] durationForKey:self.downloadKey];
        [ptimer invalidate];
    }
}


- (IBAction)playBtnDown:(id)sender{
    if (isPlaying) {
        [sender setImage:[UIImage imageNamed:@"pause_press.png"] forState:UIControlStateNormal];
    }
    else{
        [sender setImage:[UIImage imageNamed:@"play_press.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)playBtnUp:(id)sender{
    if (isPlaying) {
        [sender setImage:[UIImage imageNamed:@"pause_unpress.png"] forState:UIControlStateNormal];
    }
    else{
        [sender setImage:[UIImage imageNamed:@"play_unpress.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)sliderMove:(id)sender{
    if (isPlaying) {
        [player pause];
        player.currentTime = playSlider.value;
        [player play];
    }
}

@end

@implementation WUVideoOutCell
@end

@implementation WUContactOutCell
@end

@implementation WUFriendOutCell
@end

@implementation WUCallOutCell
@end



@interface WUBoardController (){
    int groupHeadType;
    NSMutableArray* friendList;
    BOOL isVisible;
    
    NSMutableArray* headers;
    NSMutableArray* entries;
    NSMutableArray* memberJoinList;
    NSMutableArray* sectionSize;
    
    UIImage* forwardImage;
    
    MOC2CallEvent* forwardElem;
}

@property (nonatomic, strong) NSMutableDictionary  *smallImageCache;
@property (nonatomic, strong) UIFont *textFieldInFont, *headerFieldInFont, *textFieldOutFont, *headerFieldOutFont;
@end


@implementation WUBoardController
@synthesize smallImageCache, textFieldInFont, textFieldOutFont, headerFieldInFont, headerFieldOutFont, chatTitle;

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
    memberJoinList = [[NSMutableArray alloc] init];
    
    
    //stop plain style header from floating
    CGFloat dummyViewHeight = 40;
    UIView *dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, dummyViewHeight)];
    self.tableView.tableHeaderView = dummyView;
    self.tableView.contentInset = UIEdgeInsetsMake(-dummyViewHeight, 0, 0, 0);
}

-(void) viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.translucent = NO;
    isVisible = YES;
    if(self.targetUserid){
        if(isGroup){
            [self readGroupMemberJoin];
        }
        else{
            [self rebuildListEntries];
        }
    }
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
    if(lastSection >= 0){
        NSInteger rowCnt = [self.tableView numberOfRowsInSection:lastSection];
        if (rowCnt > 0) {
            NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:([self.tableView numberOfRowsInSection:lastSection] - 1) inSection:lastSection];
            [[self tableView] scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.targetUserid) {
        return [sectionSize count];
    }
    else{
        return 1;
    }
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(self.targetUserid){
        WUListEntry* e = [headers objectAtIndex:section];
        if ([e.source isEqualToString:@"InitHeader"]) {
            
            //call super to set previousMessagesButton
            [super tableView:tableView heightForHeaderInSection:section];
            
            CGFloat h = 0.;
            if (isGroup && section == 0) {
                h += 72;
            }
            if (section == 0 && !self.previousMessagesButton.hidden) {
                h += 40;
            }
            return h;
        }
        else if ([e.source isEqualToString:@"Time"]) {
            return 35;
        }
        else{
            return 0;
        }
    }
    else{
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if(self.targetUserid){
        WUListEntry* e = [headers objectAtIndex:section];
        if ([e.source isEqualToString:@"InitHeader"]) {
        
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
                
                cell.nameLabel.text = [NSString stringWithFormat:NSLocalizedString(@"createdagroup", @""), ownerName, groupName];
                
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
            return cell;
        }
        else if ([e.source isEqualToString:@"Time"]) {
            WUMessageTimeCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"WUMessageTimeCell"];

            NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"MMMM d HH:mm" options:0
                                                                      locale:[NSLocale currentLocale]];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:formatString];
            cell.timeLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:[e.data objectForKey:@"Time"]]];
            
            CGRect f;
            f = cell.timeLabel.frame;
            f.origin.x = (self.view.frame.size.width - f.size.width) / 2;
            f.origin.y = 16;
            cell.timeLabel.frame = f;
            
            return cell;
        }
        else{
            return nil;
        }
        
    }
    else{
        return nil;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.targetUserid) {
        return ((NSNumber*)[sectionSize objectAtIndex:section]).integerValue;
    }
    else{
        return [ResponseHandler instance].broadcastList.count;
    }
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.targetUserid) {
        UITableViewCell* cell;
        for (int i = 0; i < entries.count; i++) {
            WUListEntry* e = [entries objectAtIndex:i];
            if (e.mapToPath.row == indexPath.row && e.mapToPath.section == indexPath.section) {
                if ([e.source isEqualToString:@"MemberJoin"]) {
                    cell = [self.tableView dequeueReusableCellWithIdentifier:@"WUMemberJoinCell"];
                    
                    NSString* displayName;
                    NSString* memberID = [e.data objectForKey:@"memberID"];
                    SCGroup *group = [[SCGroup alloc] initWithGroupid:self.targetUserid];
                    MOC2CallUser *member = [[SCDataManager instance] userForUserid:memberID];
                    if (!member) {
                        NSString *firstname = [group nameForGroupMember:memberID];
                        if (firstname) {
                            displayName = firstname;
                        }
                    }
                    else {
                        displayName = [member.displayName copy];
                    }
                    for (int i = 0; i < friendList.count; i++) {
                        WUAccount* a = [friendList objectAtIndex:i];
                        if ([a.c2CallID isEqualToString:memberID]) {
                            displayName = a.name;
                        }
                    }
                    if (!displayName) {
                        
                    }
                    
                    ((WUMemberJoinCell*)cell).timeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"groupAddedMember", @"%@ added %@"), group.groupName, displayName];
                }

                if ([e.source isEqualToString:@"Message"]) {
                    
                    MOC2CallEvent *elem = [self.fetchedResultsController objectAtIndexPath:e.sourcePath];
                    NSString *eventType = elem.eventType;
                    NSString *text = elem.text;
                    
                    if ([eventType isEqualToString:@"MessageIn"]) {
                        if ([text hasPrefix:@"image://"]){
                            cell = [self.tableView dequeueReusableCellWithIdentifier:@"WUImageInCell"];
                            [self configureImageCellIn:cell forEvent:elem atIndexPath:e.sourcePath];
                        }
                        else if([text hasPrefix:@"video://"] ||
                                [text hasPrefix:@"audio://"] ||
                                [text hasPrefix:@"file://"] ||
                                [text hasPrefix:@"loc://"] ||
                                [text hasPrefix:@"BEGIN:VCARD"] ||
                                [text hasPrefix:@"vcard://"] ||
                                [text hasPrefix:@"friend://"]) {
                            cell = [super tableView:tableView cellForRowAtIndexPath:e.sourcePath];
                        }
                        else{
                            cell = [self.tableView dequeueReusableCellWithIdentifier:@"WUMessageInCell"];
                            [self configureMessageCellIn:cell forEvent:elem atIndexPath:e.sourcePath];
                        }
                    }
                    else{
                        if ([text hasPrefix:@"image://"]){
                            cell = [self.tableView dequeueReusableCellWithIdentifier:@"WUImageOutCell"];
                            [self configureImageCellOut:cell forEvent:elem atIndexPath:e.sourcePath];
                        }
                        else if([text hasPrefix:@"video://"] ||
                                [text hasPrefix:@"audio://"] ||
                                [text hasPrefix:@"file://"] ||
                                [text hasPrefix:@"loc://"] ||
                                [text hasPrefix:@"BEGIN:VCARD"] ||
                                [text hasPrefix:@"vcard://"] ||
                                [text hasPrefix:@"friend://"]) {
                            cell = [super tableView:tableView cellForRowAtIndexPath:e.sourcePath];
                        }
                        else{
                            cell = [self.tableView dequeueReusableCellWithIdentifier:@"WUMessageOutCell"];
                            [self configureMessageCellOut:cell forEvent:elem atIndexPath:e.sourcePath];
                        }
                    }
                    
                    @try {
                        
                        [[SCDataManager instance] markAsRead:elem];
                    }
                    @catch (NSException *exception) {
                    }
            
                }
                else if ([e.source isEqualToString:@"NoMessage"]) {
                    cell = [self.tableView dequeueReusableCellWithIdentifier:@"SCNoMessagesCell"];
                }
                return cell;
            }
        }
    }
    else{
        WUBroadcast* b = [[ResponseHandler instance].broadcastList objectAtIndex:indexPath.row];
        if(b.isImage){
            
            WUImageInCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"WUImageInCell"];
            
            cell.eventImage.image = [UIImage imageWithData:b.imgData];
            [cell.progress setHidden:YES];
            
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
                
                WUPhotoViewController* vc = [storyboard instantiateViewControllerWithIdentifier:@"WUPhotoViewController"];
                
                [vc showPhotos:imageList currentPhoto:[NSString stringWithFormat:@"%d", (int)indexPath.row]];
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
            CGRect frame = CGRectMake(0, 8, expectedLabelSize.width + 90, expectedLabelSize.height + 20);
            [cell.bubbleView setFrame:frame];
            
            frame = CGRectMake(12, 8, expectedLabelSize.width, expectedLabelSize.height);
            [cell.textLabel setFrame:frame];
            return cell;
        }
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.targetUserid) {
        UITableViewCell* cell;
        for (int i = 0; i < entries.count; i++) {
            WUListEntry* e = [entries objectAtIndex:i];
            if (e.mapToPath.row == indexPath.row && e.mapToPath.section == indexPath.section) {
                if ([e.source isEqualToString:@"MemberJoin"]) {
                    return 40;
                }
                cell = [self cellForElement:[self.fetchedResultsController objectAtIndexPath:e.sourcePath]];
                if ([cell isKindOfClass:[ImageCellInStream class]]) {
                    return 212;
                }
                if ([cell isKindOfClass:[ImageCellOutStream class]]) {
                    return 212;
                }
                if ([cell isKindOfClass:[LocationCellIn class]]) {
                    return 118;
                }
                if ([cell isKindOfClass:[LocationCellOut class]]) {
                    return 118;
                }
                if ([cell isKindOfClass:[AudioCellIn class]]) {
                    return 65;
                }
                if ([cell isKindOfClass:[AudioCellOut class]]) {
                    return 65;
                }
                if ([cell isKindOfClass:[VideoCellIn class]]) {
                    return 120;
                }
                if ([cell isKindOfClass:[VideoCellOut class]]) {
                    return 120;
                }
                if ([cell isKindOfClass:[FriendCellIn class]]) {
                    return 77;
                }
                if ([cell isKindOfClass:[FriendCellOut class]]) {
                    return 77;
                }
                if ([cell isKindOfClass:[ContactCellIn class]]) {
                    return 77;
                }
                if ([cell isKindOfClass:[ContactCellOut class]]) {
                    return 77;
                }
                if ([cell isKindOfClass:[CallCellIn class]]) {
                    return 105;
                }
                if ([cell isKindOfClass:[CallCellOut class]]) {
                    return 105;
                }
                if ([cell isKindOfClass:[MessageCellInStream class]]) {
                    return [self messageCellInHeight:[self.fetchedResultsController objectAtIndexPath:e.sourcePath] font:nil];
                }
                if ([cell isKindOfClass:[MessageCellOutStream class]]) {
                    return [self messageCellOutHeight:[self.fetchedResultsController objectAtIndexPath:e.sourcePath] font:nil];
                }
                
                
                return 0;
                
            }
        }
        
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
        
        
    }
    else if ([cell isKindOfClass:[WUAudioOutCell class]]) {
        WUAudioOutCell *c = (WUAudioOutCell*)cell;
        [c.headline setHidden:YES];

        CGRect frame = c.bubbleView.frame;
        frame.origin.x = self.view.frame.size.width - frame.size.width;
        [c.bubbleView setFrame:frame];
        
    }
    else if ([cell isKindOfClass:[WUVideoOutCell class]]) {
        WUVideoOutCell *c = (WUVideoOutCell*)cell;
        [c.headline setHidden:YES];
        
        CGRect frame = c.bubbleView.frame;
        frame.origin.x = self.view.frame.size.width - frame.size.width;
        [c.bubbleView setFrame:frame];
        
    }
    else if ([cell isKindOfClass:[WUFriendOutCell class]]) {
        WUFriendOutCell *c = (WUFriendOutCell*)cell;
        [c.headline setHidden:YES];
        
        CGRect frame = c.bubbleView.frame;
        frame.origin.x = self.view.frame.size.width - frame.size.width;
        [c.bubbleView setFrame:frame];
        
    }
    else if ([cell isKindOfClass:[WUContactOutCell class]]) {
        WUContactOutCell *c = (WUContactOutCell*)cell;
        [c.headline setHidden:YES];
        
        CGRect frame = c.bubbleView.frame;
        frame.origin.x = self.view.frame.size.width - frame.size.width;
        [c.bubbleView setFrame:frame];
        
    }
    else if ([cell isKindOfClass:[WUCallOutCell class]]) {
        WUCallOutCell *c = (WUCallOutCell*)cell;
        [c.headline setHidden:YES];
        
        CGRect frame = c.bubbleView.frame;
        frame.origin.x = self.view.frame.size.width - frame.size.width;
        [c.bubbleView setFrame:frame];
        
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
    }
}


- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Hide Keyboard in SCChatController on touch
    if ([self.parentViewController respondsToSelector:@selector(hideKeyboard:)]) {
        [self.parentViewController performSelector:@selector(hideKeyboard:) withObject:nil];
    }
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:@"SCNoFilterResultsCell"]) {
        [self removeAllFilter:self];
        return;
    }
    if ([cell.reuseIdentifier isEqualToString:@"SCNoMessagesCell"]) {
        return;
    }
    
    //don't know why setTapAction doesn't work
    if ([cell.reuseIdentifier isEqualToString:@"VideoCellInStream"]) {
        [CommonMethods showMovie:((VideoCellInStream*)cell).downloadKey onNavigationController:self.navigationController];
        return;
    }
    
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
        return;
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
            
            UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Forward", @"MenuItem") action:@selector(shareAction:)];
            [cell setShareAction:^{
                [self forwardPhoto:[[C2CallPhone currentPhone] imageForKey:elem.text]];
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
            
            item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Email", @"MenuItem") action:@selector(retransmitAction:)];
            [cell setRetransmitAction:^{
                if ([MFMailComposeViewController canSendMail]) {
                    
                    MFMailComposeViewController *emailController = [[MFMailComposeViewController alloc] init];
                    UIImage *myImage = [[C2CallPhone currentPhone] imageForKey:text];
                    NSData *imageData = UIImagePNGRepresentation(myImage);
                    
                    [emailController addAttachmentData:imageData mimeType:@"image/png" fileName:@"image"];
                    emailController.mailComposeDelegate = self;
                    [self presentViewController:emailController animated:YES completion:nil];
                }                
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
            
            UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Forward", @"MenuItem") action:@selector(shareAction:)];
            [cell setShareAction:^{
                [self forwardPhoto:[[C2CallPhone currentPhone] imageForKey:elem.text]];
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
            
            
            item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Email", @"MenuItem") action:@selector(retransmitAction:)];
            [cell setRetransmitAction:^{
                if ([MFMailComposeViewController canSendMail]) {
                    
                    MFMailComposeViewController *emailController = [[MFMailComposeViewController alloc] init];
                    UIImage *myImage = [[C2CallPhone currentPhone] imageForKey:text];
                    NSData *imageData = UIImageJPEGRepresentation(myImage, 0.95);
                    
                    [emailController addAttachmentData:imageData mimeType:@"image/jpeg" fileName:@"image"];
                    emailController.mailComposeDelegate = self;
                    [self presentViewController:emailController animated:YES completion:nil];
                }
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
    CGSize expectedLabelSize = [self getSizeForText:text withWidth:self.view.frame.size.width - 60 withFont:[CommonMethods getStdFontType:1]];
    
    //bubble
    CGRect frame = CGRectMake(0, 0, expectedLabelSize.width + 17, expectedLabelSize.height + 6);
    [cell.bubbleView setFrame:frame];
    
    //text
    frame = CGRectMake(12, 3, expectedLabelSize.width, expectedLabelSize.height);
    [cell.textLabel setFrame:frame];
    
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
    CGSize expectedLabelSize = [self getSizeForText:text withWidth:self.view.frame.size.width - 60 withFont:[CommonMethods getStdFontType:1]];
    
    CGSize contentSize = [self getContentSizeForText:text withWidth:self.view.frame.size.width - 60 withFont:[CommonMethods getStdFontType:1]];
    
    //bubble
    CGRect frame = CGRectMake(self.view.frame.size.width - contentSize.width - 10, 0, contentSize.width + 12, contentSize.height + 6);
    [cell.bubbleView setFrame:frame];
    
    //text
    frame = CGRectMake(6, 3, expectedLabelSize.width, expectedLabelSize.height);
    [cell.textLabel setFrame:frame];
    
    
    //icon
    frame = CGRectMake(contentSize.width + 10 - 14 - 6, contentSize.height - 14, 14, 14);
    [cell.iconSubmitted setFrame:frame];
    
    
    int status = [elem.status intValue];
    if (status == 3) {
        cell.iconSubmitted.image = [UIImage imageNamed:@"ico_notdelivered.png"];
        [cell.iconSubmitted setHidden:NO];
        
        [cell setLongpressAction:^{
            [self setRetransmitActionForCell:cell withKey:elem.text andUserid:elem.contact];
        }];
        
        return;
    }
    
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

-(void) configureVideoCellIn:(__weak VideoCellInStream *) cell forEvent:(MOC2CallEvent *) elem atIndexPath:(NSIndexPath *) indexPath
{
    NSString *text = elem.text;
    
    cell.headline.text = elem.senderName?elem.senderName : [[C2CallPhone currentPhone] nameForUserid:elem.contact];
    cell.userImage.image = [self imageForElement:elem];
    [self setUserImageAction:cell.userImage forElement:elem];
    cell.imageNewIndicator.hidden = ![elem.missedDisplay boolValue];
    cell.downloadKey = text;
    
    BOOL failed = NO;
    if ([[C2CallPhone currentPhone] hasObjectForKey:text]) {
        cell.messageImage.image = [[C2CallPhone currentPhone] thumbnailForKey:text];
        cell.duration.text = [[C2CallPhone currentPhone] durationForKey:text];
        
        [cell.progress setHidden:YES];
    } else {
        UIImage *thumb = [[C2CallPhone currentPhone] thumbnailForKey:text];
        
        if (thumb) {
            cell.messageImage.image = thumb;
            cell.duration.text = [[C2CallPhone currentPhone] durationForKey:text];
        }
        if ([[C2CallPhone currentPhone] downloadStatusForKey:text]) {
            [cell.downloadButton setHidden:YES];
            [cell monitorDownloadForKey:text];
        } else if ([[C2CallPhone currentPhone] failedDownloadStatusForKey:text]) {
            // We need a broken link image here and a download button
            cell.messageImage.image = [UIImage imageNamed:@"ico_broken_video.png"];
            [cell.downloadButton setHidden:YES];
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
            [CommonMethods showMovie:text onNavigationController:self.navigationController];
        }];
        
        [cell setLongpressAction:^{
            UIMenuController *menu = [UIMenuController sharedMenuController];
            NSMutableArray *menulist = [NSMutableArray arrayWithCapacity:5];
            
            UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Share", @"MenuItem") action:@selector(shareAction:)];
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
            
            
            menu.menuItems = menulist;
            CGRect rect = cell.messageImage.frame;
            rect = [cell convertRect:rect fromView:cell.messageImage];
            [menu setTargetRect:rect inView:cell];
            [cell becomeFirstResponder];
            [menu setMenuVisible:YES animated:YES];
        }];
    }
    
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
            [CommonMethods showMovie:text onNavigationController:self.navigationController];
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
    
    
    int status = [elem.status intValue];
    if (status == 3) {
        cell.iconSubmitted.image = [UIImage imageNamed:@"ico_notdelivered.png"];
        [cell.iconSubmitted setHidden:NO];
        
        [cell setLongpressAction:^{
            [self setRetransmitActionForCell:cell withKey:elem.text andUserid:elem.contact];
        }];
        
        return;
    }
    
    
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


-(void) configureAudioCellOut:(__weak WUAudioOutCell *) cell forEvent:(MOC2CallEvent *) elem atIndexPath:(NSIndexPath *) indexPath
{

    NSString *text = elem.text;
    cell.downloadKey = text;
    
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
        [cell.progress setHidden:YES];
        [cell.playView setHidden:NO];
        [cell.playButton setImage:[UIImage imageNamed:@"play_unpress.png"] forState:UIControlStateNormal];
        
        NSString *durStr = [[C2CallPhone currentPhone] durationForKey:text];
        CGFloat durSec = 0.;
        
        while (durStr.length > 0) {
            NSRange range = [durStr rangeOfString:@":"];
            NSString* numStr;
            if (range.location == NSNotFound) {
                numStr = durStr;
                durStr = @"";
            }
            else{
                NSRange numRange;
                numRange.location = 0;
                numRange.length = range.location;
                numStr = [durStr substringWithRange:numRange];
                
                numRange.location = range.location + 1;
                numRange.length = durStr.length - numRange.location;
                durStr = [durStr substringWithRange:numRange];
            }
            durSec = durSec * 60 + numStr.intValue;
        }
        
        [cell.playSlider setMaximumValue:durSec];
        [cell.playSlider setMinimumValue:0.0];
        [cell.playSlider setValue:0.0];

    } else {
        
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
    
    int status = [elem.status intValue];
    if (status == 3) {
        cell.iconSubmitted.image = [UIImage imageNamed:@"ico_notdelivered.png"];
        [cell.iconSubmitted setHidden:NO];
        
        [cell setLongpressAction:^{
            [self setRetransmitActionForCell:cell withKey:elem.text andUserid:elem.contact];
        }];
        
        return;
    }
    
    
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
    
    int status = [elem.status intValue];
    if (status == 3) {
        cell.iconSubmitted.image = [UIImage imageNamed:@"ico_notdelivered.png"];
        [cell.iconSubmitted setHidden:NO];
        
        [cell setLongpressAction:^{
            [self setRetransmitActionForCell:cell withKey:elem.text andUserid:elem.contact];
        }];
        
        return;
    }
    
    
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

-(void) configureAudioCellIn:(__weak WUAudioInCell *) cell forEvent:(MOC2CallEvent *) elem atIndexPath:(NSIndexPath *) indexPath
{
    NSString *text = elem.text;
    BOOL failed = NO;

    cell.downloadKey = text;
    
    if ([[C2CallPhone currentPhone] hasObjectForKey:text]) {
        cell.duration.text = [[C2CallPhone currentPhone] durationForKey:text];
        
        [cell.progress setHidden:YES];
        [cell.playView setHidden:NO];
        [cell.playButton setImage:[UIImage imageNamed:@"play_unpress.png"] forState:UIControlStateNormal];
        
        NSString *durStr = [[C2CallPhone currentPhone] durationForKey:text];
        CGFloat durSec = 0.;
        
        while (durStr.length > 0) {
            NSRange range = [durStr rangeOfString:@":"];
            NSString* numStr;
            if (range.location == NSNotFound) {
                numStr = durStr;
                durStr = @"";
            }
            else{
                NSRange numRange;
                numRange.location = 0;
                numRange.length = range.location;
                numStr = [durStr substringWithRange:numRange];
                
                numRange.location = range.location + 1;
                numRange.length = durStr.length - numRange.location;
                durStr = [durStr substringWithRange:numRange];
            }
            durSec = durSec * 60 + numStr.intValue;
        }
        
        [cell.playSlider setMaximumValue:durSec];
        [cell.playSlider setMinimumValue:0.0];
        [cell.playSlider setValue:0.0];
    } else {
        
        if ([[C2CallPhone currentPhone] downloadStatusForKey:text]) {
            [cell.downloadButton setHidden:YES];
            [cell monitorDownloadForKey:text];
        } else if ([[C2CallPhone currentPhone] failedDownloadStatusForKey:text]) {
            // We need a broken link image here and a download button
            cell.messageImage.image = [UIImage imageNamed:@"ico_broken_video.png"];
            [cell.downloadButton setHidden:YES];
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
            failed = YES;
        } else {
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
            
            UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Forward", @"MenuItem") action:@selector(forwardAction:)];
            [cell setForwardAction:^{
                [self forwardMessage:text];
            }];
            [menulist addObject:item];
            
            
            menu.menuItems = menulist;
            CGRect rect = cell.messageImage.frame;
            rect = [cell convertRect:rect fromView:cell.messageImage];
            [menu setTargetRect:rect inView:cell];
            [cell becomeFirstResponder];
            [menu setMenuVisible:YES animated:YES];
        }];
    }
    
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
                [info setObject:elem forKey:@"eventObject"];
                if (elem.senderName)
                    [info setObject:elem.senderName forKey:@"senderName"];
                
                [imageList addObject:info];
            }
        }
        
        NSString * storyboardName = @"MainStoryboard";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        
        WUPhotoViewController* vc = [storyboard instantiateViewControllerWithIdentifier:@"WUPhotoViewController"];

        vc.chatTitle = chatTitle;
        [vc showPhotos:imageList currentPhoto:key];
        [self.navigationController pushViewController:vc animated:YES];
                
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
    CGSize sz = [self getSizeForText:elem.text withWidth:self.view.frame.size.width - 60 withFont:[CommonMethods getStdFontType:1]];
    
    return sz.height + 22;
}

-(CGFloat) messageCellOutHeight:(MOC2CallEvent *) elem font:(UIFont *) font
{
    CGSize sz = [self getContentSizeForText:elem.text withWidth:self.view.frame.size.width - 60 withFont:[CommonMethods getStdFontType:1]];
    return sz.height + 22;
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

-(IBAction)composeAction:(id)sender
{
    [self composeMessage:nil richMessageKey:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

-(NSArray*)getSeparatedLinesFromString:(NSString*)text withWidth:(int)width withFont:(UIFont*)font
{

    
    NSMutableArray* lines = [[NSMutableArray alloc] init];
    
    NSCharacterSet* wordSeparators = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    NSString* currentLine = text;
    int textLength = text.length;
    
    NSRange rCurrentLine = NSMakeRange(0, textLength);
    NSRange rWhitespace = NSMakeRange(0,0);
    NSRange rRemainingText = NSMakeRange(0, textLength);
    BOOL done = NO;
    while ( !done )
    {
        // determine the next whitespace word separator position
        rWhitespace.location = rWhitespace.location + rWhitespace.length;
        rWhitespace.length = textLength - rWhitespace.location;
        rWhitespace = [text rangeOfCharacterFromSet: wordSeparators options: NSCaseInsensitiveSearch range: rWhitespace];
        if ( rWhitespace.location == NSNotFound )
        {
            rWhitespace.location = textLength;
            done = YES;
        }
        
        NSRange rTest = NSMakeRange(rRemainingText.location, rWhitespace.location-rRemainingText.location);
        
        NSString* textTest = [text substringWithRange: rTest];
        CGSize sizeTest = [self getSizeForText:textTest withWidth:width + 1024 withFont:font] ;

        if ( sizeTest.width > width )
        {
            [lines addObject: [currentLine stringByTrimmingCharactersInSet:wordSeparators]];
            rRemainingText.location = rCurrentLine.location + rCurrentLine.length;
            rRemainingText.length = textLength-rRemainingText.location;
            continue;
        }
        
        rCurrentLine = rTest;
        currentLine = textTest;
    }

    NSString* remainingText = [text substringWithRange: rRemainingText];
    [lines addObject: [remainingText stringByTrimmingCharactersInSet:wordSeparators]];
    
    return lines;
}


-(CGSize)getSizeForText:(NSString*)text withWidth:(int)width withFont:(UIFont*)font{
    CGSize maximumLabelSize = CGSizeMake(width, CGFLOAT_MAX);
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: font}];
    CGRect rect = [attributedText boundingRectWithSize:maximumLabelSize
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize sizeTest = CGSizeMake(ceilf(rect.size.width), ceilf(rect.size.height));
    return sizeTest;
}


-(CGSize)getContentSizeForText:(NSString*)text withWidth:(int)width withFont:(UIFont*)font{
    CGSize maximumLabelSize = CGSizeMake(width, CGFLOAT_MAX);
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: font}];
    CGRect rect = [attributedText boundingRectWithSize:maximumLabelSize
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize sizeTest = CGSizeMake(ceilf(rect.size.width), ceilf(rect.size.height));
    
    
    NSArray* lines = [self getSeparatedLinesFromString:text withWidth:width withFont:font];
    NSString *lastLine=[lines lastObject];
    CGSize lastSize = [self getSizeForText:lastLine withWidth:width withFont:font];
    if ((width - lastSize.width) < 20) {
        sizeTest.height = sizeTest.height + 15;
    }
    else if(lines.count == 1){
        //single line, add width of time label
        sizeTest.width = sizeTest.width + 20;
    }
    return sizeTest;
}

-(void)readGroupMemberJoin{
    DataRequest* datRequest = [[DataRequest alloc] init];
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    [data setValue:self.targetUserid forKey:@"c2CallID"];
    datRequest.values = data;
    datRequest.requestName = @"readGroupMemberJoin";
    
    WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
    [serviceHandler execute:METHOD_DATA_REQUEST parameter:datRequest target:self action:@selector(readGroupMemberJoinResponse:error:)];
    
}

- (void)readGroupMemberJoinResponse:(ResponseBase *)response error:(NSError *)error{
    NSDictionary* fetchResult = ((DataResponse*)response).data;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"EST"];
    [dateFormat setTimeZone:gmt];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    [memberJoinList removeAllObjects];
    int memberCnt = ((NSNumber*)[fetchResult objectForKey:@"rowCnt"]).intValue;
    for (int i = 0; i < memberCnt; i++) {
        NSMutableDictionary* memberDat = [[NSMutableDictionary alloc] init];
        [memberDat setObject:[fetchResult objectForKey:[NSString stringWithFormat:@"memberID%d", i]] forKey:@"memberID"];

        [memberDat setObject:[dateFormat dateFromString:[fetchResult objectForKey:[NSString stringWithFormat:@"joinTime%d", i]]] forKey:@"joinTime"];

        [memberDat setObject:[fetchResult objectForKey:[NSString stringWithFormat:@"userName%d", i]] forKey:@"userName"];
        
        [memberJoinList addObject:memberDat];
    }
    
    [self rebuildListEntries];
    [self.tableView reloadData];
}

-(void)rebuildListEntries{
    headers = [[NSMutableArray alloc] init];
    entries = [[NSMutableArray alloc] init];
    sectionSize = [[NSMutableArray alloc] init];
    NSString* lastID = @"";
    NSDate* lastDateLabel = [NSDate dateWithTimeIntervalSince1970:0];
    
    if(self.targetUserid){
        
        WUListEntry* e = [[WUListEntry alloc] init];
        e.source = [NSMutableString stringWithString:@"InitHeader"];
        [headers addObject:e];
        [sectionSize addObject:[NSNumber numberWithInt:0]];

        NSDate* newJoinFrom;
        NSDate* newJoinTo;
        //a join detail until the first message
        if (isGroup) {
            if ([self.fetchedResultsController fetchedObjects].count == 0) {
                //add all join detail for empty group
                //get group create time
                NSMutableArray* groups = [[ResponseHandler instance] groupList];
                for (int i = 0; i < groups.count; i++) {
                    WUAccount* a = [groups objectAtIndex:i];
                    if ([a.c2CallID isEqualToString:self.targetUserid]) {
                        newJoinFrom = a.createTime;
                    }
                }
                
                newJoinTo = [NSDate dateWithTimeIntervalSinceNow:0];
                [self addJoinEntryFrom:newJoinFrom to:newJoinTo];
            }
        }
        
        for (int runSect = 0; runSect < [[self.fetchedResultsController sections] count]; runSect++) {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:runSect];
            int rowCnt = [sectionInfo numberOfObjects];
            for (int runRow = 0; runRow < rowCnt; runRow++) {
                MOC2CallEvent *elem = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:runRow inSection:runSect]];
                NSString* newID;
                
                if ([elem.eventType isEqualToString:@"MessageOut"] || [elem.eventType isEqualToString:@"MessageSubmit"]) {
                    newID = @"";
                }
                else{
                    newID = elem.senderName;
                }
                if((runRow == 0 && runSect == 0)
                   || [elem.timeStamp compare:[NSDate dateWithTimeInterval:900 sinceDate:lastDateLabel]] == NSOrderedDescending
                   || ![newID isEqualToString:lastID]){
                    WUListEntry* e = [[WUListEntry alloc] init];
                    e.source = [NSMutableString stringWithString:@"Time"];
                    e.data = [[NSMutableDictionary alloc] init];
                    [e.data setValue:elem.timeStamp forKey:@"Time"];
                    [headers addObject:e];
                    [sectionSize addObject:[NSNumber numberWithInt:0]];
                    
                }
                lastDateLabel = elem.timeStamp;
                lastID = newID;
                
                //add join detail before this message
                if (isGroup) {
                    if (runRow == 0 && runSect == 0) {
                        newJoinFrom = [NSDate  dateWithTimeInterval:-259200 sinceDate:elem.timeStamp ];
                    }
                    newJoinTo = elem.timeStamp;
                    [self addJoinEntryFrom:newJoinFrom to:newJoinTo];
                    
                    newJoinFrom = newJoinTo;
                }
                
                //add message
                WUListEntry* e = [[WUListEntry alloc] init];
                e.source = [NSMutableString stringWithString:@"Message"];
                e.sourcePath = [NSIndexPath indexPathForRow:runRow inSection:runSect];
                [self addEntry:e];
                
                if (runRow == rowCnt -1 && runSect == [[self.fetchedResultsController sections] count] - 1) {
                    if (isGroup) {
                        //add remaining join detail
                        newJoinTo = [NSDate dateWithTimeIntervalSinceNow:0];
                        [self addJoinEntryFrom:newJoinFrom to:newJoinTo];
                    }
                }
            }
        }
    }
}

-(void)addJoinEntryFrom:(NSDate*)pDateF to:(NSDate*)pDateT{
    for (int i = 0; i < memberJoinList.count; i++) {
        if ([pDateF compare:[[memberJoinList objectAtIndex:i] objectForKey:@"joinTime"]] == NSOrderedAscending
            && [pDateT compare:[[memberJoinList objectAtIndex:i] objectForKey:@"joinTime"]] == NSOrderedDescending) {
            
            WUListEntry* e = [[WUListEntry alloc] init];
            e.source = [NSMutableString stringWithString:@"MemberJoin"];
            e.data = [[NSMutableDictionary alloc] initWithDictionary:[memberJoinList objectAtIndex:i] copyItems:YES];
            [self addEntry:e];
        }
    }
}

-(void)addEntry:(WUListEntry*)e{
    int currentSectionLen  = ((NSNumber*)[sectionSize objectAtIndex:sectionSize.count - 1]).intValue;
    e.mapToPath = [NSIndexPath indexPathForRow:currentSectionLen inSection:sectionSize.count - 1 ];
    
    
    [entries addObject:e];
    
    [sectionSize replaceObjectAtIndex:sectionSize.count - 1 withObject:[NSNumber numberWithInt:currentSectionLen + 1]];
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self rebuildListEntries];
    [super controllerDidChangeContent:controller];
}


- (UITableViewCell *)cellForElement:(MOC2CallEvent *)elem {

    MessageCell *cell = nil;
    @try {
        // Handle Section HeaderCell
        NSString *cellIdentifier = nil;
        NSString *eventType = elem.eventType;
        NSString *text = elem.text;
        BOOL isInbound = NO;
        BOOL isMessage = NO;
        
        if ([eventType isEqualToString:@"CallIn"]) {
            cellIdentifier = @"CallCellInStream";
            isInbound = YES;
        } else if ([eventType isEqualToString:@"CallOut"]) {
            cellIdentifier = @"CallCellOutStream";
        } else if ([eventType isEqualToString:@"MessageOut"] || [eventType isEqualToString:@"MessageSubmit"]) {
            isMessage = YES;
            cellIdentifier = @"WUMessageOutCell";
            
            if ([text hasPrefix:@"image://"]) {
                cellIdentifier = @"WUImageOutCell";
            }
            if ([text hasPrefix:@"video://"]) {
                cellIdentifier = @"VideoCellOutStream";
            }
            if ([text hasPrefix:@"audio://"]) {
                cellIdentifier = @"AudioCellOutStream";
            }
            if ([text hasPrefix:@"file://"]) {
                cellIdentifier = @"FileCellOutStream";
            }
            if ([text hasPrefix:@"loc://"]) {
                cellIdentifier = @"LocationCellOutStream";
            }
            if ([text hasPrefix:@"BEGIN:VCARD"]) {
                cellIdentifier = @"ContactCellOutStream";
            }
            if ([text hasPrefix:@"vcard://"]) {
                cellIdentifier = @"ContactCellOutStream";
            }
            if ([text hasPrefix:@"friend://"]) {
                cellIdentifier = @"FriendCellOutStream";
            }
        } else {
            isInbound = YES;
            isMessage = YES;
            cellIdentifier = @"WUMessageInCell";
            
            if ([text hasPrefix:@"image://"]) {
                cellIdentifier = @"WUImageInCell";
            }
            if ([text hasPrefix:@"video://"]) {
                cellIdentifier = @"VideoCellInStream";
            }
            if ([text hasPrefix:@"audio://"]) {
                cellIdentifier = @"AudioCellInStream";
            }
            if ([text hasPrefix:@"file://"]) {
                cellIdentifier = @"FileCellInStream";
            }
            if ([text hasPrefix:@"loc://"]) {
                cellIdentifier = @"LocationCellInStream";
            }
            if ([text hasPrefix:@"BEGIN:VCARD"]) {
                cellIdentifier = @"ContactCellInStream";
            }
            if ([text hasPrefix:@"vcard://"]) {
                cellIdentifier = @"ContactCellInStream";
            }
            if ([text hasPrefix:@"friend://"]) {
                cellIdentifier = @"FriendCellInStream";
            }
        }
        
        cell = (MessageCell *) [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    @catch (NSException * e) {
        [self.tableView reloadData];
        UITableViewCell *dummyCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        dummyCell.contentView.hidden = YES;
        return dummyCell;
    }
    @finally {
    }
    return cell;
    
}


-(IBAction)previousMessages:(id)sender
{
    [super previousMessages:sender];
    [self rebuildListEntries];
}

-(void)forwardPhoto:(UIImage*)image{
    forwardImage = image;
    NSString * storyboardName = @"MainStoryboard";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    WUNewChatViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"WUNewChatViewController"];
    
    [vc switchToSelectionMode:self];
    [self.navigationController pushViewController:vc animated:YES];
    
}

-(void)forwardEvent:(MOC2CallEvent*)elem{
    forwardElem = elem;
    NSString * storyboardName = @"MainStoryboard";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    WUNewChatViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"WUNewChatViewController"];
    
    [vc switchToSelectionMode:self];
    [self.navigationController pushViewController:vc animated:YES];
}


-(void)selectTarget:(NSString*)c2callID{
    if ([forwardElem.text hasPrefix:@"image://"]){
        [[C2CallPhone currentPhone] submitImage:[[C2CallPhone currentPhone] imageForKey:forwardElem.text] withQuality:UIImagePickerControllerQualityTypeHigh andMessage:nil toTarget:c2callID withCompletionHandler:nil];
    }
    else if ([forwardElem.text hasPrefix:@"video://"]){
        [[C2CallPhone currentPhone] submitVideo:[[C2CallPhone currentPhone] mediaUrlForKey:forwardElem.text] withMessage:nil toTarget:c2callID withCompletionHandler:nil];
    }
    else if ([forwardElem.text hasPrefix:@"audio://"]){
        [[C2CallPhone currentPhone] submitAudio:[[C2CallPhone currentPhone] mediaUrlForKey:forwardElem.text] withMessage:nil toTarget:c2callID withCompletionHandler:nil];
    }
    /*
    if ([forwardElem hasPrefix:@"image://"] || [forwardElem hasPrefix:@"video://"] ||[forwardElem hasPrefix:@"audio://"] ||[forwardElem hasPrefix:@"vcard://"] ||[forwardElem hasPrefix:@"loc://"] ||[forwardElem hasPrefix:@"friend://"] || [forwardElem hasPrefix:@"file://"] ) {
        [self composeMessage:nil richMessageKey:message];
    } else {
        [self composeMessage:message richMessageKey:nil];
    }
    

    [[C2CallPhone currentPhone] submitImage:forwardImage withQuality:UIImagePickerControllerQualityTypeHigh andMessage:nil toTarget:c2callID withCompletionHandler:nil];
     */
}

-(void) setRetransmitActionForCell:(MessageCell *) cell withKey:(NSString *) key andUserid:(NSString *) userid
{
    UIMenuController *menu = [UIMenuController sharedMenuController];
    NSMutableArray *menulist = [NSMutableArray arrayWithCapacity:5];
    
    UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Retransmit", @"MenuItem") action:@selector(retransmitAction:)];
    [cell setRetransmitAction:^{
        [[C2CallPhone currentPhone] submitRichMessage:key message:nil toTarget:userid];
    }];
    [menulist addObject:item];
    menu.menuItems = menulist;
    
    CGRect rect = cell.bubbleView.frame;
    rect = [cell convertRect:rect fromView:cell.bubbleView];
    [menu setTargetRect:rect inView:cell];
    [cell becomeFirstResponder];
    [menu setMenuVisible:YES animated:YES];
    
}

@end
