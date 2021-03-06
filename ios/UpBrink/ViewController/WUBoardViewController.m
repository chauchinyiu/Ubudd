//
//  SCBoardController.m
//  C2CallPhone
//
//  Created by Michael Knecht on 19.02.13.
//  Copyright 2013,2014 C2Call GmbH. All rights reserved.
//
//
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <AddressBookUI/AddressBookUI.h>
#import <QuickLook/QuickLook.h>
#import <MessageUI/MessageUI.h>
#import "WUBoardViewController.h"
#import <SocialCommunication/UIViewController+AdSpace.h>
#import <SocialCommunication/UIViewController+SCCustomViewController.h>
#import <SocialCommunication/C2CallConstants.h>
#import <SocialCommunication/SCBubbleViewIn.h>
#import <SocialCommunication/SCBubbleViewOut.h>
//#import <SocialCommunication/SIPHandler.h>
#import <SocialCommunication/SIPConstants.h>
#import <SocialCommunication/MessageCell.h>
#import <SocialCommunication/MessageCellInStream.h>
#import <SocialCommunication/MessageCellOutStream.h>
#import <SocialCommunication/ImageCellInStream.h>
#import <SocialCommunication/ImageCellOutStream.h>
#import <SocialCommunication/VideoCellInStream.h>
#import <SocialCommunication/VideoCellOutStream.h>
#import <SocialCommunication/LocationCellInStream.h>
#import <SocialCommunication/LocationCellOutStream.h>
#import <SocialCommunication/AudioCellInStream.h>
#import <SocialCommunication/AudioCellOutStream.h>
//#import <SocialCommunication/FileCellInStream.h>
//#import <SocialCommunication/FileCellOutStream.h>
#import <SocialCommunication/FriendCellInStream.h>
#import <SocialCommunication/FriendCellOutStream.h>
#import <SocialCommunication/ContactCellInStream.h>
#import <SocialCommunication/ContactCellOutStream.h>
#import <SocialCommunication/CallCellInStream.h>
#import <SocialCommunication/CallCellOutStream.h>
//#import <SocialCommunication/C2NetworkStatusHandler.h>
#import <SocialCommunication/AlertUtil.h>
#import <SocialCommunication/DateUtil.h>
#import <SocialCommunication/FCLocation.h>
//#import <SocialCommunication/FCMenuItem.h>
#import <SocialCommunication/ImageUtil.h>
#import <SocialCommunication/MOC2CallEvent.h>
#import <SocialCommunication/MOC2CallUser.h>
#import <SocialCommunication/MOCallHistory.h>
#import <SocialCommunication/MOChatHistory.h>
#import <SocialCommunication/MOPhoneNumber.h>
#import <SocialCommunication/FriendCellIn.h>
#import <SocialCommunication/FriendCellOut.h>
#import <SocialCommunication/C2TapImageView.h>
#import <SocialCommunication/C2ActionButton.h>
#import <SocialCommunication/SCComposeMessageController.h>
#import <SocialCommunication/C2CallAppDelegate.h>
#import <SocialCommunication/SCPhotoViewerController.h>
#import <SocialCommunication/SCVideoPlayerController.h>
#import <SocialCommunication/SCAudioPlayerController.h>
#import <SocialCommunication/SCLocationViewerController.h>
#import <SocialCommunication/SCPersonController.h>
#import <SocialCommunication/SCPopupMenu.h>
#import <SocialCommunication/SCDataManager.h>
#import <SocialCommunication/SCUserProfile.h>
#import <SocialCommunication/SIPPhone.h>

#import <SocialCommunication/IOS.h>
#import <SocialCommunication/debug.h>

@interface WUBoardViewController ()<MFMailComposeViewControllerDelegate, UINavigationControllerDelegate,NSFetchedResultsControllerDelegate, UITextFieldDelegate> {
    UIFont          *cellFont;
    NSLineBreakMode cellLBM;
    NSMutableArray					*animationIcon;
    
    CFAbsoluteTime lastContentChange, lastSearch;
    int     fetchLimit, fetchSize;
    BOOL    scrollToBottom, doUpdates, showPreviousMessageButton, isVisible, wasDontShowCallEvents;
    CGFloat messageInHeightOffset, messageOutHeightOffset, messageInMinHeight, messageOutMinHeight;
    
    CGFloat imageCellInHeight, videoCellInHeight, audioCellInHeight, locationCellInHeight, contactCellInHeight, friendCellInHeight, callCellInHeight;
    CGFloat imageCellOutHeight, videoCellOutHeight, audioCellOutHeight, locationCellOutHeight, contactCellOutHeight, friendCellOutHeight, callCellOutHeight;
    
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property(nonatomic, strong) UITableViewCell       *noFilterResultsCell;
@property(nonatomic, strong) UITableViewCell       *noMessageCell;

@property(nonatomic, strong) NSDate                         *lastIncomingMessage;

@property (nonatomic, strong) NSPredicate                    *activeFilter, *textFilter, *activeUser;
@property (nonatomic, strong) NSArray                        *filterList;
@property (nonatomic, strong) NSMutableDictionary           *smallImageCache;
@property (nonatomic, strong) UIFont                        *textFieldInFont, *headerFieldInFont, *textFieldOutFont, *headerFieldOutFont;
@property(nonatomic, strong) IBOutlet UILabel               *numSMS;
@property(nonatomic, strong) IBOutlet UILabel               *numChars;

-(void) setRetransmitActionForCell:(MessageCell *) cell withKey:(NSString *) key andUserid:(NSString *) userid;
-(void) shareMessageForKey:(NSString *) key;

@end

@implementation WUBoardViewController
@synthesize fetchedResultsController, managedObjectContext, targetUserid, activeUser;
@synthesize previousMessagesButton, headerView, numSMS, numChars, firstHeaderLabel, lastIncomingMessage;
@synthesize activeFilter, textFilter, filterList, filterButton, labelFilterInfo, filterInfoView;
@synthesize noFilterResultsCell, firstHeaderView, timestampHeader, timestampLabel, smallImageCache;
@synthesize textFieldInFont, textFieldOutFont, headerFieldInFont, headerFieldOutFont, activeFilterInfo, dontShowCallEvents;

-(NSFetchRequest *) fetchRequest
{
    if (![SCDataManager instance].isDataInitialized)
        return nil;
    
    self.sectionNameKeyPath = @"timeGroup";
    self.useDidChangeContentOnly = YES;
    
    NSFetchRequest *fetchRequest = [[SCDataManager instance] fetchRequestForEventHistory:nil sort:YES];
    
    if (self.targetUserid) {
        NSPredicate *predicate = nil;
        
        if (!dontShowCallEvents) {
            predicate = [NSPredicate predicateWithFormat:@"contact == %@", self.targetUserid];
        } else {
            predicate = [NSPredicate predicateWithFormat:@"contact == %@ AND eventType contains[cd] %@", self.targetUserid, @"message"];
        }
                
        [fetchRequest setPredicate:predicate];
        self.activeUser = predicate;
    }
    
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    int offset = 0;
    if (fetchLimit > 0) {
        offset = [[SCDataManager instance] setFetchLimit:fetchLimit forFetchRequest:fetchRequest];
    }
    
    showPreviousMessageButton = offset > 0;
    
    return fetchRequest;
}

-(void) refreshTable
{
    lastContentChange = CFAbsoluteTimeGetCurrent();
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (CFAbsoluteTimeGetCurrent() - lastContentChange > 0.15) {
            [self.tableView reloadData];
            
            if (scrollToBottom) {
                scrollToBottom = NO;
                [self scrollToBottom];
            }
        }
    });
}

