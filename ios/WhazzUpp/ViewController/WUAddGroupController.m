//
//  WUAddGroupController.m
//  WhazzUpp
//
//  Created by Sahil.Khanna on 09/06/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import "WUAddGroupController.h"
#import "WUChatController.h"
#import "SocialCommunication/SCGroupNameCell.h"
#import "AddChatGroupDTO.h"
#import "WebserviceHandler.h"
#import "ResponseBase.h"


#define kGroupImage_SelectFromCameraRoll @"Select from Camera Roll"
#define kGroupImage_UseCamera @"Use Camera"

@interface WUAddGroupController (){
    int interestID;
}
@end

@implementation WUAddGroupController

#pragma mark - UIViewController Delegate
- (void)viewDidLoad {
    [super viewDidLoad];
    
    btnGroupImage.imageView.layer.cornerRadius = 40.0;
    btnGroupImage.imageView.layer.masksToBounds = YES;
    
    [self setAddGroupAction:^(NSString *groupid) {
        if ([self.parentController respondsToSelector:@selector(setCreatedGroupId:)]) {
            [self.parentController performSelector:@selector(setCreatedGroupId:) withObject:groupid];
            
            if (btnGroupImage.imageView.image) {
                SCGroup *group = [[SCGroup alloc] initWithGroupid:groupid];
                [group setGroupImage:btnGroupImage.imageView.image withCompletionHandler:nil];
            }
            
            //update c2call id and other details to server
            NSString *msdin = [[NSUserDefaults standardUserDefaults] objectForKey:@"msidn"];
            
            AddChatGroupDTO *addChatGroupDTO = [[AddChatGroupDTO alloc] init];
            addChatGroupDTO.topicDescription = txtTopic2.text;
            addChatGroupDTO.groupAdmin = msdin;
            addChatGroupDTO.interestID = [NSString stringWithFormat:@"%d", interestID];
            addChatGroupDTO.interestDescription = txtSubInterest.text;
            addChatGroupDTO.c2CallID = groupid;
            
            WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
            [serviceHandler execute:METHOD_ADD_CHAT_GROUP parameter:addChatGroupDTO target:self action:@selector(addChatGroupResponse:error:)];

            
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)addChatGroupResponse:(ResponseBase *)response error:(NSError *)error{
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
    [btnGroupImage setImage:[info objectForKey:@"UIImagePickerControllerEditedImage"] forState:UIControlStateNormal];
    
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

- (IBAction)txtSubInterestDone{
    [txtSubInterest resignFirstResponder];
}

- (IBAction)txtTopicDone{
    [txtTopic resignFirstResponder];
}

- (IBAction)txtTopic2Done{
    [txtTopic2 resignFirstResponder];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"Interest"]) {
        WUInterestViewController *cvc = (WUInterestViewController *)[segue destinationViewController];
        cvc.delegate = self;
    }
    else{
        [super prepareForSegue:segue sender:sender];
    }
}

-(void)selectedInerestID:(int) i withName:(NSString*) name;{
    interestID = i;
    [btnInterest setTitle:name forState:UIControlStateNormal];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        SCGroupNameCell* cell = (SCGroupNameCell*)[super tableView:tableView cellForRowAtIndexPath:indexPath];
        [cell.groupName setHidden:YES];
        return cell;
    }
    else{
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}



@end