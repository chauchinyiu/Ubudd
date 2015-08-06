//
//  WUChatHistoryController.m
//  WhazzUpp
//
//  Created by Michael Knecht on 02.06.13.
//  Copyright (c) 2013 C2Call GmbH. All rights reserved.
//

#import "WUChatHistoryController.h"
#import <SocialCommunication/UIViewController+SCCustomViewController.h>
#import <SocialCommunication/debug.h>
#import "ViewController/WUAddGroupController.h"
#import "WUChatController.h"
#import "WUBoardController.h"
#import "DataRequest.h"
#import "WebserviceHandler.h"
#import "ResponseBase.h"
#import "DataResponse.h"
#import "CommonMethods.h"
#import "DBHandler.h"

@implementation WUChatHistoryCell

@synthesize nameLabel, textLabel, timeLabel, userImage, missedEvents;

-(void) layoutSubviews {
    [super layoutSubviews];
    
    CALayer *l = self.missedEvents.layer;
    l.cornerRadius = 5.0;
}

@end

@implementation WUHistoryRequestCell

@synthesize nameLabel;

@end


@interface WUChatHistoryController () {
    NSCalendar  *calendar;
    CGFloat     chatHistoryCellHeight;
    CGFloat     requestCellHeight;
    BOOL hasRequest;
    int requestCnt;
    BOOL hasBroadcast;
    int broadcastIdx;
}

@end

@implementation WUChatHistoryController

#pragma mark - UIViewController Delegate
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
    
    self.cellIdentifier = @"WUChatHistoryCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    chatHistoryCellHeight = MAX(58 * [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline].pointSize / 17, 58);
    
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"WUHistoryRequestCell"];
    requestCellHeight = 34;

    calendar = [NSCalendar currentCalendar];
    hasBroadcast = false;
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.translucent = NO;
    [self reloadPage];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[WUAddGroupController class]]) {
        WUAddGroupController *addGroupController = (WUAddGroupController *)segue.destinationViewController;
        addGroupController.parentController = self;
    }
    else if ([segue.destinationViewController isKindOfClass:[WUChatController class]]) {
        WUChatController *chatController = (WUChatController *)segue.destinationViewController;
        
        chatController.targetUserid = [sender objectForKey:@"userid"];
        chatController.startEdit = [[sender objectForKey:@"startEdit"] boolValue];
        chatController.sendWelcomeText = [[sender objectForKey:@"sendWelcomeText"] boolValue];
    }
}

#pragma mark fetchRequest

-(NSFetchRequest *) fetchRequest
{
    return [[SCDataManager instance] fetchRequestForChatHistory:NO];
}

- (void)readOutStandingRequestResponse:(ResponseBase *)response error:(NSError *)error{
    requestCnt = ((NSNumber*)[((DataResponse*)response).data objectForKey:@"requestCnt"]).intValue;
    hasRequest = (requestCnt > 0);
    [self.tableView reloadData];
}


#pragma mark Configure Cell

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog([NSString stringWithFormat:@"%@, %d, %d", (hasBroadcast ? @"a" : @"b"), (int)[super tableView:tableView numberOfRowsInSection:section], broadcastIdx]);
    return [super tableView:tableView numberOfRowsInSection:section] + (hasRequest ? 1: 0) + (hasBroadcast ? 1 : 0);
}