-(void) refetchResults
{
    NSFetchRequest *fetchRequest = [self.fetchedResultsController fetchRequest];
    [fetchRequest setFetchLimit:0];
    [fetchRequest setFetchOffset:0];
    
    NSError *error = nil;
    int numElements = (int)[self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    int offset = MAX(0, numElements - fetchLimit);
    
    [fetchRequest setFetchLimit:fetchLimit];
    [fetchRequest setFetchOffset:offset];
    showPreviousMessageButton = offset > 0;
    
    error = nil;
    [self.fetchedResultsController performFetch:&error];
    if (error) {
        DLog(@"Error : %@", error);
    }
    
    [self refreshFilterInfo];
    [self refreshTable];
}

-(void) resetLimits
{
    fetchLimit = 25;
    fetchSize = 25;
}

- (UIView *)findFirstResponder:(UIView *) startView
{
    if (startView.isFirstResponder) {
        return startView;
    }
    
    for (UIView *subView in startView.subviews) {
        UIView *firstResponder = [self findFirstResponder:subView];
        
        if (firstResponder != nil) {
            return firstResponder;
        }
    }
    
    return nil;
}

-(void) refreshBadgeValue
{
    int missedEvents = [[SCDataManager instance] totalMissedCalls] + [[SCDataManager instance] totalMissedMessages];
    
    UITabBarItem *item = self.navigationController.tabBarItem;
    
    if (missedEvents == 0){
        item.badgeValue = nil;
    }
    else{
        item.badgeValue = [NSString stringWithFormat:@"%d", missedEvents];
    }
    [[C2CallPhone currentPhone] refreshApplicationBadgeNumber];
}

-(void) refreshSearchButton
{
}

-(void) awakeFromNib
{
    [super awakeFromNib];
    
    [self resetLimits];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    DLog(@"SCBoardController:viewDidLoad : %@", self.targetUserid);
    
    self.headerView.translatesAutoresizingMaskIntoConstraints = YES;
    
    // Initialize Font for TextBubble
    MessageCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MessageCellInStream"];
    self.textFieldInFont = cell.textfield.font;
    self.headerFieldInFont = cell.headline.font;
    
    DLog(@"textFieldInFont : %@", self.textFieldInFont);
    DLog(@"headerFieldInFont : %@", self.headerFieldInFont);
    
    self.noFilterResultsCell = [self.tableView dequeueReusableCellWithIdentifier:@"SCNoFilterResultsCell"];
    self.noMessageCell = [self.tableView dequeueReusableCellWithIdentifier:@"SCNoMessagesCell"];
    
    CGRect cellFrame = cell.frame;
    CGRect bubbleFrame = cell.bubbleView.frame;
    CGRect textFrame = cell.textfield.frame;
    
    DLog(@"CellFrame Height : %f", cellFrame.size.height);
    DLog(@"BubbleFrame Height : %f / %f", bubbleFrame.origin.y, bubbleFrame.size.height);
    DLog(@"TextFrame Height : %f / %f", textFrame.origin.y, textFrame.size.height);
    
    messageInMinHeight = cellFrame.size.height;
    messageInHeightOffset = 0 + bubbleFrame.origin.y + textFrame.origin.y;
    messageInHeightOffset += cellFrame.size.height - (bubbleFrame.size.height + bubbleFrame.origin.y);
    messageInHeightOffset += bubbleFrame.size.height - (textFrame.size.height + textFrame.origin.y);
    
    
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"MessageCellOutStream"];
    self.textFieldOutFont = cell.textfield.font;
    self.headerFieldOutFont = cell.headline.font;
    DLog(@"textFieldOutFont : %@", self.textFieldOutFont);
    DLog(@"headerFieldOutFont : %@", self.headerFieldOutFont);
    
    cellFrame = cell.frame;
    bubbleFrame = cell.bubbleView.frame;
    textFrame = cell.textfield.frame;
    
    messageOutMinHeight = cellFrame.size.height;
    messageOutHeightOffset = 0 + bubbleFrame.origin.y + textFrame.origin.y;
    messageOutHeightOffset += cellFrame.size.height - (bubbleFrame.size.height + bubbleFrame.origin.y);
    messageOutHeightOffset += bubbleFrame.size.height - (textFrame.size.height + textFrame.origin.y);
    
    [self calcHeight];
    
    DLog(@"MessageCell Offset Height : %f / %f", messageInHeightOffset, messageOutHeightOffset);
    
    if (!self.smallImageCache) {
        self.smallImageCache = [NSMutableDictionary dictionaryWithCapacity:50];
    }
    
    cellLBM = NSLineBreakByWordWrapping;
    
    //self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_kork.png"]];
    
    animationIcon = [[NSMutableArray alloc] initWithCapacity:4];
    for (int i = 0; i < 4; i++) {
        [animationIcon addObject:[UIImage imageNamed:[NSString stringWithFormat:@"ico_sending_%d.png", i]]];
    }
    
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    scrollToBottom = YES;
    
    [self resetLimits];
    if (!self.fetchedResultsController && [SCDataManager instance].isDataInitialized) {
        [self refreshTable];
        [self refreshBadgeValue];
    }
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handleNotificationEvent:) name:@"UserImageUpdate" object:nil];
    [nc addObserver:self selector:@selector(handleNotificationEvent:) name:@"C2Call:LogoutUser" object:nil];
    [nc addObserver:self selector:@selector(handleNotificationEvent:) name:@"TransferCompleted" object:nil];
    [nc addObserver:self selector:@selector(handleNotificationEvent:) name:@"UIApplicationDidEnterBackgroundNotification" object:nil];
    
    [self refreshSearchButton];
    
    [self.previousMessagesButton setTitle:NSLocalizedString(@"Show previous messages", @"Button") forState:UIControlStateNormal];
    
    NSMutableDictionary *all = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"All", @"Filter"), @"name", @"allFilter", @"filter", nil];
    NSMutableDictionary *image = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Images", @"Filter"), @"name", @"imageFilter", @"filter", nil];
    NSMutableDictionary *video = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Videos", @"Filter"), @"name", @"videoFilter", @"filter", nil];
    NSMutableDictionary *location = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Locations", @"Filter"), @"name", @"locationFilter", @"filter", nil];
    NSMutableDictionary *audio = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Voice Mails", @"Filter"), @"name", @"audioFilter", @"filter", nil];
    NSMutableDictionary *calls = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Calls", @"Filter"), @"name", @"callFilter", @"filter", nil];
    NSMutableDictionary *missed = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Missed", @"Filter"), @"name", @"missedFilter", @"filter", nil];
    
    self.filterList = [NSArray arrayWithObjects:all, image, video, location, audio, calls, missed, nil];
    
    int active = 0;//[[[NSUserDefaults standardUserDefaults] objectForKey:@"activeStreamFilter"] intValue];
    if (active >= [self.filterList count])
        active = 0;
    
    [[self.filterList objectAtIndex:active] setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    if (self.fetchedResultsController) {
        self.fetchedResultsController.delegate = nil;
        self.fetchedResultsController = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.smallImageCache = nil;
    self.tableView = nil;
    self.previousMessagesButton = nil;
    self.headerView = nil;
    self.firstHeaderLabel = nil;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    isVisible = YES;
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController setToolbarHidden:YES animated:NO];
    [self refreshSearchButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    @try {
        int sections = (int)[self.tableView numberOfSections];
        if (sections == 0)
            return;
        
        int rows = (int)[self.tableView numberOfRowsInSection:sections - 1];
        
        if (rows == 0)
            return;
        
        if (scrollToBottom) {
            scrollToBottom = NO;
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self scrollToBottom];
            });
        }
    }
    @finally {
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    isVisible = NO;
    
    UIView *firstResponder = [self findFirstResponder:self.view];
    [firstResponder resignFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) scrollToBottom
{
    
    double delayInSeconds = 0.05;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        int section = (int)self.tableView.numberOfSections - 1;
        int row =  (int)[self.tableView numberOfRowsInSection:section] - 1;
        if (section >= 0 && row >= 0)
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    });
}

-(void) handleNotificationEvent:(NSNotification *) notification
{
    DLog(@"C2MessageController:handleEvent : %@:%@", [notification name], [notification userInfo]);
    
    @try {
        if ([[notification name] isEqualToString:@"C2Call:LogoutUser"]) {
            self.fetchedResultsController.delegate = nil;
            self.fetchedResultsController = nil;
            [self refreshTable];
        }
        
        if ([[notification name] isEqualToString:@"UserImageUpdate"]) {
            [self.smallImageCache removeAllObjects];
            [self refreshTable];
        }
        
        if ([[notification name] isEqualToString:@"TransferCompleted"]) {
            [self refreshTable];
        }
        
        if ([[notification name] isEqualToString:@"UIApplicationDidEnterBackgroundNotification"]) {
            if ([SCDataManager instance].isDataInitialized && self.fetchedResultsController && fetchLimit > 25) {
                [self resetLimits];
                [self refetchResults];
            }
        }
    }
    @catch (NSException * e) {
        DLog(@"SCBoardController : %@", e);
    }
    
}

