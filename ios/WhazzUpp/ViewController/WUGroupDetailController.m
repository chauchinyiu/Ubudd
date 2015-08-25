//
//  WUGroupDetailController.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 21/9/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import <SocialCommunication/UIViewController+SCCustomViewController.h>
#import "WUGroupDetailController.h"
#import "DataRequest.h"
#import "DataResponse.h"
#import "WebserviceHandler.h"
#import "ResponseHandler.h"
#import "WUMediaController.h"
#import "WUUserImageController.h"
#import "WUFriendDetailController.h"
#import "CommonMethods.h"
#import "DBHandler.h"

@implementation WUGroupNonMemberActionCell
@end

@implementation WUGroupMemberActionCell
@end

@implementation WUGroupAdminActionCell
@end

@implementation WUGroupViewMediaCell
@end

@implementation WUGroupDetailCellEdit
@end

@implementation WUGroupDetailCellReadOnly
@end

@implementation WUGroupMemberCntHeaderCell
@end


@interface WUGroupDetailController (){
    int userType;
    NSMutableDictionary* groupInfo;
    WUGroupDetailCellEdit* editCell;
    UIImage* groupImg;
    NSMutableArray* friendList;
    NSMutableArray* memberList;
    NSMutableArray* newMemberList;
    NSString* currentAction;
}
@property(nonatomic, strong) SCGroup *group;
@property(nonatomic, strong) NSArray *members;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation WUGroupDetailController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    memberList = [[NSMutableArray alloc] init];
    newMemberList = [[NSMutableArray alloc] init];
    
    self.group = [[SCGroup alloc] initWithGroupid:self.groupid];
    if (self.group.groupImage) {
        groupImg = self.group.groupImage;
    }
    if ([self.group.groupOwner isEqualToString:[SCUserProfile currentUser].userid]) {
        //owner
        userType = 1;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", @"") style:UIBarButtonItemStylePlain target:self action:@selector(saveGroup)];
        
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
    else{
        userType = 3;
    }
    friendList = [[ResponseHandler instance] friendList];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (self.group.groupid != nil) {
        [dictionary setObject:self.group.groupid forKey:@"c2CallID"];
    }
    [dictionary setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"msidn"] forKey:@"userID"];
    DataRequest *dataRequest = [[DataRequest alloc] init];
    dataRequest.requestName = @"readGroupInfo";
    dataRequest.values = dictionary;
    
    WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
    [serviceHandler execute:METHOD_DATA_REQUEST parameter:dataRequest target:self action:@selector(readGroupInfo:error:)];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(hidekeybord)];
    [tap setDelegate:self];
    [self.view addGestureRecognizer:tap];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    
    self.members = [self.group groupMembers];
    
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSNumber* isPublic = [groupInfo objectForKey:@"isPublic"];
    
    if (section == 0) {
        if (userType == 1 || userType == 2 || isPublic.intValue == 1) {
            return 2; //detail and media
        }
        else{
            return 1; //detail only
        }
    }
    else if (section == 1) {
        if (userType == 1 || userType == 2 || isPublic.intValue == 1) {
            return [memberList count] + 1;
        }
        else{
            return 2;
        }
    }
    else{
        if (userType == 1 || userType == 2 || userType == 3 || isPublic.intValue == 1) {
            return 1;
        }
        else{
            return 0;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        if (userType == 1) {
            return 271;
        }
        else{
            return 309;
        }
    }
    else if (indexPath.section == 0 && indexPath.row == 1) {
        return 102;
    }
    else if(indexPath.section == 2){
        if (userType == 1) {
            return 170;
        }
        else if (userType == 2) {
            return 102;
        }
        else {
            return 34;
        }
        
    }
    else if(indexPath.section == 1){
        if (indexPath.row > 0) {
            NSNumber* isPublic = [groupInfo objectForKey:@"isPublic"];
            
            if (userType == 1 || userType == 2 || isPublic.intValue == 1) {
                NSString * userid = [memberList objectAtIndex:indexPath.row - 1];
                if([userid isEqualToString:self.group.groupOwner]){
                    return 0;
                }
            }
        }
    }
    
    return MAX(36 * [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline].pointSize / 17, 36);
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }
    else if (section == 1) {
        return 42;
    }
    else{
        return 1;
    }
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (section == 1) {
        WUGroupMemberCntHeaderCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"WUGroupMemberCntHeaderCell"];
        NSNumber* memberCnt = [groupInfo objectForKey:@"memberCnt"];
        [cell.lblMemberCnt setText:[NSString stringWithFormat:NSLocalizedString(@"Members X OF 200", @""), memberCnt.intValue + 1]];

        while (cell.contentView.gestureRecognizers.count) {
            [cell.contentView removeGestureRecognizer:[cell.contentView.gestureRecognizers objectAtIndex:0]];
        }
        return cell.contentView;
    }
    else{
        return [self.tableView dequeueReusableCellWithIdentifier:@"blankCell"];
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];


    if (indexPath.section == 1 && (userType == 1 || userType == 2)){
        NSString *userid;
        if (indexPath.row == 0) {
            userid = self.group.groupOwner;
        }
        else{
            userid = [memberList objectAtIndex:indexPath.row - 1];
        }
        
        if ([userid isEqualToString:[SCUserProfile currentUser].userid]) {
            
        } else {
            [WUFriendDetailController setC2CallID: userid];
            [self showFriendDetailForUserid:userid];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSNumber* isPublic = [groupInfo objectForKey:@"isPublic"];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        if (userType == 1) {
            WUGroupDetailCellEdit *cell = [self.tableView dequeueReusableCellWithIdentifier:@"WUGroupDetailCellEdit"];
            if (groupInfo) {
                //cell.btnPhoto.layer.cornerRadius = 0.0;
                cell.btnPhoto.layer.masksToBounds = YES;                
                [cell.btnPhoto setTapAction:^{
                    if (groupImg) {
                        [CommonMethods showSinglePhoto:cell.btnPhoto.image title:@"" onNavigationController:self.navigationController];
                        
                    }
                    else{
                        [self btnPhotoTapped:cell.btnPhoto];
                    }
                }];
                
                if(groupImg){
                    [cell.btnPhoto setImage:groupImg];
                }
                [cell.txtTopicEdit setFont:[CommonMethods getStdFontType:1]];
                [cell.txtTopicEdit setText:[groupInfo objectForKey:@"topic"]];

                int interestID = (int)[[groupInfo objectForKey:@"interestID"] integerValue];
                [cell.btnInterestEdit.titleLabel setFont:[CommonMethods getStdFontType:1]];
                [cell.btnInterestEdit setTitle:[[ResponseHandler instance] getInterestNameForID:interestID] forState:UIControlStateNormal];
                
                [cell.btnLocationEdit.titleLabel setFont:[CommonMethods getStdFontType:1]];
                [cell.btnLocationEdit setTitle:[groupInfo objectForKey:@"locationName"] forState:UIControlStateNormal];

                [cell.btnIsPublicEdit.titleLabel setFont:[CommonMethods getStdFontType:1]];
                NSNumber* isPublic = [groupInfo objectForKey:@"isPublic"];
                if(isPublic.intValue == 1){
                    [cell.btnIsPublicEdit setTitle:NSLocalizedString(@"Public", @"") forState:UIControlStateNormal];
                }
                else{
                    [cell.btnIsPublicEdit setTitle:NSLocalizedString(@"Private", @"") forState:UIControlStateNormal];
                }
                
            }
            editCell = cell;

            return cell;
        }
        else{
            WUGroupDetailCellReadOnly *cell = [self.tableView dequeueReusableCellWithIdentifier:@"WUGroupDetailCellReadOnly"];
            if (groupInfo) {
                //cell.groupImg.layer.cornerRadius = 0.0;
                cell.groupImg.layer.masksToBounds = YES;
                [cell.groupImg setTapAction:^{
                    if (groupImg) {
                        [CommonMethods showSinglePhoto:cell.groupImg.image title:@"" onNavigationController:self.navigationController];
                    }
                }];
                
                if(groupImg){
                    [cell.groupImg setImage:groupImg];
                }
                else{
                    NSString *imagePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.png", self.group.groupid]];
                    
                    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
                        NSDictionary* fileAttribute = [[NSFileManager defaultManager] attributesOfItemAtPath:imagePath error:nil];
                        NSDate* fileDate = [fileAttribute objectForKey:NSFileModificationDate];
                        if ([fileDate compare:[NSDate dateWithTimeIntervalSinceNow:-86400]] == NSOrderedDescending) {
                            NSData *data = [[NSData alloc] initWithContentsOfFile:imagePath];
                            groupImg = [UIImage imageWithData:data];
                            [cell.groupImg setImage:groupImg];
                        }
                    }
                }

                [cell.lblTopic setFont:[CommonMethods getStdFontType:1]];
                [cell.lblTopic setText:[groupInfo objectForKey:@"topic"]];
                
                int interestID = (int)[[groupInfo objectForKey:@"interestID"] integerValue];
                [cell.lblInterest setFont:[CommonMethods getStdFontType:1]];
                [cell.lblInterest setText:[[ResponseHandler instance] getInterestNameForID:interestID]];
                
                [cell.lblLocation setFont:[CommonMethods getStdFontType:1]];
                [cell.lblLocation setText:[groupInfo objectForKey:@"locationName"]];
                
                [cell.lblPublic setFont:[CommonMethods getStdFontType:1]];
                NSNumber* isPublic = [groupInfo objectForKey:@"isPublic"];
                if(isPublic.intValue == 1){
                    [cell.lblPublic setText:NSLocalizedString(@"Public", @"")];
                }
                else{
                    [cell.lblPublic setText:NSLocalizedString(@"Private", @"")];
                }
                
                
                [cell.lblJoinStatus setFont:[CommonMethods getStdFontType:1]];
                if (userType == 2) {
                    [cell.lblJoinStatus setText:NSLocalizedString(@"Joined", @"")];
                }
                else{
                    NSMutableArray* groups = [[ResponseHandler instance] groupList];
                    for (int i = 0; i < groups.count; i++) {
                        WUAccount* a = [groups objectAtIndex:i];
                        if ([a.c2CallID isEqualToString:self.group.groupid]) {
                            [groups removeObjectAtIndex:i];
                        }
                    }
                    if (userType == 3){
                        [cell.lblJoinStatus setText:NSLocalizedString(@"Non member", @"")];
                    }
                    if (userType == 4){
                        [cell.lblJoinStatus setText:NSLocalizedString(@"Request pending", @"")];
                    }
                    if (userType == 5){
                        [cell.lblJoinStatus setText:NSLocalizedString(@"Closed", @"")];
                    }
                }
                
            }
            return cell;
        }
    }
    else if (indexPath.section == 0 && indexPath.row == 1) {
        WUGroupViewMediaCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"WUGroupViewMediaCell"];
        [cell.btnViewMedia.titleLabel setFont:[CommonMethods getStdFontType:1]];
        [cell.btnEnterChat.titleLabel setFont:[CommonMethods getStdFontType:1]];
        return cell;
    }
    else if (indexPath.section == 1){
        static NSString *CellIdentifier = @"SCGroupMemberCell";
    
        SCGroupMemberCell *cell = (SCGroupMemberCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.tag = indexPath.row;
        cell.inviteButton.tag = indexPath.row;
        [cell.inviteButton.titleLabel setFont:[CommonMethods getStdFontType:1]];
        [cell.textLabel setFont:[CommonMethods getStdFontType:1]];
        [cell.detailTextLabel setFont:[CommonMethods getStdFontType:2]];
        
        [cell setHidden:NO];
        
        
        if (indexPath.row == 1 && !(userType == 1 || userType == 2 || isPublic.intValue == 1)) {
            [cell.inviteButton setHidden:YES];
            cell.textLabel.text = NSLocalizedString(@"Members are hidden due to privacy issues", @"");
            cell.backgroundColor = [UIColor whiteColor];
            cell.detailTextLabel.text = @"";
            return cell;
        }
        
        NSString *userid;
        if (indexPath.row == 0) {
            userid = self.group.groupOwner;
        }
        else{
            userid = [memberList objectAtIndex:indexPath.row - 1];
            if([userid isEqualToString:self.group.groupOwner]){
                [cell setHidden:YES];
            }
        }
        NSString *gid = self.group.groupid;
        
        MOC2CallUser *groupuser = [[SCDataManager instance] userForUserid:gid];
        int grouponline = [groupuser.onlineStatus intValue];
        int online = 0;
        
        BOOL itsMe = NO;
        
        NSString *displayName = nil;
        if ([userid isEqualToString:[SCUserProfile currentUser].userid]) {
            itsMe = YES;
            displayName = [SCUserProfile currentUser].displayname;
        }
        else if(indexPath.row == 0){
            displayName = [groupInfo objectForKey:@"userName"];
        }
        else {
            MOC2CallUser *member = [[SCDataManager instance] userForUserid:userid];
            displayName = [member.displayName copy];
            if (!member) {
                NSString *firstname = [self.group nameForGroupMember:userid];
                if (firstname) {
                    displayName = firstname;
                }
            } else {
                online = [[member onlineStatus] intValue];
            }
        }
        for (int i = 0; i < friendList.count; i++) {
            WUAccount* a = [friendList objectAtIndex:i];
            if ([a.c2CallID isEqualToString:userid]) {
                displayName = a.name;
            }
        }
        
        
        [cell.inviteButton setHidden:YES];
        cell.textLabel.text = displayName;
        
        
        if ([self.group.groupOwner isEqualToString:userid]) {
            cell.textLabel.textColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] ;
            [cell.textLabel setText:[cell.textLabel.text stringByAppendingString:NSLocalizedString(@"Group Admin", @"")]];
        } else {
            cell.textLabel.textColor = [UIColor darkTextColor];
            if (userType == 1) {
                [cell.inviteButton setHidden:NO];
                /*
                bool isNewMember = false;
                for (int j = 0; j < newMemberList.count; j++) {
                    if ([[newMemberList objectAtIndex:j] isEqualToString:userid]) {
                        isNewMember = true;
                    }
                }
                if(!isNewMember){
                    [cell.inviteButton setHidden:NO];
                }
                 */
            }
        }
        
        
        if (itsMe)
            online = OS_ONLINE;
        
        if (grouponline == OS_CALLME) {
            NSArray *active = [[C2CallPhone currentPhone] activeMembersInCallForGroup:gid];
            if ([active containsObject:userid]) {
                online = OS_GROUPCALL;
            }
        }
        
        if (online > 0) {
            cell.detailTextLabel.textColor = [UIColor greenColor];
            switch (online) {
                case OS_ONLINE:
                    cell.detailTextLabel.text = NSLocalizedString(@"online", @"Cell Label");
                    //cell.detailTextLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
                    break;
                case OS_FORWARDED:
                    cell.detailTextLabel.text = NSLocalizedString(@"Call forward", @"Cell Label");
                    //cell.detailTextLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
                    break;
                case OS_INVISIBLE:
                    cell.detailTextLabel.text = NSLocalizedString(@"offline", @"Cell Label");
                    //cell.detailTextLabel.textColor = [UIColor lightGrayColor];
                    break;
                case OS_AWAY:
                    cell.detailTextLabel.text = NSLocalizedString(@"offline away", @"offline (away)");
                    //cell.detailTextLabel.textColor = [UIColor lightGrayColor];
                    break;
                case OS_BUSY:
                    cell.detailTextLabel.text = NSLocalizedString(@"offline busy", @"offline (busy)");
                    //cell.detailTextLabel.textColor = [UIColor lightGrayColor];
                    break;
                case OS_CALLME:
                    cell.detailTextLabel.text = NSLocalizedString(@"online call me", @"online (call me)");
                    //cell.detailTextLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
                    break;
                case OS_ONLINEVIDEO:
                    cell.detailTextLabel.text = NSLocalizedString(@"online active", @"online (active)");
                    break;
                case OS_IPUSH:
                    cell.detailTextLabel.text = NSLocalizedString(@"online", @"Cell Label");
                    //cell.detailTextLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
                    break;
                case OS_IPUSHCALL:
                    cell.detailTextLabel.text = NSLocalizedString(@"online", @"Cell Label");
                    //cell.detailTextLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
                    break;
                case OS_GROUPCALL:
                    cell.detailTextLabel.text = NSLocalizedString(@"in conference", @"Cell Label");
                    break;
            }
            cell.detailTextLabel.textColor = [UIColor lightGrayColor];
            
            
        } else {
            cell.detailTextLabel.text = NSLocalizedString(@"offline", @"Cell Label");
            cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        }
        
        
        UIImage *userpic = [[C2CallPhone currentPhone] userimageForUserid:userid];
        if (userpic) {
            cell.imageView.image = userpic;
            cell.imageView.contentMode = UIViewContentModeScaleToFill;
        } else {
            cell.imageView.image = [UIImage imageNamed:@"btn_ico_avatar.png"];
            cell.imageView.contentMode = UIViewContentModeScaleToFill;
        }
        
        cell.backgroundColor = [UIColor whiteColor];
        return cell;
        
    }
    else{
        if (userType == 1) {
            WUGroupAdminActionCell* t = [self.tableView dequeueReusableCellWithIdentifier:@"WUGroupAdminActionCell"];
            [t.btnAddMember.titleLabel setFont:[CommonMethods getStdFontType:1]];
            [t.btnClearChat.titleLabel setFont:[CommonMethods getStdFontType:1]];
            [t.btnDeleteGroup.titleLabel setFont:[CommonMethods getStdFontType:1]];
            return t;
        }
        else if (userType == 2) {
            WUGroupMemberActionCell* t =[self.tableView dequeueReusableCellWithIdentifier:@"WUGroupMemberActionCell"];
            [t.btnClearChat.titleLabel setFont:[CommonMethods getStdFontType:1]];
            [t.btnLeaveGroup.titleLabel setFont:[CommonMethods getStdFontType:1]];
            return t;
        }
        else if (isPublic.intValue == 1) {
            WUGroupPublicActionCell* t =[self.tableView dequeueReusableCellWithIdentifier:@"WUGroupPublicActionCell"];
            [t.btnEnterChat.titleLabel setFont:[CommonMethods getStdFontType:1]];
            return t;
        }
        else {
            WUGroupNonMemberActionCell* t = [self.tableView dequeueReusableCellWithIdentifier:@"WUGroupNonMemberActionCell"];
            [t.btnJoinGroup.titleLabel setFont:[CommonMethods getStdFontType:1]];
            return t;
        }
    }
}