-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (hasRequest && indexPath.row == 0){
        NSLog(@"h");
        return requestCellHeight;
    }
    else{
        NSIndexPath* tmppath = [NSIndexPath indexPathForRow:indexPath.row - (hasRequest ? 1 : 0) inSection:indexPath.section];
        
        if (hasBroadcast && tmppath.row == broadcastIdx) {
            NSLog(@"h");
            return chatHistoryCellHeight;
        }
        else{
            
            
            tmppath = [NSIndexPath indexPathForRow:tmppath.row - (hasBroadcast && tmppath.row > broadcastIdx ? 1 : 0) inSection:tmppath.section];
            MOChatHistory *chathist = [self.fetchedResultsController objectAtIndexPath:tmppath];
            MOC2CallUser *user = [[SCDataManager instance] userForUserid:chathist.contact];
            if(user){
                if ([user.userType intValue] == 2) {
                    NSMutableArray* groups = [[ResponseHandler instance] groupList];
                    for (int i = 0; i < groups.count; i++) {
                        WUAccount* a = [groups objectAtIndex:i];
                        if ([a.c2CallID isEqualToString:chathist.contact]) {
                            NSLog(@"h");
                            return chatHistoryCellHeight;
                        }
                    }
                } else {
                    return chatHistoryCellHeight;
                }

            }
            NSLog(@"0");

            return 0;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog([NSString stringWithFormat:@"%@, row %d, %d", (hasBroadcast ? @"a" : @"b"), (int)indexPath.row, broadcastIdx]);

    
    if (hasRequest && indexPath.row == 0) {
        WUHistoryRequestCell* rCell = (WUHistoryRequestCell *)[self.tableView dequeueReusableCellWithIdentifier:@"WUHistoryRequestCell"];
        rCell.nameLabel.font = [CommonMethods getStdFontType:0];
        [rCell.nameLabel setText:[NSString stringWithFormat:NSLocalizedString(@"You have requests", @""), requestCnt]];
        return rCell;
    }
    
    else{

        NSIndexPath* tmppath = [NSIndexPath indexPathForRow:indexPath.row - (hasRequest ? 1 : 0) inSection:indexPath.section];
        
        
        WUChatHistoryCell* hCell = (WUChatHistoryCell*)[self.tableView dequeueReusableCellWithIdentifier:@"WUChatHistoryCell"];
        if (hasBroadcast && tmppath.row == broadcastIdx) {
            NSLog(@"a");
            hCell.nameLabel.font = [CommonMethods getStdFontType:0];
            hCell.timeLabel.font = [CommonMethods getStdFontType:2];
            hCell.textLabel.font = [CommonMethods getStdFontType:2];
            hCell.nameLabel.text = NSLocalizedString(@"Admin messages", @"");
            hCell.timeLabel.text = @"";
            hCell.textLabel.text = @"";
            hCell.missedEvents.hidden = YES;
            hCell.userImage.image = [UIImage imageNamed:@"ubudd_ico.png"];
            hCell.userImage.layer.cornerRadius = 5.0;
            hCell.userImage.layer.masksToBounds = YES;
            
            
            NSDate *today = [NSDate date];
            NSDate *bcDate = [ResponseHandler instance].lastBroadcastTime;
            
            NSDateComponents* c1 =
            [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                       fromDate:today];
            
            NSDateComponents* c2 =
            [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                       fromDate:bcDate];
            
            if (!([c1 day] == [c2 day] && [c1 month] == [c2 month] && [c1 year] == [c2 year])) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                NSTimeZone *gmt = [NSTimeZone localTimeZone];
                [dateFormatter setTimeZone:gmt];
                [dateFormatter setDateStyle:NSDateFormatterShortStyle];
                [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
                
                hCell.timeLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:bcDate]];
            } else {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                NSTimeZone *gmt = [NSTimeZone localTimeZone];
                [dateFormatter setTimeZone:gmt];
                [dateFormatter setDateStyle:NSDateFormatterNoStyle];
                [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
                
                hCell.timeLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:bcDate]];
            }
            WUBroadcast* b = [[ResponseHandler instance].broadcastList objectAtIndex:[ResponseHandler instance].broadcastList.count -1];
            
            if (b.isImage) {
                hCell.textLabel.text = NSLocalizedString(@"Picture Message", @"");
            }
            else{
                hCell.textLabel.text = b.message;
            }
        }
        else{
            NSLog(@"b");
            tmppath = [NSIndexPath indexPathForRow:tmppath.row - (hasBroadcast && tmppath.row > broadcastIdx ? 1 : 0) inSection:tmppath.section];
            [self configureCell:hCell atIndexPath:tmppath];
        }
        return hCell;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath;
{
    NSIndexPath* tmppath = [NSIndexPath indexPathForRow:indexPath.row + (hasBroadcast && indexPath.row >= broadcastIdx ? 1 : 0) inSection:indexPath.section];
    tmppath = [NSIndexPath indexPathForRow:tmppath.row + (hasRequest ? 1 : 0) inSection:tmppath.section];
    
    NSIndexPath* newtmppath;
    
    if (newIndexPath) {
        newtmppath = [NSIndexPath indexPathForRow:newIndexPath.row + (hasBroadcast && newIndexPath.row >= broadcastIdx ? 1 : 0) inSection:newIndexPath.section];
        newtmppath = [NSIndexPath indexPathForRow:newtmppath.row + (hasRequest ? 1 : 0) inSection:newtmppath.section];
    }
    
    UITableView *tableView = self.tableView;
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newtmppath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[tmppath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            if (tmppath.row < broadcastIdx) {
                broadcastIdx--;
            }
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[tmppath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[tmppath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newtmppath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }

}


-(void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    MOChatHistory *chathist = [self.fetchedResultsController objectAtIndexPath:indexPath];
    MOC2CallUser *user = [[SCDataManager instance] userForUserid:chathist.contact];
    BOOL hasRelation = false;
    if ([user.userType intValue] == 2) {
        NSMutableArray* groups = [[ResponseHandler instance] groupList];
        for (int i = 0; i < groups.count; i++) {
            WUAccount* a = [groups objectAtIndex:i];
            if ([a.c2CallID isEqualToString:chathist.contact]) {
                hasRelation = true;
            }
        }
    }
    else{
        hasRelation = true;
    }
    /*
    NSMutableArray* friends = [[ResponseHandler instance] friendList];
    for (int i = 0; i < friends.count; i++) {
        WUAccount* a = [friends objectAtIndex:i];
        if ([a.c2CallID isEqualToString:chathist.contact]) {
            hasRelation = true;
        }
    }
     */
    
    if(user && hasRelation){
        [cell setHidden:NO];
        if ([cell isKindOfClass:[WUChatHistoryCell class]]) {
            WUChatHistoryCell *histcell = (WUChatHistoryCell *) cell;
            histcell.nameLabel.font = [CommonMethods getStdFontType:0];
            histcell.timeLabel.font = [CommonMethods getStdFontType:2];
            histcell.textLabel.font = [CommonMethods getStdFontType:2];
            histcell.nameLabel.text = [[C2CallPhone currentPhone] nameForUserid:chathist.contact];
            
            if ([user.userType intValue] == 2) {
                NSMutableArray* groups = [ResponseHandler instance].groupList;
                for (int i = 0; i < groups.count; i++) {
                    WUAccount* a = [groups objectAtIndex:i];
                    if([a.c2CallID isEqualToString:chathist.contact] && a.name != nil){
                        histcell.nameLabel.text= a.name;
                    }
                }
            }
            else{
                NSMutableArray* friends = [ResponseHandler instance].friendList;
                for (int i = 0; i < friends.count; i++) {
                    WUAccount* a = [friends objectAtIndex:i];
                    if([a.c2CallID isEqualToString:chathist.contact] && a.name != nil){
                        histcell.nameLabel.text= a.name;
                    }
                }
            }
            
            NSDate *today = [NSDate date];
            
            NSDateComponents *dateComps = [calendar components:NSDayCalendarUnit fromDate:chathist.lastTimestamp toDate:today options:0];
            
            if ([dateComps day] > 0) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateStyle:NSDateFormatterShortStyle];
                [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
                
                histcell.timeLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:chathist.lastTimestamp]];
            } else {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateStyle:NSDateFormatterNoStyle];
                [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
                
                histcell.timeLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:chathist.lastTimestamp]];
            }
            
            if (chathist.lastEventId) {
                MOC2CallEvent *event = [[SCDataManager instance] eventForEventId:chathist.lastEventId];
                
                switch ([[C2CallPhone currentPhone] mediaTypeForKey:event.text]) {
                    case SCMEDIATYPE_VOICEMAIL:
                        histcell.textLabel.text = NSLocalizedString(@"Voice Mail", @"");
                        break;
                    case SCMEDIATYPE_IMAGE:
                        histcell.textLabel.text = NSLocalizedString(@"Picture Message", @"");
                        break;
                    case SCMEDIATYPE_VIDEO:
                        histcell.textLabel.text = NSLocalizedString(@"Video Message", @"");
                        break;
                    case SCMEDIATYPE_VCARD:
                        histcell.textLabel.text = @"VCard Message";
                        break;
                    case SCMEDIATYPE_FILE:
                        histcell.textLabel.text = @"File Attachment";
                        break;
                    case SCMEDIATYPE_FRIEND:
                        histcell.textLabel.text = NSLocalizedString(@"Contact Info", @"");
                        break;
                    default:
                        histcell.textLabel.text = event.text;
                        break;
                }
            } else {
                histcell.textLabel.text = @"";
            }
            
            UIImage *img = [[C2CallPhone currentPhone] userimageForUserid:chathist.contact];
            
            if (img) {
                histcell.userImage.image = img;
            } else {
                MOC2CallUser *user = [[SCDataManager instance] userForUserid:chathist.contact];
                if ([user.userType intValue] == 2) {
                    histcell.userImage.image = [UIImage imageNamed:@"btn_ico_avatar_group.png"];
                } else {
                    histcell.userImage.image = [UIImage imageNamed:@"btn_ico_avatar.png"];
                }
            }
            histcell.userImage.layer.cornerRadius = 5.0;
            histcell.userImage.layer.masksToBounds = YES;
            
            if ([chathist.missedEvents intValue] > 0) {
                histcell.missedEvents.hidden = NO;
                histcell.missedEvents.text = [NSString stringWithFormat:@"%@", chathist.missedEvents];
                histcell.timeLabel.textColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
            } else {
                histcell.missedEvents.hidden = YES;
                histcell.timeLabel.textColor = [UIColor colorWithRed:160.0/255.0 green:160.0/255.0 blue:160.0/255.0 alpha:1.0];
            }
        }
    }
    else{
        [cell setHidden:YES];
        if ([cell isKindOfClass:[WUChatHistoryCell class]]) {
            WUChatHistoryCell *histcell = (WUChatHistoryCell *) cell;
            histcell.nameLabel.text = @"";
            histcell.timeLabel.text = @"";
            histcell.textLabel.text = @"";
            histcell.nameLabel.text = @"";
            histcell.missedEvents.hidden = YES;
            histcell.userImage.image = nil;
        }
        //clear unread messages
        NSFetchRequest *fetchRequest = [[SCDataManager instance] fetchRequestForEventHistory:nil sort:YES];
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"contact == %@", chathist.contact];
        [fetchRequest setPredicate:predicate];
        NSFetchedResultsController* ubuddUsers = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[DBHandler context] sectionNameKeyPath:nil cacheName:nil];
        [ubuddUsers performFetch:nil];
        for (int j = 0; j < [[[[ubuddUsers sections] objectAtIndex:0] objects] count]; j++) {
            MOC2CallEvent *event = [[[[ubuddUsers sections] objectAtIndex:0] objects] objectAtIndex:j];
            [[SCDataManager instance] markAsRead:event];
        }
    }

}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"WUChatHistory:didSelectRowAtIndexPath : %d / %d", indexPath.section, indexPath.row);

    if (hasRequest && indexPath.row == 0) {
        [self performSegueWithIdentifier:@"JoinRequestSegue" sender:self];
    }
    else{
        NSIndexPath* tmppath = [NSIndexPath indexPathForRow:indexPath.row - (hasRequest ? 1 : 0) inSection:indexPath.section];
        if (hasBroadcast && tmppath.row == broadcastIdx) {
            NSString * storyboardName = @"chatboard";
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
            WUBoardController * vc = [storyboard instantiateViewControllerWithIdentifier:@"SCBoardController"];
            [self.navigationController pushViewController:vc animated:YES];
            
        }
        else{
            tmppath = [NSIndexPath indexPathForRow:tmppath.row - (hasBroadcast && tmppath.row > broadcastIdx ? 1 : 0) inSection:tmppath.section];
            
            MOChatHistory *chathist = [self.fetchedResultsController objectAtIndexPath:tmppath];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.selected = NO;
            MOC2CallUser *user = [[SCDataManager instance] userForUserid:chathist.contact];
            if ([user.userType intValue] == 2) {
                [WUBoardController setIsGroup:YES];
            } else {
                [WUBoardController setIsGroup:NO];
            }
            
            
            [self showChatForUserid:chathist.contact];
        }
    }
}