-(void) calcHeight
{
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"ImageCellInStream"];
    imageCellInHeight = cell.frame.size.height;
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"VideoCellInStream"];
    videoCellInHeight = cell.frame.size.height;
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"AudioCellInStream"];
    audioCellInHeight = cell.frame.size.height;
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"LocationCellInStream"];
    locationCellInHeight = cell.frame.size.height;
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"ContactCellInStream"];
    contactCellInHeight = cell.frame.size.height;
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"FriendCellInStream"];
    friendCellInHeight = cell.frame.size.height;
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"CallCellInStream"];
    callCellInHeight = cell.frame.size.height;
    
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"ImageCellOutStream"];
    imageCellOutHeight = cell.frame.size.height;
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"VideoCellOutStream"];
    videoCellOutHeight = cell.frame.size.height;
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"AudioCellOutStream"];
    audioCellOutHeight = cell.frame.size.height;
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"LocationCellOutStream"];
    locationCellOutHeight = cell.frame.size.height;
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"ContactCellOutStream"];
    contactCellOutHeight = cell.frame.size.height;
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"FriendCellOutStream"];
    friendCellOutHeight = cell.frame.size.height;
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"CallCellOutStream"];
    callCellOutHeight = cell.frame.size.height;
    
}

-(NSString *) identifierForElement:(MOC2CallEvent *) elem
{
    NSString *eventType = elem.eventType;
    NSString *text = elem.text;
    NSString *cellIdentifier = nil;
    
    DLog(@"EventType : %@", eventType);
    if ([eventType isEqualToString:@"CallIn"]) {
        cellIdentifier = @"CallCellInStream";
    } else if ([eventType isEqualToString:@"CallOut"]) {
        cellIdentifier = @"CallCellOutStream";
    } else if ([eventType isEqualToString:@"MessageOut"] || [eventType isEqualToString:@"MessageSubmit"]) {
        cellIdentifier = @"MessageCellOutStream";
        
        if ([text hasPrefix:@"image://"]) {
            cellIdentifier = @"ImageCellOutStream";
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
        cellIdentifier = @"MessageCellInStream";
        
        if ([text hasPrefix:@"image://"]) {
            cellIdentifier = @"ImageCellInStream";
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
    
    return cellIdentifier;
}

-(void) scrollTop
{
    @try {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    @catch (NSException *exception) {
        
    }
}

#pragma mark - Table view data source

-(CGFloat) messageCellInHeight:(MOC2CallEvent *) elem font:(UIFont *) font
{
    CGSize maximumLabelSize = CGSizeMake(220,9999);
    
    CGSize expectedLabelSize = [elem.text sizeWithFont:font
                                     constrainedToSize:maximumLabelSize
                                         lineBreakMode:cellLBM];
    
    CGFloat sz = expectedLabelSize.height + messageInHeightOffset;
    if (sz < messageInMinHeight)
        sz = messageInMinHeight;
    
    DLog(@"messageCellInHeight : %@ \nH : %f / %fx%f", elem.text, sz, expectedLabelSize.width, expectedLabelSize.height);
    return sz;
}

-(CGFloat) messageCellOutHeight:(MOC2CallEvent *) elem font:(UIFont *) font
{
    CGSize maximumLabelSize = CGSizeMake(220,9999);
    
    CGSize expectedLabelSize = [elem.text sizeWithFont:font
                                     constrainedToSize:maximumLabelSize
                                         lineBreakMode:cellLBM];
    
    CGFloat sz = expectedLabelSize.height + messageOutHeightOffset;
    if (sz < messageOutMinHeight)
        sz = messageOutMinHeight;
    
    DLog(@"messageCellOutHeight : %f / %fx%f", sz, expectedLabelSize.width, expectedLabelSize.height);
    
    return sz;
}

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"heightForRowAtIndexPath : %d / %d ", indexPath.section, indexPath.row);
    if ([SCDataManager instance].isDataInitialized && [[self.fetchedResultsController fetchedObjects] count] == 0) {
        if (self.activeFilter || self.textFilter) {
            return self.noFilterResultsCell.frame.size.height;
        } else {
            return self.noMessageCell.frame.size.height;
        }
    }
    
    MOC2CallEvent *elem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *identifier = [self identifierForElement:elem];
    
    if ([identifier isEqualToString:@"MessageCellInStream"]) {
        return [self messageCellInHeight:elem font:self.textFieldInFont];
    }
    if ([identifier isEqualToString:@"MessageCellOutStream"]) {
        return [self messageCellOutHeight:elem font:self.textFieldOutFont];
    }
    
    if ([identifier isEqualToString:@"VideoCellInStream"]) {
        return videoCellInHeight;
    }
    if ([identifier isEqualToString:@"VideoCellOutStream"]) {
        return videoCellOutHeight;
    }
    
    if ([identifier isEqualToString:@"ImageCellInStream"]) {
        return imageCellInHeight;
    }
    if ([identifier isEqualToString:@"ImageCellOutStream"]) {
        return imageCellOutHeight;
    }
    
    if ([identifier isEqualToString:@"LocationCellInStream"]) {
        return locationCellInHeight;
    }
    if ([identifier isEqualToString:@"LocationCellOutStream"]) {
        return locationCellOutHeight;
    }
    
    if ([identifier isEqualToString:@"AudioCellInStream"]) {
        return audioCellInHeight;
    }
    if ([identifier isEqualToString:@"AudioCellOutStream"]) {
        return audioCellOutHeight;
    }
    
    if ([identifier isEqualToString:@"FileCellInStream"]) {
        return 105.;
    }
    if ([identifier isEqualToString:@"FileCellOutStream"]) {
        return 105.;
    }
    
    if ([identifier isEqualToString:@"FriendCellInStream"]) {
        return friendCellInHeight;
    }
    if ([identifier isEqualToString:@"FriendCellOutStream"]) {
        return friendCellOutHeight;
    }
    
    if ([identifier isEqualToString:@"ContactCellInStream"]) {
        return contactCellInHeight;
    }
    if ([identifier isEqualToString:@"ContactCellOutStream"]) {
        return contactCellOutHeight;
    }
    
    if ([identifier isEqualToString:@"CallCellInStream"]) {
        return callCellInHeight;
    }
    if ([identifier isEqualToString:@"CallCellOutStream"]) {
        return callCellOutHeight;
    }
    
    
    return 44.;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        CGRect f = self.headerView.frame;
        
        if (showPreviousMessageButton) {
            
            self.previousMessagesButton.hidden = NO;
            if (!self.filterInfoView.hidden) {
                f.size.height = 111.;
                self.headerView.frame = f;
                return 111;
            }
            
            f.size.height = 67.;
            self.headerView.frame = f;
            return 67.;
        }
        self.previousMessagesButton.hidden = YES;
        
        if (!self.filterInfoView.hidden) {
            f.size.height = 60.;
            self.headerView.frame = f;
            
            return 60;
        }
        
        f.size.height = 22.;
        self.headerView.frame = f;
        
        return 22;
    }
    
    return 20.;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    DLog(@"viewForHeaderInSection : %d", section);
    
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
        self.firstHeaderLabel.text = @"";
        self.firstHeaderView.hidden = YES;
        return headerView;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    MOC2CallEvent *elem = nil;
    @try {
        elem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    @catch (NSException *exception) {
    }
    
    if (section == 0 && elem) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        self.firstHeaderLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:elem.timeStamp]];
        self.firstHeaderView.hidden = NO;
        return self.headerView;
    }
    
    if (elem) {
        if (self.timestampHeader) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            
            self.timestampLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:elem.timeStamp]];
            
            NSData *archivedViewData = [NSKeyedArchiver archivedDataWithRootObject: self.timestampHeader];
            id clone = [NSKeyedUnarchiver unarchiveObjectWithData:archivedViewData];
            return (UIView *) clone;
        }
        
        /*
         
         CGRect bounds = self.tableView.bounds;
         UIView *h = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, 20.)];
         
         UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_timestamp.png"]];
         CGRect bgFrame = bg.frame;
         bgFrame.origin.x = (bounds.size.width / 2.) - (bgFrame.size.width / 2.);
         bgFrame.origin.y = 0;
         bg.frame = bgFrame;
         [h addSubview:bg];
         
         UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(bgFrame.origin.x + 4, -1, 102, 20.)];
         label.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:elem.timeStamp]];
         label.textAlignment = UITextAlignmentCenter;
         label.textColor = [UIColor lightTextColor];
         label.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:0x11/255. green:0x1e/255. blue:0x36/255. alpha:0.2];
         label.font = [UIFont fontWithName:@"Helvetica" size:12.];
         [h addSubview:label];
         */
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor colorWithWhite:0. alpha:0.];
    label.text = @"";
    
    return label;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor colorWithWhite:0. alpha:0.];
    
    label.text = @"";
    return label;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
        return 1;
    }
    
    return [[self.fetchedResultsController sections] count];
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

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
    if (![SCDataManager instance].isDataInitialized) {
        return 0;
    }
    
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
        return 1;
    }
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"willDisplayCell : %d, %d", indexPath.section, indexPath.row);
    
    UIView *bv = [self findBubbleView:cell];
    [bv setNeedsLayout];
    
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
        
        [self showPhotos:imageList currentPhoto:key];
    }
    @catch (NSException *exception) {
        
    }
}