-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (userType == 1 && indexPath.section == 1) {
        SCUserProfile *userProfile = [SCUserProfile currentUser];
        if (indexPath.row == 0) {
            return NO;
        }
        else if([userProfile.userid isEqualToString:[memberList objectAtIndex:indexPath.row - 1]]){
            return NO;
        }
        else{
            return YES;
        }
    }
    return NO;
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


#pragma mark - UIButton Action
- (IBAction)btnPhotoTapped:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select photo", @"") delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Select from Camera Roll", @"")];
    }
    
    if ([SIPPhone currentPhone].callStatus == SCCallStatusNone) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [actionSheet addButtonWithTitle:NSLocalizedString(@"Use Camera", @"")];
        }
    }
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.allowsEditing = YES;
    imagePickerController.delegate = self;
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Select from Camera Roll", @"")]) {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Use Camera", @"")]) {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        imagePickerController.showsCameraControls = YES;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}


#pragma mark - UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    groupImg = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    [editCell.btnPhoto setImage:groupImg];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)btnIsPublicTapped:(id)sender{
    NSNumber* isPublic = [groupInfo objectForKey:@"isPublic"];
    if(isPublic.intValue == 1){
        isPublic = [NSNumber numberWithInt:0];
        [editCell.btnIsPublicEdit setTitle:NSLocalizedString(@"Private", @"") forState:UIControlStateNormal];
    }
    else{
        isPublic = [NSNumber numberWithInt:1];
        [editCell.btnIsPublicEdit setTitle:NSLocalizedString(@"Public", @"") forState:UIControlStateNormal];
    }
    [groupInfo setObject:isPublic forKey:@"isPublic"];
   
    
}