-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (hasRequest && indexPath.row == 0) {
        return NO;
    }
    else {
        NSIndexPath* tmppath = [NSIndexPath indexPathForRow:indexPath.row - (hasRequest ? 1 : 0) inSection:indexPath.section];
        if (hasBroadcast && tmppath.row == broadcastIdx) {
            return NO;
        }
        else{
            return YES;
        }
    }
}

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSIndexPath* tmppath = [NSIndexPath indexPathForRow:indexPath.row - (hasRequest ? 1 : 0) inSection:indexPath.section];
        if(hasBroadcast){
            tmppath = [NSIndexPath indexPathForRow:tmppath.row - (hasBroadcast && tmppath.row > broadcastIdx ? 1 : 0) inSection:tmppath.section];
        
        }
        MOChatHistory *chathist = [self.fetchedResultsController objectAtIndexPath:tmppath];
        [[SCDataManager instance] removeDatabaseObject:chathist];
    }
}

-(IBAction)toggleEditing:(id)sender
{
    if (self.tableView.editing) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(toggleEditing:)];
    } else {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toggleEditing:)];
    }
    [self.tableView setEditing:!self.tableView.editing animated:YES];
}

-(void)readBroadcastCompleted{
    if ([ResponseHandler instance].broadcastList.count > 0) {
        hasBroadcast = YES;
        BOOL isEarlier = NO;
        broadcastIdx = (int)self.fetchedResultsController.fetchedObjects.count;
        for (int i = 0; i < self.fetchedResultsController.fetchedObjects.count; i++) {
            if(!isEarlier){
                MOChatHistory *chathist = [self.fetchedResultsController.fetchedObjects objectAtIndex:i];
                if ([chathist.lastTimestamp compare: [ResponseHandler instance].lastBroadcastTime] == NSOrderedAscending) {
                    broadcastIdx = i;
                    isEarlier = YES;
                }
            }
        }
    }
    else{
        hasBroadcast = NO;
    }
    [self.tableView reloadData];
}

-(void)readBroadcastImgCompleted{
}

-(void)readRequest{
    DataRequest* datRequest = [[DataRequest alloc] init];
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    [data setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"msidn"] forKey:@"userID"];
    datRequest.values = data;
    datRequest.requestName = @"readOutStandingCount";
    
    WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
    [serviceHandler execute:METHOD_DATA_REQUEST parameter:datRequest target:self action:@selector(readOutStandingRequestResponse:error:)];
}

-(void)reloadPage{
    [self readRequest];
    [[ResponseHandler instance] readGroups];
    [ResponseHandler instance].bcdelegate = self;
    [[ResponseHandler instance] readBroadcasts];
}
@end