#pragma mark Configure Cells

-(void) setSubmittedStatusIcon:(MessageCell *) cell forStatus:(int) messageStatus
{
    cell.iconSubmitted.animationImages = nil;
    
    switch (messageStatus) {
        case 1:
            cell.iconSubmitted.image = nil;
            cell.iconSubmitted.animationImages = animationIcon;
            cell.iconSubmitted.animationDuration = 1.5;
            [cell.iconSubmitted startAnimating];
            [cell.iconSubmitted setHidden:NO];
            break;
        case 2:
            cell.iconSubmitted.image = [UIImage imageNamed:@"ico_deliverd.png"];
            [cell.iconSubmitted setHidden:NO];
            break;
        case 3:
            cell.iconSubmitted.image = [UIImage imageNamed:@"ico_notdelivered.png"];
            [cell.iconSubmitted setHidden:NO];
            break;
        case 4:
            cell.iconSubmitted.image = [UIImage imageNamed:@"ico_read.png"];
            [cell.iconSubmitted setHidden:NO];
            break;
        default:
            [cell.iconSubmitted setHidden:YES];
            break;
    }
    
}

-(UIImage *) ownUserImage
{
    UIImage *image = [self.smallImageCache objectForKey:[SCUserProfile currentUser].userid];
    if (image)
        return image;
    
    image = [[C2CallPhone currentPhone] userimageForUserid:[SCUserProfile currentUser].userid];
    if (image) {
        image = [ImageUtil thumbnailFromImage:image withSize:35. andCornerRadius:0];
        [self.smallImageCache setObject:image forKey:[SCUserProfile currentUser].userid];
        return image;
    }
    
    image = [UIImage imageNamed:@"btn_ico_avatar.png"];
    image = [ImageUtil thumbnailFromImage:image withSize:35. andCornerRadius:0];
    [self.smallImageCache setObject:image forKey:[SCUserProfile currentUser].userid];
    return image;
}

-(BOOL) isPhoneNumber:(NSString *) uid
{
    if ([uid hasPrefix:@"+"] && [uid rangeOfString:@"@"].location == NSNotFound) {
        return YES;
    }
    return NO;
}

-(UIImage *) imageForElement:(MOC2CallEvent *) elem
{
    UIImage *image = [self.smallImageCache objectForKey:elem.contact];
    if (image)
        return image;
    
    image = [[C2CallPhone currentPhone] userimageForUserid:elem.contact];
    if (image) {
        image = [ImageUtil thumbnailFromImage:image withSize:35. andCornerRadius:0];
        [self.smallImageCache setObject:image forKey:elem.contact];
        return image;
    }
    
    if ([self isPhoneNumber:elem.contact]) {
        image = [UIImage imageNamed:@"btn_ico_adressbook_contact.png"];
        image = [ImageUtil thumbnailFromImage:image withSize:35. andCornerRadius:0];
        [self.smallImageCache setObject:image forKey:elem.contact];
        return image;
    }
    
    MOC2CallUser *user = [[SCDataManager instance] userForUserid:elem.contact];
    if ([user.userType intValue] == 2) {
        image = [UIImage imageNamed:@"btn_ico_avatar_group.png"];
        image = [ImageUtil thumbnailFromImage:image withSize:35. andCornerRadius:0];
        [self.smallImageCache setObject:image forKey:elem.contact];
        return image;
        
    }
    
    image = [UIImage imageNamed:@"btn_ico_avatar.png"];
    image = [ImageUtil thumbnailFromImage:image withSize:35. andCornerRadius:0];
    [self.smallImageCache setObject:image forKey:elem.contact];
    return image;
}

-(void) setUserImageAction:(C2TapImageView *) imageView forElement:(MOC2CallEvent *) elem
{
    // TODO - setUserImage Action
    /*
     [imageView setTapAction:^(){
     [self showMessagesForUser:elem.contact];
     }];
     
     [imageView setLongpressAction:^(){
     [self showUserProfile:elem.contact];
     }];
     */
    
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
        bv.textFont = textFieldInFont;
        bv.textFont = [UIFont fontWithName:bv.textFont.fontName size:[UIFont preferredFontForTextStyle:UIFontTextStyleBody].pointSize];
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
    CGSize maximumLabelSize = CGSizeMake(220,9999);
    
    //    dispatch_async(dispatch_get_main_queue(), ^(){
    CGSize expectedLabelSize = [text sizeWithFont:self.textFieldInFont
                                constrainedToSize:maximumLabelSize
                                    lineBreakMode:cellLBM];
    
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
                                           lineBreakMode:cellLBM];
        sendernameSize.width += diffHeaderLeft + diffHeaderRight;
        
        if (sendernameSize.width > width) {
            DLog(@"senderName width : %f / %f", sendernameSize.width, width);
            width = sendernameSize.width;
        }
    }
    
    if (width < 67.0)
        width = 67.0;
    
    DLog(@"messageCellInWidth : %f", width);
    
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
            DLog(@"messageCellIn contraints : %f / %f / %f / %f", frame.origin.x, frame.origin.y,  frame.size.width, frame.size.height);
            bubble.width.constant = frame.size.width;
            bubble.left.constant = frame.origin.x;
            bubble.top.constant = -150;
            //frame.origin.y;
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
        bv.textFont = textFieldOutFont;
        bv.textFont = [UIFont fontWithName:bv.textFont.fontName size:[UIFont preferredFontForTextStyle:UIFontTextStyleBody].pointSize];
        
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
    CGSize maximumLabelSize = CGSizeMake(220,9999);
    
    //    dispatch_async(dispatch_get_main_queue(), ^(){
    CGSize expectedLabelSize = [text sizeWithFont:self.textFieldOutFont
                                constrainedToSize:maximumLabelSize
                                    lineBreakMode:cellLBM];
    
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
                                           lineBreakMode:cellLBM];
        sendernameSize.width += diffHeaderLeft + diffHeaderRight;
        
        if (sendernameSize.width > width) {
            width = sendernameSize.width;
        }
    }
    
    
    //    if ([elem.missedDisplay boolValue])
    //        width += 5;
    
    if (width < 67.0)
        width = 67.0;
    
    DLog(@"messageCellOutWidth : %f", width);
    
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
            DLog(@"messageCellOut contraints : %f / %f / %f / %f", frame.origin.x, frame.origin.y,  frame.size.width, frame.size.height);
            
            bubble.width.constant = frame.size.width;
            bubble.left.constant = frame.origin.x;
            bubble.top.constant = frame.origin.y;
        } else {
            cell.bubbleView.frame = frame;
        }
    }
    
    [self setSubmittedStatusIcon:cell forStatus:[elem.status intValue]];
}

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
        cell.messageImage.image = [[C2CallPhone currentPhone] thumbnailForKey:text];
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

-(void) configureVideoCellIn:(__weak VideoCellInStream *) cell forEvent:(MOC2CallEvent *) elem atIndexPath:(NSIndexPath *) indexPath
{
    NSString *text = elem.text;
    
    cell.headline.text = elem.senderName?elem.senderName : [[C2CallPhone currentPhone] nameForUserid:elem.contact];
    cell.userImage.image = [self imageForElement:elem];
    [self setUserImageAction:cell.userImage forElement:elem];
    cell.imageNewIndicator.hidden = ![elem.missedDisplay boolValue];
    
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
        
        
        cell.downloadKey = text;
        
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
            [self showVideo:text];
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
            
            menu.menuItems = menulist;
            CGRect rect = cell.messageImage.frame;
            rect = [cell convertRect:rect fromView:cell.messageImage];
            [menu setTargetRect:rect inView:cell];
            [cell becomeFirstResponder];
            [menu setMenuVisible:YES animated:YES];
        }];
    }
    
    [self setSubmittedStatusIcon:cell forStatus:[elem.status intValue]];
}

