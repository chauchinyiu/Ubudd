//
//  WUFriendDetailController.m
//  WhazzUpp
//
//  Created by Michael Knecht on 03.06.13.
//  Copyright (c) 2013 C2Call GmbH. All rights reserved.
//

#import "WUFriendDetailController.h"
#import "WUChatController.h"
#import <SocialCommunication/UDUserInfoCell.h>
#import <SocialCommunication/C2TapImageView.h>

#import <SocialCommunication/UIViewController+SCCustomViewController.h>
#import "WUBoardController.h"
#import "DataRequest.h"
#import "DataResponse.h"
#import "WebserviceHandler.h"
#import "ResponseHandler.h"
#import "WUMediaController.h"


@implementation WUUserInfoCell
@synthesize lblName, lblTelNo, lblStatus, userImage;
@end

@interface WUFriendDetailController(){
    NSDate* dob;
    NSString* countryCode;
    NSString* phoneNo;
    NSString* status;
    WUUserInfoCell* profileCell;
    NSString* c2CallID;
}
@end

@implementation WUFriendDetailController

static NSString* currentPhoneNo = @"";

#pragma mark - UIViewController Delegate

- (void)viewDidLoad {
    //[super viewDidLoad];

    NSMutableArray* acclist = [ResponseHandler instance].friendList;
    if ([[self.fetchedResultsController fetchedObjects] count] == 0){
        for (int i = 0; i < acclist.count; i++) {
            WUAccount* a = [acclist objectAtIndex:i];
            if ([a.phoneNo isEqualToString:currentPhoneNo]) {
                c2CallID = a.c2CallID;
            }
        }
    }
    
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    //read from server
    if (self.currentUser) {
        c2CallID = self.currentUser.userid;
    }

    [dictionary setObject:c2CallID forKey:@"c2CallID"];

    DataRequest *dataRequest = [[DataRequest alloc] init];
    dataRequest.requestName = @"readUserInfo";
    dataRequest.values = dictionary;
    
    WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
    [serviceHandler execute:METHOD_DATA_REQUEST parameter:dataRequest target:self action:@selector(readFriendInfo:error:)];
 
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.translucent = NO;
}


-(MOC2CallUser *) currentUser{
    if ([[self.fetchedResultsController fetchedObjects] count] == 0)
        return nil;
    
    return [[self.fetchedResultsController fetchedObjects] objectAtIndex:0];
}


- (void)readFriendInfo:(ResponseBase *)response error:(NSError *)error {
    DataResponse *res = (DataResponse *)response;
    
    if (error){
        
    }
    else {
        NSDateFormatter *dateFormatRead = [[NSDateFormatter alloc] init];
        [dateFormatRead setDateFormat:@"yyyy-MM-d"];
        dob = [dateFormatRead dateFromString:[res.data objectForKey:@"dob"]];
        countryCode = [res.data objectForKey:@"countryCode"];
        status = [res.data objectForKey:@"status"];
        
        NSMutableString *stringts = [NSMutableString stringWithString:[res.data objectForKey:@"phoneNo"]];
        [stringts insertString:@"-" atIndex:4];
        if (stringts.length > 9) {
            [stringts insertString:@"-" atIndex:9];
        }
        phoneNo = [NSString stringWithString:stringts];

        if (profileCell == nil) {
            [self.tableView reloadData];
        }
        else{
            [profileCell.lblTelNo setText:[NSString stringWithFormat:NSLocalizedString(@"Tel No", @""), countryCode, phoneNo]];
            
            [profileCell.lblStatus setText:status];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
     return nil;
}



-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 275;
}



-(void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[WUUserInfoCell class]]) {
        WUUserInfoCell* c = (WUUserInfoCell*)cell;

        UIImage *userImage = [[C2CallPhone currentPhone] userimageForUserid:c2CallID];
        
        if (userImage) {
            c.userImage.image = userImage;
            [c.userImage setTapAction:^{
                [self showUserImageForUserid:c2CallID];
            }];
        }
        
        NSMutableArray* acclist = [ResponseHandler instance].friendList;
        for (int i = 0; i < acclist.count; i++) {
            WUAccount* a = [acclist objectAtIndex:i];
            if ([a.c2CallID isEqualToString:c2CallID] && a.name) {
                [c.lblName setText:a.name];
            }
        }
        

        [c.lblTelNo setText:[NSString stringWithFormat:NSLocalizedString(@"Tel No", @""), countryCode, phoneNo]];
        [c.lblStatus setText:status];
        profileCell = c;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WUUserInfoCell *c = [self.tableView dequeueReusableCellWithIdentifier:@"WUUserInfoCell"];
    
    UIImage *userImage = [[C2CallPhone currentPhone] userimageForUserid:c2CallID];
    
    if (userImage) {
        c.userImage.image = userImage;
        [c.userImage setTapAction:^{
            [self showUserImageForUserid:c2CallID];
        }];
    }
    
    NSMutableArray* acclist = [ResponseHandler instance].friendList;
    for (int i = 0; i < acclist.count; i++) {
        WUAccount* a = [acclist objectAtIndex:i];
        if ([a.c2CallID isEqualToString:c2CallID] && a.name) {
            c.lblName.text = a.name;
        }
    }
    

    [c.lblTelNo setText:[NSString stringWithFormat:NSLocalizedString(@"Tel No", @""), countryCode, phoneNo]];
    [c.lblStatus setText:status];
    profileCell = c;
    return c;
}

    
-(IBAction)chat:(id)sender
{
    int idx = (int)[self.navigationController.viewControllers indexOfObject:self];
    if (idx != NSNotFound && idx > 0) {
        UIViewController *previousController = [self.navigationController.viewControllers objectAtIndex:idx - 1];
        if ([previousController isKindOfClass:[WUChatController class]]) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
    }
    [WUBoardController setIsGroup:NO];
    
    [self showChatForUserid:c2CallID];
}

-(IBAction)phoneCall:(id)sender{
    NSString* phoneNumber;
    phoneNumber = [@"telprompt://" stringByAppendingString:currentPhoneNo];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}


+(void)setPhoneNo:(NSString*)p{
    currentPhoneNo = p;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"ViewMedia"]) {
        WUMediaController *mv = (WUMediaController *)[segue destinationViewController];
        mv.targetUserid = c2CallID;
    }
    else{
        [super prepareForSegue:segue sender:sender];
    }
}

@end