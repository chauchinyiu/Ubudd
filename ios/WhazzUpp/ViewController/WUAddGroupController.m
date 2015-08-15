//
//  WUAddGroupController.m
//  WhazzUpp
//
//  Created by Sahil.Khanna on 09/06/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import <SocialCommunication/UIViewController+SCCustomViewController.h>
#import "WUAddGroupController.h"
#import "WUChatController.h"
#import "SocialCommunication/SCGroupNameCell.h"
#import "AddChatGroupDTO.h"
#import "WebserviceHandler.h"
#import "ResponseBase.h"
#import "ResponseHandler.h"
#import "WUFriendDetailController.h"
#import "WUUserImageController.h"
#import "CommonMethods.h"
#import "DataRequest.h"

@implementation WUGroupMemberCell
    @synthesize nameLabel, userImg;
@end

@interface WUAddGroupController (){
    int interestID;
    CLLocationCoordinate2D loc;
    BOOL isPublic;
    BOOL inWorking;
    BOOL hasImage;
    NSMutableArray* friendList;
    BOOL hasNoMember;
    NSString* newID;
    UIImage* newImage;
}
@end

@implementation WUAddGroupController

#pragma mark - UIViewController Delegate
- (void)viewDidLoad {
    [super viewDidLoad];
    //btnPhoto.layer.cornerRadius = 0.0;
    btnPhoto.layer.masksToBounds = YES;
    [btnPhoto setTapAction:^{
        if(hasImage){
            [CommonMethods showSinglePhoto:btnPhoto.image title:@"" onNavigationController:self.navigationController];
        }
        else{
            [self btnPhotoTapped:btnPhoto];
        }
    }];

    loc.latitude = 999;
    loc.longitude = 999;
    isPublic = false;
    interestID = -1;
    hasImage = false;
    [btnIsPublic setTitle:NSLocalizedString(@"Private", @"") forState:UIControlStateNormal];
    [btnDone setEnabled:NO];
    
    [self setAddGroupAction:^(NSString *groupid) {
        [btnDone setEnabled:NO];
        if ([self.parentController respondsToSelector:@selector(setCreatedGroupId:)]) {
            [self.parentController performSelector:@selector(setCreatedGroupId:) withObject:groupid];
            
            if (hasImage) {
                SCGroup *group = [[SCGroup alloc] initWithGroupid:groupid];
                [group setGroupImage:btnPhoto.image withCompletionHandler:nil];
            }
            SCGroup *group = [[SCGroup alloc] initWithGroupid:groupid];
            [group makePublic:YES];
            [group saveGroupWithCompletionHandler:^(BOOL success) {
                
            }];
            
            WUAccount* a = [[WUAccount alloc] init];
            a.c2CallID = groupid;
            a.name = txtTopic.text;
            a.createTime = [NSDate dateWithTimeIntervalSinceNow:0];
            [[[ResponseHandler instance] groupList] addObject:a];

            
            //update c2call id and other details to server
            NSString *msdin = [[NSUserDefaults standardUserDefaults] objectForKey:@"msidn"];
            
            AddChatGroupDTO *addChatGroupDTO = [[AddChatGroupDTO alloc] init];
            addChatGroupDTO.groupAdmin = msdin;
            addChatGroupDTO.interestID = [NSString stringWithFormat:@"%d", interestID];
            addChatGroupDTO.c2CallID = groupid;
            addChatGroupDTO.location = btnLocation.titleLabel.text;
            addChatGroupDTO.latCoord = loc.latitude;
            addChatGroupDTO.longCoord = loc.longitude;
            addChatGroupDTO.topic = txtTopic.text;
            addChatGroupDTO.isPublic = isPublic;
            newID = [NSString stringWithString:groupid];
            newImage = btnPhoto.image;
            if (!hasNoMember) {
                for (int i = 0; i < self.members.count; i++) {
                    NSDictionary* friendInfo = [[C2CallPhone currentPhone] getUserInfoForUserid:[self.members objectAtIndex:i]];
                    NSString* memberid = [friendInfo objectForKey:@"Email"];
                    memberid = [[memberid componentsSeparatedByString:@"@"] objectAtIndex:0];
                    [addChatGroupDTO.members addObject:memberid];
                }
            }
            
            WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
            [serviceHandler execute:METHOD_ADD_CHAT_GROUP parameter:addChatGroupDTO target:self action:@selector(addChatGroupResponse:error:)];

            
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(hidekeybord)];
    [tap setDelegate:self];
    [self.view addGestureRecognizer:tap];

    [self setTitle:NSLocalizedString(@"New Group", @"")];
    friendList = [[ResponseHandler instance] friendList];
    
    [txtTopic setFont:[CommonMethods getStdFontType:1]];
    [btnInterest.titleLabel setFont:[CommonMethods getStdFontType:1]];
    [btnLocation.titleLabel setFont:[CommonMethods getStdFontType:1]];
    [btnIsPublic.titleLabel setFont:[CommonMethods getStdFontType:1]];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self checkFilled];
    inWorking = false;
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.translucent = NO;
}



- (void)addChatGroupResponse:(ResponseBase *)response error:(NSError *)error{
    
    if (hasImage) {
        DataRequest* datRequest = [[DataRequest alloc] init];
        NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
        
        [data setValue:newID forKey:@"c2CallID"];
        [data setValue:[UIImagePNGRepresentation(newImage) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength] forKey:@"pic"];
        
        datRequest.values = data;
        datRequest.requestName = @"updateGroupPhoto";
        WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
        [serviceHandler execute:METHOD_DATA_REQUEST parameter:datRequest target:self action:@selector(updateGroupPhoto:error:)];
        
    }
    
}

- (void)updateGroupPhoto:(ResponseBase *)response error:(NSError *)error{
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}


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
    hasImage = true;
    btnPhoto.image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 0;
    }
    else if (indexPath.section == 0 && indexPath.row == 1) {
        return 42;
    }
    else{
        return 36;
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"Interest"]) {
        WUInterestViewController *cvc = (WUInterestViewController *)[segue destinationViewController];
        cvc.delegate = self;
    }
    else if ([[segue identifier] isEqualToString:@"LocationSearch"]) {
        WULocationSearchController *cvc = (WULocationSearchController *)[segue destinationViewController];
        cvc.delegate = self;
    }
    else{
        WUUserSelectionController *cvc = (WUUserSelectionController *)[segue destinationViewController];
        cvc.delegate = self;
        if(self.members){
            [cvc setSelectedAccount:self.members];
        }
        //[super prepareForSegue:segue sender:sender];
    }
}