-(void) configureLocationCellIn:(__weak LocationCellInStream *) cell forEvent:(MOC2CallEvent *) elem atIndexPath:(NSIndexPath *) indexPath
{
    NSString *text = elem.text;
    
    cell.headline.text = elem.senderName?elem.senderName : [[C2CallPhone currentPhone] nameForUserid:elem.contact];
    cell.userImage.image = [self imageForElement:elem];
    [self setUserImageAction:cell.userImage forElement:elem];
    cell.imageNewIndicator.hidden = ![elem.missedDisplay boolValue];
    
    FCLocation *loc = [[FCLocation alloc] initWithKey:text];
    [cell retrieveLocation:loc];
    
    [cell setOpenLocationAction:^{
        if (cell.locationUrl) {
            NSString *name = [loc.place objectForKey:@"name"];
            [self openBrowserWithUrl:cell.locationUrl andTitle:name];
        }
    }];
    
    
    [cell setTapAction:^{
        [self showLocation:text forUser:cell.headline.text];
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
        
        
        menu.menuItems = menulist;
        CGRect rect = cell.bubbleView.frame;
        rect = [cell convertRect:rect fromView:cell.bubbleView];
        [menu setTargetRect:rect inView:cell];
        [cell becomeFirstResponder];
        [menu setMenuVisible:YES animated:YES];
    }];
    
    
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
        
        
        menu.menuItems = menulist;
        CGRect rect = cell.bubbleView.frame;
        rect = [cell convertRect:rect fromView:cell.bubbleView];
        [menu setTargetRect:rect inView:cell];
        [cell becomeFirstResponder];
        [menu setMenuVisible:YES animated:YES];
    }];
    
    [self setSubmittedStatusIcon:cell forStatus:[elem.status intValue]];
}

-(void) configureAudioCellIn:(__weak AudioCellInStream *) cell forEvent:(MOC2CallEvent *) elem atIndexPath:(NSIndexPath *) indexPath
{
    NSString *text = elem.text;
    
    cell.headline.text = elem.senderName?elem.senderName : [[C2CallPhone currentPhone] nameForUserid:elem.contact];
    cell.userImage.image = [self imageForElement:elem];
    [self setUserImageAction:cell.userImage forElement:elem];
    cell.imageNewIndicator.hidden = ![elem.missedDisplay boolValue];
    
    BOOL failed = NO;
    
    if ([[C2CallPhone currentPhone] hasObjectForKey:text]) {
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
                
                
                menu.menuItems = menulist;
                
                CGRect rect = cell.messageImage.frame;
                rect = [cell convertRect:rect fromView:cell.messageImage];
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
            
            menu.menuItems = menulist;
            CGRect rect = cell.messageImage.frame;
            rect = [cell convertRect:rect fromView:cell.messageImage];
            [menu setTargetRect:rect inView:cell];
            [cell becomeFirstResponder];
            [menu setMenuVisible:YES animated:YES];
        }];
    }
    
    [self setSubmittedStatusIcon:cell forStatus:[elem.status intValue]];
}

-(void) configureFriendCellIn:(__weak FriendCellInStream *) cell forEvent:(MOC2CallEvent *) elem atIndexPath:(NSIndexPath *) indexPath
{
    NSString *text = elem.text;
    
    cell.headline.text = elem.senderName?elem.senderName : [[C2CallPhone currentPhone] nameForUserid:elem.contact];
    cell.userImage.image = [self imageForElement:elem];
    [self setUserImageAction:cell.userImage forElement:elem];
    cell.imageNewIndicator.hidden = ![elem.missedDisplay boolValue];
    
    if ([cell isKindOfClass:[FriendCellIn class]]) {
        [(FriendCellIn *)cell setFriend:text];
    }
    if ([cell isKindOfClass:[FriendCellOut class]]) {
        [(FriendCellOut *)cell setFriend:text];
    }
    
    [cell setLongpressAction:^{
        UIMenuController *menu = [UIMenuController sharedMenuController];
        NSMutableArray *menulist = [NSMutableArray arrayWithCapacity:5];
        
        UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Forward", @"MenuItem") action:@selector(forwardAction:)];
        [cell setForwardAction:^{
            [self forwardMessage:text];
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
        
        
        menu.menuItems = menulist;
        CGRect rect = cell.bubbleView.frame;
        rect = [cell convertRect:rect fromView:cell.bubbleView];
        [menu setTargetRect:rect inView:cell];
        [cell becomeFirstResponder];
        [menu setMenuVisible:YES animated:YES];
    }];
    
    [self setSubmittedStatusIcon:cell forStatus:[elem.status intValue]];
    
}

-(void) configureContactCellIn:(__weak ContactCellInStream *) cell forEvent:(MOC2CallEvent *) elem atIndexPath:(NSIndexPath *) indexPath
{
    NSString *text = elem.text;
    
    cell.headline.text = elem.senderName?elem.senderName : [[C2CallPhone currentPhone] nameForUserid:elem.contact];
    cell.userImage.image = [self imageForElement:elem];
    [self setUserImageAction:cell.userImage forElement:elem];
    cell.imageNewIndicator.hidden = ![elem.missedDisplay boolValue];
    
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
        
        
        menu.menuItems = menulist;
        CGRect rect = cell.bubbleView.frame;
        rect = [cell convertRect:rect fromView:cell.bubbleView];
        [menu setTargetRect:rect inView:cell];
        [cell becomeFirstResponder];
        [menu setMenuVisible:YES animated:YES];
    }];
    
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
        
        
        menu.menuItems = menulist;
        CGRect rect = cell.bubbleView.frame;
        rect = [cell convertRect:rect fromView:cell.bubbleView];
        [menu setTargetRect:rect inView:cell];
        [cell becomeFirstResponder];
        [menu setMenuVisible:YES animated:YES];
    }];
    
    [self setSubmittedStatusIcon:cell forStatus:[elem.status intValue]];
}

-(void) configureCallCellIn:(CallCellInStream *) cell forEvent:(MOC2CallEvent *) elem atIndexPath:(NSIndexPath *) indexPath
{
    
    cell.headline.text = elem.senderName?elem.senderName : [[C2CallPhone currentPhone] nameForUserid:elem.contact];
    
    cell.userImage.image = [self imageForElement:elem];
    [self setUserImageAction:cell.userImage forElement:elem];
    cell.imageNewIndicator.hidden = ![elem.missedDisplay boolValue];
    
    
    [cell.btnCall addAction:^(id sender) {
        if ([[C2CallPhone currentPhone] isGroupUser:elem.contact]) {
            [[SIPPhone currentPhone] callVoIP:elem.contact groupCall:YES];
        } else {
            [[SIPPhone currentPhone] callVoIP:elem.contact groupCall:NO];
        }
    }];
    
    [cell.btnVideoCall addAction:^(id sender) {
        if ([[C2CallPhone currentPhone] isGroupUser:elem.contact]) {
            [[SIPPhone currentPhone] callVideo:elem.contact groupCall:YES];
        } else {
            [[SIPPhone currentPhone] callVideo:elem.contact groupCall:NO];
        }
    }];
    
    [cell.btnChat addAction:^(id sender) {
        [self showMessagesForUser:elem.contact];
    }];
    
    
    if ([elem.status intValue] == 2) {
        cell.callStatusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Call at %@", @"CallStatusLabel"), @"00:00"];
    } else {
        cell.callStatusLabel.text = NSLocalizedString(@"Missed call!", @"CallStatusLabel");
    }
    
    BOOL missed = NO;
    if (elem.lastCall.lastMissedEvent) {
        if ([elem.status intValue] == 3 && [elem.timeStamp compare:elem.lastCall.lastMissedEvent] != NSOrderedAscending) {
            missed = YES;
        }
    }
    
    if ([elem.status intValue] == 2) {
        cell.iconCallStatus.image = [UIImage imageNamed:@"ico_call_in.png"];
    } else {
        cell.iconCallStatus.image = [UIImage imageNamed:@"ico_call_in_x.png"];
    }
    
}

