//
//  WUGroupDetailController.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 21/9/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "WUGroupDetailController.h"
#import "DataRequest.h"
#import "DataResponse.h"
#import "WebserviceHandler.h"
#import "ResponseHandler.h"
#define kGroupImage_SelectFromCameraRoll @"Select from Camera Roll"
#define kGroupImage_UseCamera @"Use Camera"


@implementation WUGroupDetailCellEdit
@end

@implementation WUGroupDetailCellReadOnly
@end

@interface WUGroupDetailController (){
    CGFloat editCellHeight;
    CGFloat readOnlyCellHeight;
    CGFloat memberCellHeight;
    BOOL isOwner;
    NSMutableDictionary* groupInfo;
    WUGroupDetailCellEdit* editCell;
    UIImage* groupImg;
    
}
@property(nonatomic, strong) SCGroup *group;
@property(nonatomic, strong) NSArray *members;

@end

@implementation WUGroupDetailController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    WUGroupDetailCellEdit *cell = [self.tableView dequeueReusableCellWithIdentifier:@"WUGroupDetailCellEdit"];
    editCellHeight = cell.frame.size.height;
    
    WUGroupDetailCellReadOnly *cell2 = [self.tableView dequeueReusableCellWithIdentifier:@"WUGroupDetailCellReadOnly"];
    readOnlyCellHeight = cell2.frame.size.height;
    
    SCGroupMemberCell *cell3 = [self.tableView dequeueReusableCellWithIdentifier:@"SCGroupMemberCell"];
    memberCellHeight = cell3.frame.size.height;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(hidekeybord)];
    [tap setDelegate:self];
    [self.view addGestureRecognizer:tap];
    
    self.group = [[SCGroup alloc] initWithGroupid:self.groupid];
    groupImg = self.group.groupImage;
    isOwner = [self.group.groupOwner isEqualToString:[SCUserProfile currentUser].userid];
    if (isOwner) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveGroup)];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
    
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    }
    else{
        return [self.members count];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (isOwner) {
            return editCellHeight;
        }
        else{
            return readOnlyCellHeight;
        }
    }
    else{
        return memberCellHeight;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (isOwner) {
            WUGroupDetailCellEdit *cell = [self.tableView dequeueReusableCellWithIdentifier:@"WUGroupDetailCellEdit"];
            if (groupInfo) {
                cell.btnGroupImageEdit.imageView.layer.cornerRadius = 40.0;
                cell.btnGroupImageEdit.imageView.layer.masksToBounds = YES;

                [cell.btnGroupImageEdit setImage:groupImg forState:UIControlStateNormal];
                [cell.txtTopicEdit setText:[groupInfo objectForKey:@"topic"]];
                [cell.txtTopic2Edit setText:[groupInfo objectForKey:@"topicDescription"]];

                int interestID = [[groupInfo objectForKey:@"interestID"] integerValue];
                [cell.btnInterestEdit setTitle:[[ResponseHandler instance] getInterestNameForID:interestID] forState:UIControlStateNormal];
                [cell.txtSubInterestEdit setText:[groupInfo objectForKey:@"interestDescription"]];
                
                [cell.btnLocationEdit setTitle:[groupInfo objectForKey:@"locationName"] forState:UIControlStateNormal];

                NSNumber* isPublic = [groupInfo objectForKey:@"isPublic"];
                if(isPublic.intValue == 1){
                    [cell.btnIsPublicEdit setTitle:@"Public" forState:UIControlStateNormal];
                }
                else{
                    [cell.btnIsPublicEdit setTitle:@"Private" forState:UIControlStateNormal];
                }
                
                NSNumber* memberCnt = [groupInfo objectForKey:@"memberCnt"];
                [cell.lblMemberCntEdit setText:[NSString stringWithFormat:@"Members: %d OF 50", memberCnt.intValue + 1]];
                
            }
            editCell = cell;
            return cell;
        }
        else{
            WUGroupDetailCellReadOnly *cell = [self.tableView dequeueReusableCellWithIdentifier:@"WUGroupDetailCellReadOnly"];
            return cell;
        }
    }
    else{
        NSIndexPath* ipath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
        static NSString *CellIdentifier = @"SCGroupMemberCell";
        
        SCGroupMemberCell *cell = (SCGroupMemberCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        [cell.inviteButton setHidden:YES];
        
        NSString *userid = [self.members objectAtIndex:indexPath.row];
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
                NSString *user = [self.members objectAtIndex:indexPath.row];
                
                NSString *lastname = [self.group nameForGroupMember:user];
                NSString *firstname = [self.group firstnameForGroupMember:user];
                NSString *email = [self.group emailForGroupMember:user];
                
                if ([lastname length] > 0 && [firstname length] > 0) {
                    displayName = [NSString stringWithFormat:@"%@ %@", firstname, lastname];
                } else if (firstname) {
                    displayName = firstname;
                } else if (lastname) {
                    displayName = lastname;
                } else {
                    displayName = email;
                }
            } else {
                online = [[member onlineStatus] intValue];
            }
        }
        
        cell.textLabel.text = displayName;
        if ([self.group.groupOwner isEqualToString:userid]) {
            cell.textLabel.textColor = [UIColor blueColor];
            [cell.textLabel setText:[cell.textLabel.text stringByAppendingString:@"(Group Admin)"]];
        } else {
            cell.textLabel.textColor = [UIColor darkTextColor];
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
        
        /*
        UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:ipath];
        if ([cell isKindOfClass:[SCGroupMemberCell class]]) {
            SCGroupMemberCell *c = (SCGroupMemberCell*)cell;
            NSString *userid = [self.members objectAtIndex:indexPath.row];
            
            if ([self.group.groupOwner isEqualToString:userid]) {
                [c.textLabel setText:[c.textLabel.text stringByAppendingString:@"(Group Admin)"]];
            }
        }
        return cell;
         */
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
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

-(void)hidekeybord
{
    [self.view endEditing:YES];
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
    groupImg = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    [editCell.btnGroupImageEdit setImage:groupImg forState:UIControlStateNormal];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)btnIsPublicTapped:(id)sender{
    NSNumber* isPublic = [groupInfo objectForKey:@"isPublic"];
    if(isPublic.intValue == 1){
        isPublic = [NSNumber numberWithInt:0];
        [editCell.btnIsPublicEdit setTitle:@"Public" forState:UIControlStateNormal];
    }
    else{
        isPublic = [NSNumber numberWithInt:1];
        [editCell.btnIsPublicEdit setTitle:@"Private" forState:UIControlStateNormal];
    }
    [groupInfo setObject:isPublic forKey:@"isPublic"];
   
    
}

- (void)readGroupInfo:(ResponseBase *)response error:(NSError *)error {
    DataResponse *res = (DataResponse *)response;
    
    if (error){
        
    }
    else {
        groupInfo = [[NSMutableDictionary alloc] initWithDictionary:res.data];
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
    if ([[segue identifier] isEqualToString:@"EditInterest"]) {
        WUInterestViewController *cvc = (WUInterestViewController *)[segue destinationViewController];
        cvc.delegate = self;
    }
    else if ([[segue identifier] isEqualToString:@"EditLocation"]) {
        WULocationSearchController *cvc = (WULocationSearchController *)[segue destinationViewController];
        cvc.delegate = self;
    }
    else{
        [super prepareForSegue:segue sender:sender];
    }
}

-(void)saveGroup{
    [self.group setGroupName: [groupInfo objectForKey:@"topic"]];
    [self.group setGroupdata:[groupInfo objectForKey:@"topicDescription"] forKey:@"topicDesc" public:YES];
    [self.group saveGroup];
    [self.group setGroupImage:groupImg withCompletionHandler:nil];
    
    DataRequest *dataRequest = [[DataRequest alloc] init];
    dataRequest.requestName = @"updateGroupInfo";
    dataRequest.values = groupInfo;
    
    WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
    [serviceHandler execute:METHOD_DATA_REQUEST parameter:dataRequest target:self action:@selector(updateGroupInfo:error:)];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
}

- (void)updateGroupInfo:(ResponseBase *)response error:(NSError *)error {
    DataResponse *res = (DataResponse *)response;
    
    if (error){
        
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
}

@end
