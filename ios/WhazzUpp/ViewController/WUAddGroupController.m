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

#define kGroupImage_SelectFromCameraRoll @"Select from Camera Roll"
#define kGroupImage_UseCamera @"Use Camera"

@interface WUAddGroupController (){
    int interestID;
    CLLocationCoordinate2D loc;
    BOOL isPublic;
    BOOL inWorking;
    BOOL hasImage;
    NSMutableArray* friendList;
}
@end

@implementation WUAddGroupController

#pragma mark - UIViewController Delegate
- (void)viewDidLoad {
    [super viewDidLoad];
    btnPhoto.layer.cornerRadius = 0.0;
    btnPhoto.layer.masksToBounds = YES;
    [btnPhoto setTapAction:^{
        
        NSString * storyboardName = @"MainStoryboard";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        WUUserImageController * vc = [storyboard instantiateViewControllerWithIdentifier:@"SCUserImageController"];
        vc.viewImage = btnPhoto.image;
        [self.navigationController pushViewController:vc animated:YES];
    }];

    loc.latitude = 999;
    loc.longitude = 999;
    isPublic = false;
    interestID = -1;
    hasImage = false;
    [btnIsPublic setTitle:@"Private" forState:UIControlStateNormal];
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
            [group setGroupdata:txtTopic2.text forKey:@"topicDesc" public:YES];
            [group makePublic:YES];
            [group saveGroup];
            
            //update c2call id and other details to server
            NSString *msdin = [[NSUserDefaults standardUserDefaults] objectForKey:@"msidn"];
            
            AddChatGroupDTO *addChatGroupDTO = [[AddChatGroupDTO alloc] init];
            addChatGroupDTO.topicDescription = txtTopic2.text;
            addChatGroupDTO.groupAdmin = msdin;
            addChatGroupDTO.interestID = [NSString stringWithFormat:@"%d", interestID];
            addChatGroupDTO.interestDescription = txtSubInterest.text;
            addChatGroupDTO.c2CallID = groupid;
            addChatGroupDTO.location = btnLocation.titleLabel.text;
            addChatGroupDTO.latCoord = loc.latitude;
            addChatGroupDTO.longCoord = loc.longitude;
            addChatGroupDTO.topic = txtTopic.text;
            addChatGroupDTO.isPublic = isPublic;
            
            for (int i = 0; i < self.members.count; i++) {
                NSDictionary* friendInfo = [[C2CallPhone currentPhone] getUserInfoForUserid:[self.members objectAtIndex:i]];
                NSString* memberid = [friendInfo objectForKey:@"Email"];
                memberid = [[memberid componentsSeparatedByString:@"@"] objectAtIndex:0];
                [addChatGroupDTO.members addObject:memberid];
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

    [self setTitle:@"New Event"];
    friendList = [[ResponseHandler instance] friendList];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self checkFilled];
    inWorking = false;
}



- (void)addChatGroupResponse:(ResponseBase *)response error:(NSError *)error{
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}


#pragma mark - UIButton Action
- (IBAction)btnPhotoTapped:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select photo" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [actionSheet addButtonWithTitle:kGroupImage_SelectFromCameraRoll];
    }
    
    if ([SIPPhone currentPhone].callStatus == SCCallStatusNone) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [actionSheet addButtonWithTitle:kGroupImage_UseCamera];
        }
    }
    
    [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.allowsEditing = YES;
    imagePickerController.delegate = self;
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kGroupImage_SelectFromCameraRoll]) {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kGroupImage_UseCamera]) {
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
    else{
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
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
        [c.numMembers setText:[NSString stringWithFormat:@"(%d of 199)", self.members.count]];
        return c;
    }
    else{
        [self checkFilled];
        UITableViewCell* t = [super tableView:tableView cellForRowAtIndexPath:indexPath];
        NSString* memberID = [self.members objectAtIndex:indexPath.row];
        for (int i = 0; i < friendList.count; i++) {
            WUAccount* a = [friendList objectAtIndex:i];
            if ([a.c2CallID isEqualToString:memberID]) {
                [t.textLabel setText:a.name];
            }
        }
        [t.detailTextLabel setText:@""];
        return t;
    }
}

- (IBAction)btnIsPublicTapped:(id)sender{
    isPublic = !isPublic;
    if (isPublic) {
        [btnIsPublic setTitle:@"Public" forState:UIControlStateNormal];
    }
    else{
        [btnIsPublic setTitle:@"Private" forState:UIControlStateNormal];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    NSLog(@"went here ...");
    
    [self.view endEditing:YES];
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
    if (self.members.count == 0){
        return NO;
    }
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

@end