-(void) configureCallCellOut:(CallCellOutStream *) cell forEvent:(MOC2CallEvent *) elem atIndexPath:(NSIndexPath *) indexPath
{
    cell.headline.text = elem.senderName?elem.senderName : [[C2CallPhone currentPhone] nameForUserid:elem.contact];
    cell.userImage.image = [self ownUserImage];
    [self setUserImageAction:cell.userImage forElement:elem];
    
    UIImage *contactImage =  [[C2CallPhone currentPhone] userimageForUserid:elem.contact];
    
    SCBubbleViewOut *bubble = nil;
    if ([cell.bubbleView isKindOfClass:[SCBubbleViewOut class]]) {
        bubble = (SCBubbleViewOut *) cell.bubbleView;
    }
    
    
    if (contactImage) {
        /*
         CGFloat width = 240.;
         if (bubble.width) {
         bubble.width.constant = 240.;
         } else {
         CGRect frame = cell.bubbleView.frame;
         
         CGFloat diff = frame.size.width - width;
         frame.size.width = width;
         frame.origin.x += diff;
         
         if (diff != 0.) {
         cell.bubbleView.frame = frame;
         [cell.bubbleView setNeedsDisplay];
         }
         }
         */
        cell.messageImage.image = contactImage;
    } else {
        /*
         if (bubble.width) {
         bubble.width.constant = 193.;
         } else {
         CGFloat width = 193.;
         CGRect frame = cell.bubbleView.frame;
         
         CGFloat diff = frame.size.width - width;
         frame.size.width = width;
         frame.origin.x += diff;
         
         if (diff != 0.) {
         cell.bubbleView.frame = frame;
         [cell.bubbleView setNeedsDisplay];
         }
         }
         */
        cell.messageImage.image = [UIImage imageNamed:@"btn_ico_avatar.png"];
    }
    
    [cell.btnCall addAction:^(id sender) {
        if ([[C2CallPhone currentPhone] isGroupUser:elem.contact]) {
            [[SIPPhone currentPhone] callVoIP:elem.contact groupCall:YES];
        } else {
            [[SIPPhone currentPhone] callVoIP:elem.contact groupCall:NO];
        }
    }];
    
    [cell.btnVideoCall addAction:^(id sender) {
        if ([[C2CallPhone currentPhone] isGroupUser:elem.contact]) {
            [[SIPPhone currentPhone] callVideo:elem.contact groupCall:YES];
        } else {
            [[SIPPhone currentPhone] callVideo:elem.contact groupCall:NO];
        }
    }];
    
    [cell.btnChat addAction:^(id sender) {
        [self showMessagesForUser:elem.contact];
    }];
    
    [self setSubmittedStatusIcon:cell forStatus:[elem.status intValue]];
    
    
    if ([elem.status intValue] == 2) {
        cell.iconCallStatus.image = [UIImage imageNamed:@"ico_call_out.png"];
    } else {
        cell.iconCallStatus.image = [UIImage imageNamed:@"ico_call_out_x.png"];
    }
    
}


-(void) configureCell:(MessageCell *) cell atIndexPath:(NSIndexPath *) indexPath
{
    // Set up the cell...
    MOC2CallEvent *elem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[MessageCellInStream class]]) {
        [self configureMessageCellIn:(MessageCellInStream *) cell forEvent:elem atIndexPath:indexPath];
    }
    
    if ([cell isKindOfClass:[MessageCellOutStream class]]) {
        [self configureMessageCellOut:(MessageCellOutStream *) cell forEvent:elem atIndexPath:indexPath];
    }
    
    if ([cell isKindOfClass:[ImageCellInStream class]]) {
        [self configureImageCellIn:(ImageCellInStream *) cell forEvent:elem atIndexPath:indexPath];
    }
    
    if ([cell isKindOfClass:[ImageCellOutStream class]]) {
        [self configureImageCellOut:(ImageCellOutStream *) cell forEvent:elem atIndexPath:indexPath];
    }
    
    if ([cell isKindOfClass:[VideoCellInStream class]]) {
        [self configureVideoCellIn:(VideoCellInStream *) cell forEvent:elem atIndexPath:indexPath];
    }
    
    if ([cell isKindOfClass:[VideoCellOutStream class]]) {
        [self configureVideoCellOut:(VideoCellOutStream *) cell forEvent:elem atIndexPath:indexPath];
    }
    
    if ([cell isKindOfClass:[LocationCellInStream class]]) {
        [self configureLocationCellIn:(LocationCellInStream *) cell forEvent:elem atIndexPath:indexPath];
    }
    
    if ([cell isKindOfClass:[LocationCellOutStream class]]) {
        [self configureLocationCellOut:(LocationCellOutStream *) cell forEvent:elem atIndexPath:indexPath];
    }
    
    if ([cell isKindOfClass:[AudioCellInStream class]]) {
        [self configureAudioCellIn:(AudioCellInStream *) cell forEvent:elem atIndexPath:indexPath];
    }
    
    if ([cell isKindOfClass:[AudioCellOutStream class]]) {
        [self configureAudioCellOut:(AudioCellOutStream *) cell forEvent:elem atIndexPath:indexPath];
    }
    
    if ([cell isKindOfClass:[FriendCellInStream class]]) {
        [self configureFriendCellIn:(FriendCellInStream *) cell forEvent:elem atIndexPath:indexPath];
    }
    
    if ([cell isKindOfClass:[FriendCellOutStream class]]) {
        [self configureFriendCellOut:(FriendCellOutStream *) cell forEvent:elem atIndexPath:indexPath];
    }
    
    if ([cell isKindOfClass:[ContactCellInStream class]]) {
        [self configureContactCellIn:(ContactCellInStream *) cell forEvent:elem atIndexPath:indexPath];
    }
    
    if ([cell isKindOfClass:[ContactCellOutStream class]]) {
        [self configureContactCellOut:(ContactCellOutStream *) cell forEvent:elem atIndexPath:indexPath];
    }
    
    if ([cell isKindOfClass:[CallCellInStream class]]) {
        [self configureCallCellIn:(CallCellInStream *) cell forEvent:elem atIndexPath:indexPath];
    }
    
    if ([cell isKindOfClass:[CallCellOutStream class]]) {
        [self configureCallCellOut:(CallCellOutStream *) cell forEvent:elem atIndexPath:indexPath];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DLog(@"cellForRowAtIndexPath : %d, %d", indexPath.section, indexPath.row);
    
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
        if (self.activeFilter || self.textFilter) {
            return self.noFilterResultsCell;
        } else {
            return self.noMessageCell;
        }
    }
    
    
    MessageCell *cell = nil;
    @try {
        // Handle Section HeaderCell
        MOC2CallEvent *elem = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSString *cellIdentifier = nil;
        NSString *eventType = elem.eventType;
        NSString *text = elem.text;
        BOOL isInbound = NO;
        BOOL isMessage = NO;
        
        DLog(@"EventType : %@", eventType);
        if ([eventType isEqualToString:@"CallIn"]) {
            cellIdentifier = @"CallCellInStream";
            isInbound = YES;
        } else if ([eventType isEqualToString:@"CallOut"]) {
            cellIdentifier = @"CallCellOutStream";
        } else if ([eventType isEqualToString:@"MessageOut"] || [eventType isEqualToString:@"MessageSubmit"]) {
            isMessage = YES;
            cellIdentifier = @"MessageCellOutStream";
            
            if ([text hasPrefix:@"image://"]) {
                cellIdentifier = @"ImageCellOutStream";
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
            cellIdentifier = @"MessageCellInStream";
            
            if ([text hasPrefix:@"image://"]) {
                cellIdentifier = @"ImageCellInStream";
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
        
        DLog(@"Cell with identifier : %@", cellIdentifier);
        
        cell = (MessageCell *) [tv dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (!cell) {
            DLog(@"Error : Cell with identifier : %@", cellIdentifier);
        }
        
        // Initialize Cell
        [cell reset];
        [cell.downloadButton setHidden:YES];
        [cell.progress setHidden:YES];
        [cell.activity stopAnimating];
        
        if (isInbound) {
            if (!self.lastIncomingMessage)
                self.lastIncomingMessage = elem.timeStamp;
            else {
                self.lastIncomingMessage = [elem.timeStamp laterDate:self.lastIncomingMessage];
            }
        }
        
        [self configureCell:cell atIndexPath:indexPath];
        
        if (isVisible && isInbound && isMessage && [elem.status intValue] < 4) {
            [[SCDataManager instance] markAsRead:elem];
        }
        
    }
    @catch (NSException * e) {
        [self.tableView reloadData];
        NSLog(@"2:Exception : cellForRowAtIndexPath %d / %d \n %@", (int)indexPath.section, (int)indexPath.row, e);
        UITableViewCell *dummyCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        dummyCell.contentView.hidden = YES;
        return dummyCell;
    }
    @finally {
        DLog(@"2:Cell Text (%d/%d): %@", indexPath.section, indexPath.row, cell.textfield.text);
    }
    
    cell.selected = NO;
    return cell;
    
}

-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
        return NO;
    }
    
    @try {
        MOC2CallEvent *elem = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSString *eventType = elem.eventType;
        
        if ([eventType isEqualToString:@"MessageSubmit"]) {
            int status = [elem.status intValue];
            if (status != 3) {
                return NO;
            }
        }
        return YES;
    }
    @catch (NSException *exception) {
        return NO;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MOC2CallEvent *elem = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[SCDataManager instance] removeDatabaseObject:elem];
    }
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

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
        [self composeAction:nil];
        return;
    }
    
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
        return;
    }
    
}

#pragma mark FetchResultsController delegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    [super controller:controller didChangeObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            scrollToBottom = YES;
            break;
        case NSFetchedResultsChangeDelete:
            break;
        case NSFetchedResultsChangeUpdate:
            break;
        case NSFetchedResultsChangeMove:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    //    if (!isVisible)
    //        return;
    [super controllerDidChangeContent:controller];
    @try {
        [self refreshTable];
        [self refreshBadgeValue];
    }
    @catch (NSException *exception) {
        DLog(@"Exception:didChangeContent : %@ \n%@", exception, exception.callStackSymbols);
    }
}

