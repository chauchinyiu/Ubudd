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

@interface WUGroupDetailController (){
    int userType;
    NSMutableDictionary* groupInfo;
    WUGroupDetailCellEdit* editCell;
    UIImage* groupImg;
    NSMutableArray* friendList;
    NSMutableArray* memberList;
    NSMutableArray* newMemberList;
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
            return 0;
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
            return 320;
        }
        else{
            return 320;
        }
    }
    else if(indexPath.section == 2){
        if (userType == 1) {
            return 120;
        }
        else{
            return 80;
        }
        
    }
    else if(indexPath.section == 1){
        if (indexPath.row > 0) {
            NSString * userid = [memberList objectAtIndex:indexPath.row - 1];
            if([userid isEqualToString:self.group.groupOwner]){
                return 0;
            }
        }
    }
    return 44;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];

    if (indexPath.section == 1){
        NSString *userid;
        if (indexPath.row == 0) {
            userid = self.group.groupOwner;
        }
        else{
            userid = [memberList objectAtIndex:indexPath.row - 1];
        }
        
        if ([userid isEqualToString:[SCUserProfile currentUser].userid]) {
            
        } else {
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
                cell.btnPhoto.layer.cornerRadius = 0.0;
                cell.btnPhoto.layer.masksToBounds = YES;                
                [cell.btnPhoto setTapAction:^{
                    if (groupImg) {
                        NSString * storyboardName = @"MainStoryboard";
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                        WUUserImageController * vc = [storyboard instantiateViewControllerWithIdentifier:@"SCUserImageController"];
                        vc.viewImage = cell.btnPhoto.image;
                        [self.navigationController pushViewController:vc animated:YES];
                    }
                    else{
                        [self btnPhotoTapped:cell.btnPhoto];
                    }
                }];
                
                if(groupImg){
                    [cell.btnPhoto setImage:groupImg];
                }

                [cell.txtTopicEdit setText:[groupInfo objectForKey:@"topic"]];
                [cell.txtTopic2Edit setText:[groupInfo objectForKey:@"topicDescription"]];

                int interestID = [[groupInfo objectForKey:@"interestID"] integerValue];
                [cell.btnInterestEdit setTitle:[[ResponseHandler instance] getInterestNameForID:interestID] forState:UIControlStateNormal];
                [cell.txtSubInterestEdit setText:[groupInfo objectForKey:@"interestDescription"]];
                
                [cell.btnLocationEdit setTitle:[groupInfo objectForKey:@"locationName"] forState:UIControlStateNormal];

                NSNumber* isPublic = [groupInfo objectForKey:@"isPublic"];
                if(isPublic.intValue == 1){
                    [cell.btnIsPublicEdit setTitle:NSLocalizedString(@"Public", @"") forState:UIControlStateNormal];
                }
                else{
                    [cell.btnIsPublicEdit setTitle:NSLocalizedString(@"Private", @"") forState:UIControlStateNormal];
                }
                NSNumber* memberCnt = [groupInfo objectForKey:@"memberCnt"];
                [cell.lblMemberCntEdit setText:[NSString stringWithFormat:NSLocalizedString(@"Members X OF 200", @""), memberCnt.intValue + 1]];
                
            }
            editCell = cell;

            return cell;
        }
        else{
            WUGroupDetailCellReadOnly *cell = [self.tableView dequeueReusableCellWithIdentifier:@"WUGroupDetailCellReadOnly"];
            if (groupInfo) {
                
                if (groupImg) {
                    [cell.groupImg setImage:groupImg];
                }
                [cell.lblTopic setText:[groupInfo objectForKey:@"topic"]];
                [cell.lblTopicDesc setText:[groupInfo objectForKey:@"topicDescription"]];
                
                int interestID = [[groupInfo objectForKey:@"interestID"] integerValue];
                [cell.lblInterest setText:[[ResponseHandler instance] getInterestNameForID:interestID]];
                [cell.lblSubinterest setText:[groupInfo objectForKey:@"interestDescription"]];
                
                [cell.lblLocation setText:[groupInfo objectForKey:@"locationName"]];
                
                NSNumber* isPublic = [groupInfo objectForKey:@"isPublic"];
                if(isPublic.intValue == 1){
                    [cell.lblPublic setText:NSLocalizedString(@"Public", @"")];
                }
                else{
                    [cell.lblPublic setText:NSLocalizedString(@"Private", @"")];
                }
                
                NSNumber* memberCnt = [groupInfo objectForKey:@"memberCnt"];
                [cell.lblMemberCnt setText:NSLocalizedString(@"Members X OF 200", @"")];
                
                [cell.lblHost setText:[groupInfo objectForKey:@"userName"]];
                
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
                    
                    if (userType == 3) {
                        [cell.lblJoinStatus setText:NSLocalizedString(@"Non member", @"")];
                    }
                }
                
            }
            return cell;
        }
    }
    else if (indexPath.section == 0 && indexPath.row == 1) {
        WUGroupViewMediaCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"WUGroupViewMediaCell"];
        return cell;
    }
    else if (indexPath.section == 1){
        static NSString *CellIdentifier = @"SCGroupMemberCell";
    
        SCGroupMemberCell *cell = (SCGroupMemberCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.tag = indexPath.row;
        [cell setHidden:NO];
        
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
        } else {
            MOC2CallUser *member = [[SCDataManager instance] userForUserid:userid];
            displayName = [member.displayName copy];
            if (!member) {
                NSString *user = [memberList objectAtIndex:indexPath.row - 1];
                NSString *firstname = [self.group firstnameForGroupMember:user];
                
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
            cell.textLabel.textColor = [UIColor blueColor];
            [cell.textLabel setText:[cell.textLabel.text stringByAppendingString:NSLocalizedString(@"Group Admin", @"")]];
        } else {
            cell.textLabel.textColor = [UIColor darkTextColor];
            if (userType == 1) {
                [cell.inviteButton setHidden:NO];
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
                    cell.detailTextLabel.textColor = [UIColor blackColor];
                    break;
                case OS_FORWARDED:
                    cell.detailTextLabel.text = NSLocalizedString(@"Call forward", @"Cell Label");
                    cell.detailTextLabel.textColor = [UIColor blackColor];
                    break;
                case OS_INVISIBLE:
                    cell.detailTextLabel.text = NSLocalizedString(@"offline", @"Cell Label");
                    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
                    break;
                case OS_AWAY:
                    cell.detailTextLabel.text = NSLocalizedString(@"offline (away)", @"Cell Label");
                    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
                    break;
                case OS_BUSY:
                    cell.detailTextLabel.text = NSLocalizedString(@"offline (busy)", @"Cell Label");
                    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
                    break;
                case OS_CALLME:
                    cell.detailTextLabel.text = NSLocalizedString(@"online (call me)", @"Cell Label");
                    cell.detailTextLabel.textColor = [UIColor blackColor];
                    break;
                case OS_ONLINEVIDEO:
                    cell.detailTextLabel.text = NSLocalizedString(@"online (active)", @"Cell Label");
                    break;
                case OS_IPUSH:
                    cell.detailTextLabel.text = NSLocalizedString(@"online", @"Cell Label");
                    cell.detailTextLabel.textColor = [UIColor blackColor];
                    break;
                case OS_IPUSHCALL:
                    cell.detailTextLabel.text = NSLocalizedString(@"online", @"Cell Label");
                    cell.detailTextLabel.textColor = [UIColor blackColor];
                    break;
                case OS_GROUPCALL:
                    cell.detailTextLabel.text = NSLocalizedString(@"in conference", @"Cell Label");
                    break;
            }
            
        } else {
            cell.detailTextLabel.text = NSLocalizedString(@"offline", @"Cell Label");
            cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        }
        
        //cell.detailTextLabel.text = [[member elementForName:@"EMail"] stringValue];
        
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
            return [self.tableView dequeueReusableCellWithIdentifier:@"WUGroupAdminActionCell"];
        }
        else if (userType == 2) {
            return [self.tableView dequeueReusableCellWithIdentifier:@"WUGroupMemberActionCell"];
        }
        else if (isPublic.intValue == 1) {
            return [self.tableView dequeueReusableCellWithIdentifier:@"WUGroupPublicActionCell"];
        }
        else {
            return [self.tableView dequeueReusableCellWithIdentifier:@"WUGroupNonMemberActionCell"];
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
        [editCell.btnIsPublicEdit setTitle:NSLocalizedString(@"Public", @"") forState:UIControlStateNormal];
    }
    else{
        isPublic = [NSNumber numberWithInt:1];
        [editCell.btnIsPublicEdit setTitle:NSLocalizedString(@"Private", @"") forState:UIControlStateNormal];
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
        if (joinStatus.intValue == 1) {
            userType = 2;
        }
        else if (joinStatus.intValue == 2) {
            userType = 1;
        }
        else{
            userType = 4;
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
    [groupInfo setObject:editCell.txtTopicEdit.text forKey:@"topic"];
    [groupInfo setObject:editCell.txtTopic2Edit.text forKey:@"topicDescription"];
    [groupInfo setObject:editCell.txtSubInterestEdit.text forKey:@"interestDescription"];
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
        
        
        
    }];
    [self.group setGroupImage:groupImg withCompletionHandler:nil];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [self showActivityView];
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
        
        
        [self.activityView stopAnimating];
        [self.navigationController popViewControllerAnimated:YES];
        
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
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [self.tableView reloadData];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Submittion failed", @"")
                                                        message:NSLocalizedString(@"Unable to submit your request", @"")
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
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
    [self showChatForUserid:self.group.groupid];
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
                                          cancelButtonTitle:@"OK"
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



- (void)deleteGroupResponse:(ResponseBase *)response error:(NSError *)error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete Group", @"")
                                                    message:NSLocalizedString(@"You deleted the group", @"")
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Blocking a member", @"")
                                                    message:NSLocalizedString(@"Do you really want to blocked this member", @"")
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"No", @"")
                                          otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
    [alert setTag:((UIButton*)sender).tag];
    [alert show];
}
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        SCGroup* tGroup = [[SCGroup alloc] initWithGroupid:self.groupid];
        NSString *userid = [self.members objectAtIndex:[alertView tag]];
        [tGroup removeMember:userid];
        [tGroup saveGroupWithCompletionHandler:^(BOOL success){
            DataRequest* datRequest = [[DataRequest alloc] init];
            NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
            [data setValue:userid forKey:@"c2CallID"];
            datRequest.values = data;
            datRequest.requestName = @"readUserInfo";
            
            WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
            [serviceHandler execute:METHOD_DATA_REQUEST parameter:datRequest target:self action: @selector(readBlockUserInfo:error:)];
            
        }];
        
        [self showActivityView];
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
                                              cancelButtonTitle:@"OK"
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
    for (int i = 0; i < users.count; i++) {
        [memberList addObject:[users objectAtIndex:i]];
        [newMemberList addObject:[users objectAtIndex:i]];
    }
    [self.tableView reloadData];
}


@end