- (void)readGroupInfo:(ResponseBase *)response error:(NSError *)error {
    DataResponse *res = (DataResponse *)response;
    
    if (error){
        
    }
    else {
        groupInfo = [[NSMutableDictionary alloc] initWithDictionary:res.data];
        NSNumber* joinStatus = [groupInfo objectForKey:@"isMember"];
        if(joinStatus.intValue == 0){
            userType = 3; //none
        }
        else if (joinStatus.intValue == 1) {
            userType = 2; //accepted
        }
        else if (joinStatus.intValue == 2) {
            userType = 1; //admin
        }
        else if (joinStatus.intValue == 3) {
            userType = 4; //request pending
        }
        else{
            userType = 5; //request rejected
        }
        [self.tableView reloadData];
        
        UIBarButtonItem *newBackButton =
        [[UIBarButtonItem alloc] initWithTitle:[groupInfo objectForKey:@"topic"]
                                         style:UIBarButtonItemStyleBordered
                                        target:nil
                                        action:nil];
        [[self navigationItem] setBackBarButtonItem:newBackButton];
        
        [memberList removeAllObjects];
        for (int i = 0; i < ((NSNumber*)[groupInfo objectForKey:@"memberCnt"]).intValue; i++) {
            [memberList addObject:[groupInfo objectForKey:[NSString stringWithFormat:@"memberID%d", i]]];
        }
        for (int i = 0; i < self.members.count; i++) {
            NSString *userid = [self.members objectAtIndex:i];
            if (![userid isEqualToString:self.group.groupOwner]) {
                BOOL isValid = NO;
                for (int j = 0; j < memberList.count; j++) {
                    if([userid isEqualToString:[memberList objectAtIndex:j]]){
                        isValid = YES;
                    }
                }
                if (!isValid) {
                    SCGroup* tGroup = [[SCGroup alloc] initWithGroupid:self.groupid];
                    [tGroup removeMember:userid];
                    [tGroup saveGroup];
                }
            }
        }
        [self.tableView reloadData];
    }
}

