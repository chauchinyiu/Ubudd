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
    chatHistoryCellHeight = cell.frame.size.height;
    
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"WUHistoryRequestCell"];
    requestCellHeight = cell.frame.size.height;

    calendar = [NSCalendar currentCalendar];
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.createdGroupId) {
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"0", self.createdGroupId, @"1", nil] forKeys:[NSArray arrayWithObjects:@"startEdit", @"userid", @"sendWelcomeText", nil]];
        [self performSegueWithIdentifier:@"SCChatControllerSegue" sender:dictionary];
        self.createdGroupId = nil;
    }
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
        chatController.sendWelcomeText = [[sender objectForKey:@"sendWelcomeText"] boolValue];;
    }
}

#pragma mark fetchRequest

-(NSFetchRequest *) fetchRequest
{
    DataRequest* datRequest = [[DataRequest alloc] init];
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    [data setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"msidn"] forKey:@"userID"];
    datRequest.values = data;
    datRequest.requestName = @"readOutStandingCount";
    
    WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
    [serviceHandler execute:METHOD_DATA_REQUEST parameter:datRequest target:self action:@selector(readOutStandingRequestResponse:error:)];
    
    
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
    return [super tableView:tableView numberOfRowsInSection:section] + (hasRequest ? 1: 0);
}



-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (hasRequest && indexPath.row == 0 ? requestCellHeight : chatHistoryCellHeight);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (hasRequest && indexPath.row == 0) {
        WUHistoryRequestCell* rCell = (WUHistoryRequestCell *)[self.tableView dequeueReusableCellWithIdentifier:@"WUHistoryRequestCell"];
        [rCell.nameLabel setText:[NSString stringWithFormat:@"You have %d requests", requestCnt]];
        return rCell;
    }
    else{
        NSIndexPath* tmppath = [NSIndexPath indexPathForRow:indexPath.row - (hasRequest ? 1 : 0) inSection:indexPath.section];
        WUChatHistoryCell* hCell = (WUChatHistoryCell*)[self.tableView dequeueReusableCellWithIdentifier:@"WUChatHistoryCell"];
        [self configureCell:hCell atIndexPath:tmppath];
        return hCell;
    }
}


-(void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    MOChatHistory *chathist = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[WUChatHistoryCell class]]) {
        WUChatHistoryCell *histcell = (WUChatHistoryCell *) cell;
        histcell.nameLabel.text = [[C2CallPhone currentPhone] nameForUserid:chathist.contact];

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
                    histcell.textLabel.text = @"VoiceMail";
                    break;
                case SCMEDIATYPE_IMAGE:
                    histcell.textLabel.text = @"Picture Message";
                    break;
                case SCMEDIATYPE_VIDEO:
                    histcell.textLabel.text = @"Video Message";
                    break;
                case SCMEDIATYPE_VCARD:
                    histcell.textLabel.text = @"VCard Message";
                    break;
                case SCMEDIATYPE_FILE:
                    histcell.textLabel.text = @"File Attachment";
                    break;
                case SCMEDIATYPE_FRIEND:
                    histcell.textLabel.text = @"Contact Info";
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


        if ([chathist.missedEvents intValue] > 0) {
            histcell.missedEvents.hidden = NO;
            histcell.missedEvents.text = [NSString stringWithFormat:@"%@", chathist.missedEvents];
        } else {
            histcell.missedEvents.hidden = YES;
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

-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (hasRequest && indexPath.row == 0) {
        return YES;
    }
    else{
        return NO;
    }
}

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSIndexPath* tmppath = [NSIndexPath indexPathForRow:indexPath.row - (hasRequest ? 1 : 0) inSection:indexPath.section];
        
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


@end