#pragma mark Segue Handling

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self customPrepareForSegue:segue sender:sender];
}

#pragma mark actions


-(IBAction)composeAction:(id)sender
{
    [self composeMessage:nil richMessageKey:nil];
}

-(IBAction)answerMessage:(id)sender
{
    [self composeMessage:nil richMessageKey:nil answerLastContact:YES];
}

-(IBAction)searchBarAction:(UIBarButtonItem *)sender
{
    /*
     if (self.searchView.alpha == 0) {
     self.filterInfoView.hidden = YES;
     [UIView animateWithDuration:0.5 animations:^{
     self.searchView.alpha = 1.0;
     } completion:^(BOOL finished) {
     [self.searchField becomeFirstResponder];
     [self.tableView reloadData];
     [self scrollTop];
     }];
     return;
     }
     
     if (self.searchView.alpha == 1.0) {
     [UIView animateWithDuration:0.5 animations:^{
     self.searchView.alpha = 0.0;
     } completion:^(BOOL finished) {
     if ([self.searchField isFirstResponder])
     [self.searchField resignFirstResponder];
     [self refreshFilterInfo];
     [self.tableView reloadData];
     }];
     return;
     }
     */
}


-(IBAction)filterMenu:(id)sender
{
    SCPopupMenu *popup = [SCPopupMenu popupMenu:self];
    
    [popup addChoiceWithName:NSLocalizedString(@"Remove Filter", @"Filter Action") andSubTitle:nil andIcon:nil andCompletion:^{
        [self removeAllFilter:nil];
    }];
    
    [popup addChoiceWithName:NSLocalizedString(@"Images", @"Filter Action") andSubTitle:nil andIcon:nil andCompletion:^{
        [self setMessageFilter:SCBoardMessageFilter_IMAGE];
    }];
    
    [popup addChoiceWithName:NSLocalizedString(@"Videos", @"Filter Action") andSubTitle:nil andIcon:nil andCompletion:^{
        [self setMessageFilter:SCBoardMessageFilter_VIDEO];
    }];
    
    [popup addChoiceWithName:NSLocalizedString(@"Voice Mails", @"Filter Action") andSubTitle:nil andIcon:nil andCompletion:^{
        [self setMessageFilter:SCBoardMessageFilter_VOICEMAIL];
    }];
    
    [popup addChoiceWithName:NSLocalizedString(@"Locations", @"Filter Action") andSubTitle:nil andIcon:nil andCompletion:^{
        [self setMessageFilter:SCBoardMessageFilter_LOCATION];
    }];
    
    [popup addChoiceWithName:NSLocalizedString(@"Calls", @"Filter Action") andSubTitle:nil andIcon:nil andCompletion:^{
        [self setMessageFilter:SCBoardMessageFilter_CALL];
    }];
    
    [popup addChoiceWithName:NSLocalizedString(@"Missed", @"Filter Action") andSubTitle:nil andIcon:nil andCompletion:^{
        [self setMessageFilter:SCBoardMessageFilter_MISSED];
    }];
    
    [popup addCancelWithName:NSLocalizedString(@"Cancel", @"Button") andCompletion:^{
    }];
    
    [popup showMenu];
}

-(IBAction)removeAllFilter:(id)sender
{
    for (NSMutableDictionary *f in self.filterList) {
        [f setValue:[NSNumber numberWithBool:NO] forKey:@"selected"];
    }
    NSMutableDictionary *all = [self.filterList objectAtIndex:0];
    [all setValue:[NSNumber numberWithBool:YES] forKey:@"selected"];
    
    self.activeFilter = nil;
    self.filterButton.selected = NO;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"activeStreamFilter"];
    [self removeTextFilter];
    
    [self refetchResults];
}

-(void) showMessagesForUser:(NSString *) userid
{
    if (!userid)
        return;
    
    UIView *responderView = [self findFirstResponder:self.view];
    [responderView resignFirstResponder];
    
    // TODO - Show Message for User
    /*
     double delayInSeconds = 0.1;
     dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
     dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
     MessagePaneController *mpc = [[MessagePaneController alloc] initWithNibName:@"MessagePane" bundle:nil];
     mpc.targetUserid = userid;
     mpc.startEdit = YES;
     
     UINavigationController *nc = [[C2NavigationController alloc] initWithRootViewController:mpc];
     nc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
     nc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
     
     [self presentModalViewController:nc animated:YES];
     
     
     //[[self navigationController] pushViewController:mpc animated:YES];
     
     });
     */
}

-(IBAction)previousMessages:(id)sender
{
    int fetchedObectsCount = (int)[[self.fetchedResultsController fetchedObjects] count];
    fetchLimit = MAX(fetchedObectsCount, fetchLimit);
    
    fetchLimit += fetchSize;
    [self refetchResults];
}

-(void) showPaymentRequired
{
    // TODO - Payment Required
    /*
     PaymentRequiredController *pay = [[PaymentRequiredController alloc] initWithNibName:@"PaymentRequiredController" bundle:nil];
     [self presentModalViewController:pay animated:YES];
     */
}

#pragma mark Message Actions

-(void) shareEmail:(NSString *) key
{
    if (![MFMailComposeViewController canSendMail]) {
        return;
    }
    
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    
    NSURL *url = [[C2CallPhone currentPhone] mediaUrlForKey:key];
    NSString *name = [[C2CallPhone currentPhone] nameForKey:key];
    NSString *contentType = [[C2CallPhone currentPhone] contentTypeForKey:key];
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    [controller addAttachmentData:data mimeType:contentType
                         fileName:name];
    
    [self presentViewController:controller animated:YES completion:NULL];
}

-(void) shareMessageForKey:(NSString *) key
{
    SCPopupMenu *cv = [SCPopupMenu popupMenu:self];
    
    [cv addChoiceWithName:NSLocalizedString(@"Forward", @"Choice Title") andSubTitle:NSLocalizedString(@"Share via FriendCaller", @"Choice SubTitle") andIcon:[UIImage imageNamed:@"ico_forward.png"] andCompletion:^(){
        [self forwardMessage:key];
    }];
    
    
    [cv addCancelWithName:NSLocalizedString(@"Cancel", @"Button") andCompletion:^{
    }];
    
    [cv showMenu];
    
}

-(void) shareRichMessageForKey:(NSString *) key
{
    SCPopupMenu *cv = [SCPopupMenu popupMenu:self];
    
    [cv addChoiceWithName:NSLocalizedString(@"Forward", @"Choice Title") andSubTitle:NSLocalizedString(@"Share via FriendCaller", @"Choice SubTitle") andIcon:[UIImage imageNamed:@"ico_forward.png"] andCompletion:^(){
        [self forwardMessage:key];
    }];
    
    [cv addChoiceWithName:NSLocalizedString(@"Email", @"Choice Title") andSubTitle:NSLocalizedString(@"Share via Email", @"Choice SubTitle") andIcon:[UIImage imageNamed:@"ico_email.png"] andCompletion:^(){
        [self shareEmail:key];
    }];
    
    [cv addCancelWithName:NSLocalizedString(@"Cancel", @"Button") andCompletion:^{
    }];
    
    [cv showMenu];
}

// Not implemented yet
-(void) sharePhotoOrVideo:(NSString *) key
{
    
}

-(void) forwardMessage:(NSString *)message
{
    if ([message hasPrefix:@"image://"] || [message hasPrefix:@"video://"] ||[message hasPrefix:@"audio://"] ||[message hasPrefix:@"vcard://"] ||[message hasPrefix:@"loc://"] ||[message hasPrefix:@"friend://"] || [message hasPrefix:@"file://"] ) {
        [self composeMessage:nil richMessageKey:message];
    } else {
        [self composeMessage:message richMessageKey:nil];
    }
    
}

-(void) copyText:(NSString *) text
{
    @autoreleasepool {
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        
        [pasteBoard setString:text];
    }
}

-(void) copyVCard:(NSString *) vcard
{
    @autoreleasepool {
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        
        NSData *data = [vcard dataUsingEncoding:NSUTF8StringEncoding];
        [pasteBoard setData:data forPasteboardType:(NSString*)kUTTypeVCard];
    }
}

-(void) copyImageForKey:(NSString *) key
{
    @autoreleasepool {
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        
        if ([[C2CallPhone currentPhone] hasObjectForKey:key]) {
            UIImage *img = [[C2CallPhone currentPhone] imageForKey:key];
            [pasteBoard setImage:img];
        }
    }
}