- (IBAction)editEnded{
    if(editCell){
        [groupInfo setObject:editCell.txtTopicEdit.text forKey:@"topic"];
    }
}

-(void)selectedInerestID:(int) i withName:(NSString*) name;{
    [editCell.btnInterestEdit setTitle:name forState:UIControlStateNormal];
    NSNumber* interestID = [NSNumber numberWithInt:i];
    [groupInfo setObject:interestID forKey:@"interestID"];
}

-(void)selectedLocationWithCoord:(CLLocationCoordinate2D)coord typedName:(NSString*)typedname{
    NSNumber* locLat = [NSNumber numberWithFloat:coord.latitude];
    NSNumber* locLong = [NSNumber numberWithFloat:coord.longitude];
    [editCell.btnLocationEdit setTitle:typedname forState:UIControlStateNormal];
    [groupInfo setObject:locLat forKey:@"locationLag"];
    [groupInfo setObject:locLong forKey:@"locationLong"];
    [groupInfo setObject:typedname forKey:@"locationName"];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [self editEnded];
    if ([[segue identifier] isEqualToString:@"EditInterest"]) {
        WUInterestViewController *cvc = (WUInterestViewController *)[segue destinationViewController];
        cvc.delegate = self;
    }
    else if ([[segue identifier] isEqualToString:@"EditLocation"]) {
        WULocationSearchController *cvc = (WULocationSearchController *)[segue destinationViewController];
        cvc.delegate = self;
    }
    else if ([[segue identifier] isEqualToString:@"ViewMedia"]) {
        WUMediaController *mv = (WUMediaController *)[segue destinationViewController];
        mv.targetUserid = [self.group groupid];
    }
    else if ([[segue identifier] isEqualToString:@"ViewMedia2"]) {
        WUMediaController *mv = (WUMediaController *)[segue destinationViewController];
        mv.targetUserid = [self.group groupid];
    }
    else if ([[segue identifier] isEqualToString:@"AddFriend"]){
        WUUserSelectionController *cvc = (WUUserSelectionController *)[segue destinationViewController];
        cvc.delegate = self;
        if(self.members){
            [cvc setSelectedAccount:memberList];
        }
    }
    else{
        [super prepareForSegue:segue sender:sender];
    }
}




