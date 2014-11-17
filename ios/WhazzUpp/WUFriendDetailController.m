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
@synthesize lblGender, lblDateOfBirth, lblInterest, lblSubinterest, lblTelNo;
@end

@interface WUFriendDetailController(){
    bool genderFemale;
    int interestID;
    NSDate* dob;
    NSString* subInterest;
    NSString* countryCode;
    NSString* phoneNo;
    NSString* status;
    WUUserInfoCell* profileCell;
    MOC2CallUser* curUser;
}
@end

@implementation WUFriendDetailController

static NSString* currentPhoneNo = @"";

#pragma mark - UIViewController Delegate
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userInfoCell.userImage.layer.cornerRadius = 45.0;
    self.userInfoCell.userImage.layer.masksToBounds = YES;

    NSMutableArray* acclist = [ResponseHandler instance].friendList;
    if ([[self.fetchedResultsController fetchedObjects] count] == 0){
        curUser = [[MOC2CallUser alloc] init];
        curUser.ownNumber = currentPhoneNo;
        for (int i = 0; i < acclist.count; i++) {
            WUAccount* a = [acclist objectAtIndex:i];
            if ([a.phoneNo isEqualToString:currentPhoneNo]) {
                curUser.userid = a.c2CallID;
            }
        }
    }
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    //read from server

    [dictionary setObject:self.currentUser.userid forKey:@"c2CallID"];

    DataRequest *dataRequest = [[DataRequest alloc] init];
    dataRequest.requestName = @"readUserInfo";
    dataRequest.values = dictionary;
    
    WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
    [serviceHandler execute:METHOD_DATA_REQUEST parameter:dataRequest target:self action:@selector(readFriendInfo:error:)];
}

-(MOC2CallUser *) currentUser{
    if ([[self.fetchedResultsController fetchedObjects] count] == 0)
        return curUser;
    
    return [[self.fetchedResultsController fetchedObjects] objectAtIndex:0];
}


- (void)readFriendInfo:(ResponseBase *)response error:(NSError *)error {
    DataResponse *res = (DataResponse *)response;
    
    if (error){
        
    }
    else {
        interestID = [[res.data objectForKey:@"interestID"] integerValue];
        subInterest = [res.data objectForKey:@"interestDescription"];
        dob = [res.data objectForKey:@"dob"];
        genderFemale = [(NSString*)[res.data objectForKey:@"gender"] isEqualToString:@"F"];
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
            [profileCell.lblTelNo setText:[NSString stringWithFormat:@"Tel No.: %@ %@", countryCode, phoneNo]];
            
            [profileCell.lblGender setText:(genderFemale ? @"Female" : @"Male")];
            [profileCell.lblDateOfBirth setText:[NSDateFormatter localizedStringFromDate:dob
                                                                     dateStyle:NSDateFormatterMediumStyle
                                                                     timeStyle:NSDateFormatterNoStyle]];
            [profileCell.lblInterest setText:[[ResponseHandler instance] getInterestNameForID:interestID]];
            [profileCell.lblSubinterest setText:subInterest];
            
        }
    }
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
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 330;
    }
    else{
        return 100;
    }
}



-(void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    [super configureCell:cell atIndexPath:indexPath];
    if ([cell isKindOfClass:[WUUserInfoCell class]]) {
        WUUserInfoCell* c = (WUUserInfoCell*)cell;
        [c.favoriteImage setHidden:YES];
        [c.facebookImage setHidden:YES];
        [c.email setHidden:YES];
        [c.lblGender setText:(genderFemale ? @"Female" : @"Male")];
        [c.lblDateOfBirth setText:[NSDateFormatter localizedStringFromDate:dob
                                                                 dateStyle:NSDateFormatterMediumStyle
                                                                 timeStyle:NSDateFormatterNoStyle]];
        [c.lblInterest setText:[[ResponseHandler instance] getInterestNameForID:interestID]];
        [c.lblSubinterest setText:subInterest];
        [c.lblTelNo setText:[NSString stringWithFormat:@"Tel No.: %@ %@", countryCode, phoneNo]];
        profileCell = c;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        WUUserInfoCell *c;
        c = [super tableView:tableView cellForRowAtIndexPath:indexPath];
        [c.favoriteImage setHidden:YES];
        [c.facebookImage setHidden:YES];
        [c.email setHidden:YES];
        [c.lblGender setText:(genderFemale ? @"Female" : @"Male")];
        [c.lblDateOfBirth setText:[NSDateFormatter localizedStringFromDate:dob
                                                                 dateStyle:NSDateFormatterMediumStyle
                                                                 timeStyle:NSDateFormatterNoStyle]];
        [c.lblInterest setText:[[ResponseHandler instance] getInterestNameForID:interestID]];
        [c.lblSubinterest setText:subInterest];
        [c.lblTelNo setText:[NSString stringWithFormat:@"Tel No.: %@ %@", countryCode, phoneNo]];
        [c.userStatus setText:status];
        profileCell = c;
        return c;
    }
    else{
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

    
-(IBAction)chat:(id)sender
{
    int idx = [self.navigationController.viewControllers indexOfObject:self];
    if (idx != NSNotFound && idx > 0) {
        UIViewController *previousController = [self.navigationController.viewControllers objectAtIndex:idx - 1];
        if ([previousController isKindOfClass:[WUChatController class]]) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
    }
    [WUBoardController setIsGroup:NO];
    
    MOC2CallUser *user = [self currentUser];
    /*
    if ([user.userType intValue] == 2) {
        [WUBoardController setIsGroup:YES];
    } else {
        [WUBoardController setIsGroup:NO];
    }
     */
    [self showChatForUserid:user.userid];
}

-(IBAction)phoneCall:(id)sender{
    NSString* phoneNumber;
    MOC2CallUser *user = [self currentUser];
    phoneNumber = [@"telprompt://" stringByAppendingString:user.ownNumber];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

+(void)setPhoneNo:(NSString*)p{
    currentPhoneNo = p;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"ViewMedia"]) {
        WUMediaController *mv = (WUMediaController *)[segue destinationViewController];
        mv.targetUserid = self.currentUser.userid;
    }
    else{
        [super prepareForSegue:segue sender:sender];
    }
}


@end