-(void) copyLocationForKey:(NSString *) key
{
    @autoreleasepool {
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        
        UIImage *img = [ImageUtil imageFromLocation:[[FCLocation alloc] initWithKey:key]];
        if (img)
            [pasteBoard setImage:img];
    }
}

-(void) copyMovieForKey:(NSString *) key
{
    @autoreleasepool {
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        
        NSURL *url = [[C2CallPhone currentPhone] mediaUrlForKey:key];
        if (url) {
            [pasteBoard setURL:url];
        }
    }
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
    
    CGRect rect = cell.messageImage.frame;
    rect = [cell convertRect:rect fromView:cell.messageImage];
    [menu setTargetRect:rect inView:cell];
    [cell becomeFirstResponder];
    [menu setMenuVisible:YES animated:YES];
    
}

#pragma mark Filter

-(void) setMessageFilter:(SCBoardMessageFilterType)filter
{
    NSMutableDictionary *dict = nil;
    NSString *filterkey = @"allFilter";
    
    if (wasDontShowCallEvents) {
        wasDontShowCallEvents = NO;
        dontShowCallEvents = YES;
    }
    
    switch (filter) {
        case SCBoardMessageFilter_CALL:
            filterkey =@"callFilter";
            if (dontShowCallEvents) {
                wasDontShowCallEvents = YES;
                dontShowCallEvents = NO;
            }
            break;
        case SCBoardMessageFilter_IMAGE:
            filterkey =@"imageFilter";
            break;
        case SCBoardMessageFilter_LOCATION:
            filterkey =@"locationFilter";
            break;
        case SCBoardMessageFilter_MISSED:
            filterkey =@"missedFilter";
            break;
        case SCBoardMessageFilter_VIDEO:
            filterkey =@"videoFilter";
            break;
        case SCBoardMessageFilter_VOICEMAIL:
            filterkey =@"audioFilter";
            break;
        default:
            break;
    }
    
    DLog(@"setFriendFilter : %@", filterkey);
    
    for (NSMutableDictionary *f in self.filterList) {
        [f setValue:[NSNumber numberWithBool:NO] forKey:@"selected"];
        
        if ([[f objectForKey:@"filter"] isEqualToString:filterkey]) {
            DLog(@"Found Filter : %@", f);
            
            dict = f;
        }
    }
    [dict setValue:[NSNumber numberWithBool:YES] forKey:@"selected"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshActiveFilter];
        [self refetchResults];
    });
    
}

-(void) refreshFilterInfo
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.selected = YES"];
    NSArray *selected = [self.filterList filteredArrayUsingPredicate:predicate];
    
    NSString *activeFilterName = nil;
    if ([selected count] > 0) {
        if (![[[selected objectAtIndex:0] objectForKey:@"filter"] isEqualToString:@"allFilter"]) {
            activeFilterName = [[selected objectAtIndex:0] objectForKey:@"name"];
        }
    }
    
    NSString *filterText = nil; //self.searchField.text;
    if ([filterText length] == 0)
        filterText = nil;
    
    if (!activeFilterName && !filterText) {
        self.activeFilterInfo = nil;
    } else {
        
        if (activeFilterName && filterText) {
            self.activeFilterInfo = [NSString stringWithFormat:@"Filter : %@, '%@'", activeFilterName, filterText];
        } else if (activeFilterName) {
            self.activeFilterInfo = [NSString stringWithFormat:@"Filter : %@", activeFilterName];
        } else {
            self.activeFilterInfo = [NSString stringWithFormat:@"Filter : '%@'", filterText];
        }
    }
    
    if (self.activeFilterInfo) {
        self.filterInfoView.hidden = NO;
        self.labelFilterInfo.text = self.activeFilterInfo;
    } else {
        self.filterInfoView.hidden = YES;
    }
    
    [self refreshSearchButton];
}

-(void) refreshActiveFilter
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.selected = YES"];
    NSArray *selected = [self.filterList filteredArrayUsingPredicate:predicate];
    
    int filterType = 0;
    if ([selected count] > 0) {
        NSString *filter = [[selected objectAtIndex:0] objectForKey:@"filter"];
        if ([filter isEqualToString:@"allFilter"]) {
            filterType = 0;
        }
        if ([filter isEqualToString:@"imageFilter"]) {
            filterType = 1;
        }
        if ([filter isEqualToString:@"videoFilter"]) {
            filterType = 2;
        }
        if ([filter isEqualToString:@"locationFilter"]) {
            filterType = 3;
        }
        if ([filter isEqualToString:@"audioFilter"]) {
            filterType = 4;
        }
        if ([filter isEqualToString:@"callFilter"]) {
            filterType = 5;
        }
        if ([filter isEqualToString:@"missedFilter"]) {
            filterType = 6;
        }
    }
    switch (filterType) {
        case 0:
            self.activeFilter = nil;
            break;
        case 1:
            self.activeFilter = [NSPredicate predicateWithFormat:@"SELF.text contains[cd] %@", @"image://"];
            break;
        case 2:
            self.activeFilter = [NSPredicate predicateWithFormat:@"SELF.text contains[cd] %@", @"video://"];
            break;
        case 3:
            self.activeFilter = [NSPredicate predicateWithFormat:@"SELF.text contains[cd] %@", @"loc://"];
            break;
        case 4:
            self.activeFilter = [NSPredicate predicateWithFormat:@"SELF.text contains[cd] %@", @"audio://"];
            break;
        case 5:
            self.activeFilter = [NSPredicate predicateWithFormat:@"eventType contains[cd] %@", @"call"];
            break;
        case 6:
            self.activeFilter = [NSPredicate predicateWithFormat:@"missedDisplay = YES"];
            break;
        default:
            break;
    }
    
    if (self.activeFilter) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:filterType] forKey:@"activeStreamFilter"];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"activeStreamFilter"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSFetchRequest *fetch = [self.fetchedResultsController fetchRequest];
    if (self.activeFilter && self.textFilter) {
        self.filterButton.selected = YES;
        NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:self.activeFilter, self.textFilter, nil]];
        [fetch setPredicate:predicate];
    } else if (self.activeFilter) {
        self.filterButton.selected = YES;
        [fetch setPredicate:self.activeFilter];
    } else if (self.textFilter) {
        self.filterButton.selected = NO;
        [fetch setPredicate:self.textFilter];
    } else {
        self.filterButton.selected = NO;
        [fetch setPredicate:nil];
    }
}

-(void) removeTextFilter
{
    NSFetchRequest *fetch = [self.fetchedResultsController fetchRequest];
    
    self.textFilter = nil;
    if (self.activeFilter) {
        [fetch setPredicate:self.activeFilter];
    } else {
        [fetch setPredicate:nil];
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"textStreamFilter"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) setTextFilterForText:(NSString *) text
{
    [self resetLimits];
    
    NSFetchRequest *fetch = [self.fetchedResultsController fetchRequest];
    
    self.textFilter = [NSPredicate predicateWithFormat:@"SELF.text contains[cd] %@ or SELF.senderName contains[cd] %@", text, text];
    
    if (self.activeFilter) {
        NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:self.activeFilter, self.textFilter, nil]];
        [fetch setPredicate:predicate];
    } else {
        [fetch setPredicate:self.textFilter];
    }
    
    if (text) {
        [[NSUserDefaults standardUserDefaults] setObject:text forKey:@"textStreamFilter"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark UITextFieldDelegate


-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)text
{
    @try {
        NSString *newtext = [textField.text stringByReplacingCharactersInRange:range withString:text];
        
        lastSearch = CFAbsoluteTimeGetCurrent();
        
        double delayInSeconds = 0.6;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (CFAbsoluteTimeGetCurrent() - lastSearch >= 0.5) {
                lastSearch = CFAbsoluteTimeGetCurrent();
                
                if ([newtext length] == 0) {
                    [self removeTextFilter];
                } else {
                    [self setTextFilterForText:newtext];
                }
                [self refetchResults];
            }
        });
    }
    @catch (NSException *exception) {
    }
    
    
    return YES;
}

-(BOOL) textFieldShouldClear:(UITextField *)textField
{
    [self removeTextFilter];
    [self refetchResults];
    
    return YES;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    /*
     if ([self.searchField isFirstResponder]) {
     [self searchBarAction:nil];
     }
     */
    
    return YES;
}

#pragma mark MailComposerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    UIView *firstResponder = [self findFirstResponder:controller.view];
    [firstResponder resignFirstResponder];
    double delayInSeconds = 0.5;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [controller dismissViewControllerAnimated:YES completion:NULL];
    });
}

@end