-(void)saveGroup{
    [self editEnded];
    [self.group setGroupName: [groupInfo objectForKey:@"topic"]];
    [self.group setGroupdata:[groupInfo objectForKey:@"topicDescription"] forKey:@"topicDesc" public:YES];
    
    for (int i = 0; i < newMemberList.count; i++) {
        [self.group addGroupMember:[newMemberList objectAtIndex:i]];
    }
    
    [self.group saveGroupWithCompletionHandler:^(BOOL success){
        DataRequest *dataRequest = [[DataRequest alloc] init];
        dataRequest.requestName = @"updateGroupInfo";
        dataRequest.values = groupInfo;
        
        WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
        [serviceHandler execute:METHOD_DATA_REQUEST parameter:dataRequest target:self action:@selector(updateGroupInfo:error:)];
        
        
        if (groupImg) {
            DataRequest* datRequest = [[DataRequest alloc] init];
            NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
            
            [data setValue:[self.group groupid] forKey:@"c2CallID"];
            [data setValue:[UIImagePNGRepresentation(groupImg) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength] forKey:@"pic"];
            
            
            datRequest.values = data;
            datRequest.requestName = @"updateGroupPhoto";
            WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
            [serviceHandler execute:METHOD_DATA_REQUEST parameter:datRequest target:self action:@selector(updateGroupPhoto:error:)];
            
        }
        
        [self.activityView stopAnimating];
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
    [self.group setGroupImage:groupImg withCompletionHandler:nil];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [self showActivityView];
}

-(void)saveGroupChanges{
    [self editEnded];
    [self.group setGroupName: [groupInfo objectForKey:@"topic"]];
    [self.group setGroupdata:[groupInfo objectForKey:@"topicDescription"] forKey:@"topicDesc" public:YES];
    
    for (int i = 0; i < newMemberList.count; i++) {
        [self.group addGroupMember:[newMemberList objectAtIndex:i]];
    }
    
    DataRequest *dataRequest = [[DataRequest alloc] init];
    dataRequest.requestName = @"updateGroupInfo";
    dataRequest.values = groupInfo;
    
    WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
    [serviceHandler execute:METHOD_DATA_REQUEST parameter:dataRequest target:self action:@selector(updateGroupInfo:error:)];
    
    
    if (groupImg) {
        DataRequest* datRequest = [[DataRequest alloc] init];
        NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
        
        [data setValue:[self.group groupid] forKey:@"c2CallID"];
        [data setValue:[UIImagePNGRepresentation(groupImg) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength] forKey:@"pic"];
        
        
        datRequest.values = data;
        datRequest.requestName = @"updateGroupPhoto";
        WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
        [serviceHandler execute:METHOD_DATA_REQUEST parameter:datRequest target:self action:@selector(updateGroupPhoto:error:)];
        
    }
}





- (void)updateGroupPhoto:(ResponseBase *)response error:(NSError *)error{
    if (error){
        
    }

}

- (void)updateGroupInfo:(ResponseBase *)response error:(NSError *)error {
    if (error){
        
    }
    else {
        if (newMemberList.count > 0) {
            DataRequest* datRequest = [[DataRequest alloc] init];
            NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
            
            for (int i = 0; i < newMemberList.count; i++) {
                NSDictionary* friendInfo = [[C2CallPhone currentPhone] getUserInfoForUserid:[newMemberList objectAtIndex:i]];
                NSString* memberid = [friendInfo objectForKey:@"Email"];
                memberid = [[memberid componentsSeparatedByString:@"@"] objectAtIndex:0];
                [data setValue:memberid forKey:[NSString stringWithFormat:@"memberID%d", i + 1]];
            }
            
            [data setValue:[NSNumber numberWithInteger:newMemberList.count] forKey:@"memberCnt"];
            
            [data setValue:[groupInfo objectForKey:@"groupID"] forKey:@"groupID"];
            datRequest.values = data;
            datRequest.requestName = @"addGroupMembers";
            
            WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
            [serviceHandler execute:METHOD_DATA_REQUEST parameter:datRequest target:self action: @selector(addGroupUserResponse:error:)];
            
        }
        
        NSMutableArray* groups = [[ResponseHandler instance] groupList];
        for (int i = 0; i < groups.count; i++) {
            WUAccount* a = [groups objectAtIndex:i];
            if ([a.c2CallID isEqualToString:self.group.groupid]) {
                a.name = [groupInfo objectForKey:@"topic"];
            }
        }
    }
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
}

- (IBAction)btnJoinTapped:(id)sender{
    NSNumber* isPublic = [groupInfo objectForKey:@"isPublic"];
    if(isPublic.intValue == 1){
        //join directly
        [self.group joinGroup];
        [self.group saveGroupWithCompletionHandler:^(BOOL success){
            DataRequest* datRequest = [[DataRequest alloc] init];
            NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
            [data setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"msidn"] forKey:@"memberID"];
            [data setValue:[groupInfo objectForKey:@"groupID"] forKey:@"groupID"];
            datRequest.values = data;
            datRequest.requestName = @"addGroupMember";
            
            WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
            [serviceHandler execute:METHOD_DATA_REQUEST parameter:datRequest target:self action: @selector(addGroupUserResponse:error:)];
        }];
    }
    else{
        //submit request
        DataRequest* datRequest = [[DataRequest alloc] init];
        NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
        [data setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"msidn"] forKey:@"memberID"];
        [data setValue:[groupInfo objectForKey:@"groupID"] forKey:@"groupID"];
        [data setValue:[SCUserProfile currentUser].firstname forKey:@"userName"];
        
        datRequest.values = data;
        datRequest.requestName = @"requestJoinGroup";
        
        WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
        [serviceHandler execute:METHOD_DATA_REQUEST parameter:datRequest target:self action: @selector(requestJoinGroupResponse:error:)];
    }
}

