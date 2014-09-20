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


@implementation WUUserInfoCell
@synthesize lblGender, lblDateOfBirth, lblInterest, lblSubinterest;
@end

@interface WUFriendDetailController(){
    bool genderFemale;
    int interestID;
    NSDate* dob;
    NSString* subInterest;
    WUUserInfoCell* profileCell;
}
@end

@implementation WUFriendDetailController

#pragma mark - UIViewController Delegate
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userInfoCell.userImage.layer.cornerRadius = 35.0;
    self.userInfoCell.userImage.layer.masksToBounds = YES;

    //read from server
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:self.currentUser.userid forKey:@"c2CallID"];

    DataRequest *dataRequest = [[DataRequest alloc] init];
    dataRequest.requestName = @"readUserInfo";
    dataRequest.values = dictionary;
    
    WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
    [serviceHandler execute:METHOD_DATA_REQUEST parameter:dataRequest target:self action:@selector(readFriendInfo:error:)];
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
        if (profileCell == nil) {
            [self.tableView reloadData];
        }
        else{
            [profileCell.lblGender setText:(genderFemale ? @"Female" : @"Male")];
            [profileCell.lblDateOfBirth setText:[NSDateFormatter localizedStringFromDate:dob
                                                                     dateStyle:NSDateFormatterMediumStyle
                                                                     timeStyle:NSDateFormatterNoStyle]];
            [profileCell.lblInterest setText:[[ResponseHandler instance] getInterestNameForID:interestID]];
            [profileCell.lblSubinterest setText:subInterest];
        
        }
    }
}



-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 300;
    }
    else{
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
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
    
    MOC2CallUser *user = [self currentUser];
    if ([user.userType intValue] == 2) {
        [WUBoardController setIsGroup:YES];
    } else {
        [WUBoardController setIsGroup:NO];
    }
    [self showChatForUserid:user.userid];
}

@end