-(void)selectedInerestID:(int) i withName:(NSString*) name;{
    interestID = i;
    [btnInterest setTitle:name forState:UIControlStateNormal];
    [self checkFilled];
    
}

-(void)selectedLocationWithCoord:(CLLocationCoordinate2D)coord typedName:(NSString*)typedname{
    loc = coord;
    [btnLocation setTitle:typedname forState:UIControlStateNormal];
    [self checkFilled];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        SCGroupNameCell* cell = (SCGroupNameCell*)[super tableView:tableView cellForRowAtIndexPath:indexPath];
        [cell.groupName setHidden:YES];
        return cell;
    }
    else if (indexPath.section == 0 && indexPath.row == 1) {
        SCGroupAddMembersCell* c = (SCGroupAddMembersCell*)[super tableView:tableView cellForRowAtIndexPath:indexPath];
        [c.numMembers setText:[NSString stringWithFormat:NSLocalizedString(@"memberOutOf", @""), (int)self.members.count]];
        return c;
    }
    else{
        [self checkFilled];
        WUGroupMemberCell* t = (WUGroupMemberCell *)[self.tableView dequeueReusableCellWithIdentifier:@"GroupMemberCell"];
        NSString* memberID = [self.members objectAtIndex:indexPath.row];
        [t.nameLabel setFont:[CommonMethods getStdFontType:1]];
        for (int i = 0; i < friendList.count; i++) {
            WUAccount* a = [friendList objectAtIndex:i];
            if ([a.c2CallID isEqualToString:memberID]) {
                [t.nameLabel setText:a.name];
                
                UIImage* image = [[C2CallPhone currentPhone] userimageForUserid:a.c2CallID];
                if(image){
                    [t.userImg setImage:image];
                }
                else{
                    NSDictionary* userInfo = [[C2CallPhone currentPhone] getUserInfoForUserid:a.c2CallID];
                    NSString* imageName = [userInfo objectForKey:@"ImageLarge"];
                    if(imageName){
                        image = [[C2CallPhone currentPhone] imageForKey:imageName];
                        if(image){
                            [t.userImg setImage:image];
                        }
                        else{
                            image = [UIImage imageNamed:@"btn_ico_avatar.png"];
                            [t.userImg setImage:image];
                        }
                    }
                }
                
            }
        }
        

        
        return t;
    }
}

- (IBAction)btnIsPublicTapped:(id)sender{
    isPublic = !isPublic;
    if (isPublic) {
        [btnIsPublic setTitle:NSLocalizedString(@"Public", @"") forState:UIControlStateNormal];
    }
    else{
        [btnIsPublic setTitle:NSLocalizedString(@"Private", @"") forState:UIControlStateNormal];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    NSLog(@"went here ...");
    
    if((![touch.view isKindOfClass:[UITextView class]])
       && (![touch.view isKindOfClass:[UITextField class]])){
        [self.view endEditing:YES];
    }

    return NO; // handle the touch
}

-(void)hidekeybord
{
    [self.view endEditing:YES];
}

- (IBAction)editEnded{
    [self checkFilled];
}

-(void)checkFilled{
    [btnDone setEnabled:[self detailFilled]];
}

-(bool)detailFilled{
    if ([txtTopic.text isEqualToString:@""]) {
        return NO;
    }
    if (interestID < 1) {
        return NO;
    }
    if (loc.latitude == 999) {
        return NO;
    }
    //if (self.members.count == 0){
    //    return NO;
    //}
    if (self.members.count > 199){
        return NO;
    }
    return YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
    }
    else{
        NSMutableArray* friendList = [[ResponseHandler instance] friendList];
        for (int i = 0; i < friendList.count; i++) {
            WUAccount* a = [friendList objectAtIndex:i];
            if ([a.c2CallID isEqualToString:[self.members objectAtIndex:indexPath.row]]) {
                [WUFriendDetailController setPhoneNo:a.phoneNo];
            }
        }
        [self showFriendDetailForUserid:[self.members objectAtIndex:indexPath.row]];
    }
}


- (IBAction)createGroup:(id)sender{
    if (!inWorking) {
        inWorking = true;
        [super createGroup:sender];
    }
}

-(void)selectedUsersUpdated:(NSArray*)users{
    self.members = users;
    [self.tableView reloadData];
}

- (IBAction)btnAddGroupClicked:(id)sender{
    if (self.members.count == 0) {
        NSMutableArray* defMember;
        defMember = [[NSMutableArray alloc] init];
        [defMember addObject:[[SCUserProfile currentUser] userid]];
        self.members = defMember;
        hasNoMember = true;
    }
    else{
        hasNoMember = false;
    }
    [self createGroup:sender];
    
}

@end