- (void)requestJoinGroupResponse:(ResponseBase *)response error:(NSError *)error{
    if (response.errorCode == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Request submitted", @"")
                                                        message:NSLocalizedString(@"Your request is submitted and is waiting for approval", @"")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
        [alert show];
        userType = 4;
        [self.tableView reloadData];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Submission failed", @"")
                                                        message:NSLocalizedString(@"Unable to submit your request", @"")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    
}


- (void)addGroupUserResponse:(ResponseBase *)response error:(NSError *)error{

    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (self.group.groupid != nil) {
        [dictionary setObject:self.group.groupid forKey:@"c2CallID"];
    }
    [dictionary setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"msidn"] forKey:@"userID"];
    DataRequest *dataRequest = [[DataRequest alloc] init];
    dataRequest.requestName = @"readGroupInfo";
    dataRequest.values = dictionary;
    
    WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
    [serviceHandler execute:METHOD_DATA_REQUEST parameter:dataRequest target:self action:@selector(readGroupInfo:error:)];
}


- (IBAction)btnLeaveTapped:(id)sender{
    MOC2CallUser *user = [[SCDataManager instance] userForUserid:self.groupid];
    [[SCDataManager instance] removeDatabaseObject:user];

    
    DataRequest* datRequest = [[DataRequest alloc] init];
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    [data setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"msidn"] forKey:@"memberID"];
    [data setValue:[groupInfo objectForKey:@"groupID"] forKey:@"groupID"];
    datRequest.values = data;
    datRequest.requestName = @"removeGroupMember";
        
    WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
    [serviceHandler execute:METHOD_DATA_REQUEST parameter:datRequest target:self action: @selector(removeGroupUserResponse:error:)];

}

