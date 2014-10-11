//
//  WUUbuddListController.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 27/9/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "WUUbuddListController.h"
#import <SocialCommunication/UIViewController+SCCustomViewController.h>
#import <SocialCommunication/debug.h>
#import "DBHandler.h"
#import "WUBoardController.h"
#import "DataRequest.h"
#import "WebserviceHandler.h"
#import "ResponseBase.h"
#import "DataResponse.h"

@implementation WUUbuddListCell

@synthesize nameLabel, statusLabel, onlineLabel, userBtn, addButton;

@end

@interface WUUbuddListController (){
    CGFloat favoritesCellHeight;
    NSDictionary* fetchResult;
    BOOL inSearch;
}
@end

@implementation WUUbuddListController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"WUUbuddListCell"];
    favoritesCellHeight = cell.frame.size.height;
    [self readUserGroup];
    
}


- (void)viewDidAppear:(BOOL)animated {
    //[self refetchResults];
    //[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)readUserGroup{
    DataRequest* datRequest = [[DataRequest alloc] init];
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    [data setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"msidn"] forKey:@"userID"];
    datRequest.values = data;
    datRequest.requestName = @"readUserGroups";
    inSearch = NO;
    
    WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
    [serviceHandler execute:METHOD_DATA_REQUEST parameter:datRequest target:self action:@selector(readUserGroupResponse:error:)];

}

- (void)searchUserGroup:(NSString*)searchTxt{
    DataRequest* datRequest = [[DataRequest alloc] init];
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    [data setValue:searchTxt forKey:@"searchString"];
    [data setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"msidn"] forKey:@"userID"];
    datRequest.values = data;
    datRequest.requestName = @"searchGroup";
    inSearch = YES;
    
    WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
    [serviceHandler execute:METHOD_DATA_REQUEST parameter:datRequest target:self action:@selector(readUserGroupResponse:error:)];
    
}


- (void)readUserGroupResponse:(ResponseBase *)response error:(NSError *)error{
    fetchResult = ((DataResponse*)response).data;
    if (inSearch) {
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    else{
        [self.tableView reloadData];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (fetchResult) {
        return ((NSNumber*)[fetchResult objectForKey:@"rowCnt"]).intValue;
    }
    else{
        return 0;
    }
}



-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return favoritesCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WUUbuddListCell *favocell = (WUUbuddListCell *)[self.tableView dequeueReusableCellWithIdentifier:@"WUUbuddListCell"];
    [favocell.userBtn setTag:indexPath.row];
    [favocell.addButton setTag:indexPath.row];
    
    NSNumber* isMember = [fetchResult objectForKey:[NSString stringWithFormat:@"isMember%d", indexPath.row]];
    if(isMember.intValue == 1 || isMember.intValue == 2){
        [favocell.addButton setHidden:YES];
    }
    else{
        [favocell.addButton setHidden:NO];
    }
    
    SCGroup *group = [[SCGroup alloc] initWithGroupid:[fetchResult objectForKey:[NSString stringWithFormat:@"c2CallID%d", indexPath.row ]]];
    
    favocell.nameLabel.text = group.groupName;
    favocell.statusLabel.text = [fetchResult objectForKey:[NSString stringWithFormat:@"topicDescription%d", indexPath.row]];
    
    UIImage *image = [[C2CallPhone currentPhone] userimageForUserid:group.groupid];
    
    if (image) {
        favocell.userImg.image = image;
    }
    else{
        favocell.userImg.image = [UIImage imageNamed:@"btn_ico_avatar_group.png"];
    }
    
    return favocell;
}



-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"didSelectRowAtIndexPath : %d / %d", indexPath.section, indexPath.row);
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    
    [WUBoardController setIsGroup:YES];
    [self showChatForUserid:[fetchResult objectForKey:[NSString stringWithFormat:@"c2CallID%d", indexPath.row]]];
}

-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"accessoryButtonTappedForRowWithIndexPath : %d / %d", indexPath.section, indexPath.row);
    
    [self showGroupDetailForGroupid:[fetchResult objectForKey:[NSString stringWithFormat:@"c2CallID%d", indexPath.row]]];
}

-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}



-(IBAction)showFriendInfo:(id)sender{
    [self showGroupDetailForGroupid:[fetchResult objectForKey:[NSString stringWithFormat:@"c2CallID%d", [sender tag]]]];
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

-(IBAction)joinGroup:(id)sender{
    NSNumber* isPublic = [fetchResult objectForKey:[NSString stringWithFormat:@"isPublic%d", [sender tag]]];
    if(isPublic.intValue == 1){
        //join directly
        NSString* groupID = [fetchResult objectForKey:[NSString stringWithFormat:@"c2CallID%d", [sender tag] ]];
        SCGroup *group = [[SCGroup alloc] initWithGroupid:[fetchResult objectForKey:[NSString stringWithFormat:@"c2CallID%d", [sender tag] ]]];
        //[group addGroupMember:[SCUserProfile currentUser].userid];
        [group joinGroup];
        [group saveGroupWithCompletionHandler:^(BOOL success){
            DataRequest* datRequest = [[DataRequest alloc] init];
            NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
            [data setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"msidn"] forKey:@"memberID"];
            [data setValue:[fetchResult objectForKey:[NSString stringWithFormat:@"groupID%d", [sender tag]]] forKey:@"groupID"];
            datRequest.values = data;
            datRequest.requestName = @"addGroupMember";
            
            WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
            [serviceHandler execute:METHOD_DATA_REQUEST parameter:datRequest target:self action: @selector(addGroupUserResponse:error:)];
        }];
    }
    else{
        //submit request
    }
}

- (void)addGroupUserResponse:(ResponseBase *)response error:(NSError *)error{
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self searchUserGroup:searchString];
    
    // Return NO, as the search will be done in the background
    return NO;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    
    // Return NO, as the search will be done in the background
    return NO;
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    [self readUserGroup];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)_tableView
{
}

@end