- (void)removeGroupUserResponse:(ResponseBase *)response error:(NSError *)error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Leave Group", @"")
                                                    message:NSLocalizedString(@"You left the group", @"")
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                          otherButtonTitles:nil];
    [alert show];
    NSMutableArray* groups = [[ResponseHandler instance] groupList];
    for (int i = 0; i < groups.count; i++) {
        WUAccount* a = [groups objectAtIndex:i];
        if ([a.c2CallID isEqualToString:self.group.groupid]) {
            [groups removeObjectAtIndex:i];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnChatTapped:(id)sender{
    [self showChatForUserid:self.group.groupid];
}

- (IBAction)btnDeleteTapped:(id)sender{
    currentAction = @"Delete Group";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete this group", @"")
                                                    message:NSLocalizedString(@"Do you really want to delete this group", @"")
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"No", @"")
                                          otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
    [alert show];
}



- (void)deleteGroupResponse:(ResponseBase *)response error:(NSError *)error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete Group", @"")
                                                    message:NSLocalizedString(@"You deleted the group", @"")
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                          otherButtonTitles:nil];
    [alert show];
    NSMutableArray* groups = [[ResponseHandler instance] groupList];
    for (int i = 0; i < groups.count; i++) {
        WUAccount* a = [groups objectAtIndex:i];
        if ([a.c2CallID isEqualToString:self.group.groupid]) {
            [groups removeObjectAtIndex:i];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}




- (IBAction)btnBlockMemberTapped:(id)sender{
    currentAction = @"Block";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Blocking a member", @"")
                                                    message:NSLocalizedString(@"Do you really want to blocked this member", @"")
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"No", @"")
                                          otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
    [alert setTag:((UIButton*)sender).tag];
    [alert show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([currentAction isEqualToString:@"Block"]) {
        if (buttonIndex == 1) {
            
            SCGroup* tGroup = [[SCGroup alloc] initWithGroupid:self.groupid];
            NSString *userid = [memberList objectAtIndex:[alertView tag] - 1];
            int deleteIndex;
            bool isNewMember = false;
            for (int j = 0; j < newMemberList.count; j++) {
                if ([[newMemberList objectAtIndex:j] isEqualToString:userid]) {
                    isNewMember = true;
                    deleteIndex = j;
                }
            }
            if(!isNewMember){
                [self saveGroupChanges];
                
                [self.group removeMember:userid];
                [self.group saveGroupWithCompletionHandler:^(BOOL success){
                    DataRequest* datRequest = [[DataRequest alloc] init];
                    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
                    [data setValue:userid forKey:@"c2CallID"];
                    datRequest.values = data;
                    datRequest.requestName = @"readUserInfo";
                    
                    WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
                    [serviceHandler execute:METHOD_DATA_REQUEST parameter:datRequest target:self action: @selector(readBlockUserInfo:error:)];
                    
                }];
                //[newMemberList removeAllObjects];
                //[self.tableView reloadData];
                //[self showActivityView];
            }
            else{
                [newMemberList removeObjectAtIndex:deleteIndex];
                [memberList removeObjectAtIndex:[alertView tag] - 1];
                [self.tableView reloadData];
            }
        }
        
    }
    else{
        if (buttonIndex == 1) {
            MOC2CallUser *user = [[SCDataManager instance] userForUserid:self.groupid];
            [[SCDataManager instance] removeDatabaseObject:user];
            
            DataRequest* datRequest = [[DataRequest alloc] init];
            NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
            [data setValue:[groupInfo objectForKey:@"groupID"] forKey:@"groupID"];
            datRequest.values = data;
            datRequest.requestName = @"deleteGroup";
            
            WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
            [serviceHandler execute:METHOD_DATA_REQUEST parameter:datRequest target:self action: @selector(deleteGroupResponse:error:)];
        }
    
    }
    
}
    
- (void)readBlockUserInfo:(ResponseBase *)response error:(NSError *)error{
    DataResponse *res = (DataResponse *)response;
    
    if (error){
        
    }
    else {
        [self.activityView stopAnimating];

        NSMutableDictionary* tUser = [[NSMutableDictionary alloc] initWithDictionary:res.data];
        NSString* tUserID = [NSString stringWithFormat:@"%@%@", [tUser objectForKey:@"countryCode"], [tUser objectForKey:@"phoneNo"]];

        DataRequest* datRequest = [[DataRequest alloc] init];
        NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
        [data setValue:tUserID forKey:@"userID"];
        [data setValue:[groupInfo objectForKey:@"groupID"] forKey:@"groupID"];
        datRequest.values = data;
        datRequest.requestName = @"rejectRequest";
        
        WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
        [serviceHandler execute:METHOD_DATA_REQUEST parameter:datRequest target:self action: @selector(rejectGroupUserResponse:error:)];
    }
    
    
}

- (void)rejectGroupUserResponse:(ResponseBase *)response error:(NSError *)error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Member Blocked", @"")
                                                        message:NSLocalizedString(@"You blocked the member", @"")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
    [alert show];
    
    [self showGroupDetailForGroupid:self.groupid];
    [self removeFromParentViewController];
    
}

- (void) showActivityView {
    if (self.activityView==nil) {
        self.activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
        [self.tableView addSubview:self.activityView];
        self.activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray ;
        self.activityView.hidesWhenStopped = YES;
    }
    // Center
    CGFloat x = UIScreen.mainScreen.applicationFrame.size.width/2;
    CGFloat y = UIScreen.mainScreen.applicationFrame.size.height/2;
    // Offset. If tableView has been scrolled
    CGFloat yOffset = self.tableView.contentOffset.y;
    self.activityView.frame = CGRectMake(x, y + yOffset, 0, 0);
    
    self.activityView.hidden = NO;
    [self.activityView startAnimating];
    [self.tableView bringSubviewToFront:self.activityView];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


-(void)selectedUsersUpdated:(NSArray*)users{
    NSString* photoName;
    bool hasRepeat;
    for (int i = 0; i < users.count; i++) {
        hasRepeat = false;
        photoName = [users objectAtIndex:i];
        for (int j = 0; j < memberList.count; j++) {
            if ([[memberList objectAtIndex:j] isEqualToString:photoName]) {
                hasRepeat = true;
            }
        }
        if(!hasRepeat){
            [memberList addObject:[users objectAtIndex:i]];
            [newMemberList addObject:[users objectAtIndex:i]];
        }
    }
    
    
    [self.tableView reloadData];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    NSLog(@"went here ...");
    
    if((![touch.view isKindOfClass:[UITextView class]])
       && (![touch.view isKindOfClass:[UITextField class]])){
        [self.view endEditing:YES];
    }
    
    return NO; // handle the touch
}

- (IBAction)btnClearChatTapped:(id)sender{
    NSLog(@"Clear all chat");
    // TODO clear all chat history
    NSArray* result = [DBHandler dataFromTable:@"MOChatHistory" condition:[NSString stringWithFormat:@"contact = '%@'", self.groupid] orderBy:nil ascending:false];
    if (result.count > 0) {
        [[SCDataManager instance] removeDatabaseObject:[result objectAtIndex:0]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Chat cleared", @"")
                                                        message:NSLocalizedString(@"You cleared the chat history", @"")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
        [alert show];
        
    }

}

@end
