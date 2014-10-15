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
#import <MapKit/MapKit.h>

@implementation WUUbuddListCell

@synthesize nameLabel, statusLabel, accessLabel, userBtn, addButton;

@end

@interface WUUbuddListController (){
    CGFloat favoritesCellHeight;
    NSDictionary* fetchResult;
    BOOL inSearch;
    NSString* searchStr;
    id joinCell;
    CLLocationCoordinate2D loc;
    NSString* locName;
    int searchDist;
    
}
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation WUUbuddListController
@synthesize locationLabel, distanceLabel;


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

    inSearch = NO;
    searchStr = @"";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"WUUbuddListCell"];
    favoritesCellHeight = cell.frame.size.height;
    [self searchUpdated];
}


- (void)viewDidAppear:(BOOL)animated {
    if(!inSearch){
        [self readUserGroup];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)readUserGroup{
    
    [self showActivityView];
    
    DataRequest* datRequest = [[DataRequest alloc] init];
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    [data setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"msidn"] forKey:@"userID"];
    datRequest.values = data;
    datRequest.requestName = @"readUserGroups";
    
    WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
    [serviceHandler execute:METHOD_DATA_REQUEST parameter:datRequest target:self action:@selector(readUserGroupResponse:error:)];

}

- (void)searchUserGroup:(NSString*)searchTxt{
    
    [self showActivityView];
    searchStr = searchTxt;
    
    DataRequest* datRequest = [[DataRequest alloc] init];
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    [data setValue:searchTxt forKey:@"searchString"];
    MKCoordinateRegion r = MKCoordinateRegionMakeWithDistance(loc, searchDist * 2000, searchDist * 2000);
    
    [data setValue:[NSNumber numberWithFloat:loc.latitude - (r.span.latitudeDelta / 2)] forKey:@"latFrom"];
    [data setValue:[NSNumber numberWithFloat:loc.latitude + (r.span.latitudeDelta / 2)] forKey:@"latTo"];
    [data setValue:[NSNumber numberWithFloat:loc.longitude - (r.span.longitudeDelta / 2)] forKey:@"longFrom"];
    [data setValue:[NSNumber numberWithFloat:loc.longitude + (r.span.longitudeDelta / 2)] forKey:@"longTo"];
    
    [data setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"msidn"] forKey:@"userID"];
    datRequest.values = data;
    datRequest.requestName = @"searchGroup";
    
    WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
    [serviceHandler execute:METHOD_DATA_REQUEST parameter:datRequest target:self action:@selector(readUserGroupResponse:error:)];
    
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



- (void)readUserGroupResponse:(ResponseBase *)response error:(NSError *)error{
    [self.activityView stopAnimating];
    fetchResult = ((DataResponse*)response).data;
    [self.tableView reloadData];
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
    if(isMember.intValue != 0){
        [favocell.addButton setHidden:YES];
    }
    else{
        [favocell.addButton setHidden:NO];
    }
    
    SCGroup *group = [[SCGroup alloc] initWithGroupid:[fetchResult objectForKey:[NSString stringWithFormat:@"c2CallID%d", indexPath.row ]]];
    
    favocell.nameLabel.text = [fetchResult objectForKey:[NSString stringWithFormat:@"topic%d", indexPath.row]];;
    favocell.statusLabel.text = [fetchResult objectForKey:[NSString stringWithFormat:@"topicDescription%d", indexPath.row]];
    
    NSNumber* isPublic = [fetchResult objectForKey:[NSString stringWithFormat:@"isPublic%d", indexPath.row]];
    if(isPublic.intValue == 1){
        favocell.accessLabel.text = @"Public";
    }
    else{
        favocell.accessLabel.text = @"Private";
    }
    
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
    
    NSNumber* isMember = [fetchResult objectForKey:[NSString stringWithFormat:@"isMember%d", indexPath.row]];
    if(isMember.intValue == 1 || isMember.intValue == 2){
        [WUBoardController setIsGroup:YES];
        [self showChatForUserid:[fetchResult objectForKey:[NSString stringWithFormat:@"c2CallID%d", indexPath.row]]];
    }
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
    joinCell = sender;
    if(isPublic.intValue == 1){
        //join directly
        NSString* groupID = [fetchResult objectForKey:[NSString stringWithFormat:@"c2CallID%d", [sender tag] ]];
        SCGroup *group = [[SCGroup alloc] initWithGroupid:groupID];
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
        DataRequest* datRequest = [[DataRequest alloc] init];
        NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
        [data setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"msidn"] forKey:@"memberID"];
        [data setValue:[fetchResult objectForKey:[NSString stringWithFormat:@"groupID%d", [sender tag]]] forKey:@"groupID"];
        [data setValue:[SCUserProfile currentUser].firstname forKey:@"userName"];
        
        datRequest.values = data;
        datRequest.requestName = @"requestJoinGroup";
        
        WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
        [serviceHandler execute:METHOD_DATA_REQUEST parameter:datRequest target:self action: @selector(requestJoinGroupResponse:error:)];
    }
}

- (void)requestJoinGroupResponse:(ResponseBase *)response error:(NSError *)error{
    if (response.errorCode == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request submitted"
                                                        message:@"Your request is submitted and is waiting for approval."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [joinCell setHidden:YES];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Submittion failed"
                                                        message:@"Unable to submit your request."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    
    }
    
}


- (void)addGroupUserResponse:(ResponseBase *)response error:(NSError *)error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Join Group"
                                                    message:@"You are now a member of the group."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [joinCell setHidden:YES];
    NSMutableDictionary* tempcpy = [NSMutableDictionary dictionaryWithDictionary:fetchResult];
    [tempcpy  setValue:[NSNumber numberWithInt:1] forKey:[NSString stringWithFormat:@"isMember%d", [joinCell tag]]];
    fetchResult = tempcpy;
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if ([searchBar.text isEqualToString:@""]) {
        inSearch = false;
        [self readUserGroup];
    }
    else{
        inSearch = true;
        [self searchUserGroup:searchBar.text];
    }
    
}


-(void)updateLocationSearchGUI{
    distanceLabel.text = [NSString stringWithFormat:@"Within %dKm", searchDist];
    locationLabel.text = locName;
}

-(void)searchUpdated{
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    if ([ud boolForKey:@"hasLocSearch"]) {
        loc.latitude = [ud floatForKey:@"searchLat"];
        loc.longitude = [ud floatForKey:@"searchLong"];
        locName = [ud stringForKey:@"searchLoc"];
        searchDist = [ud integerForKey:@"searchDist"];
    }
    else{
        loc.latitude = 999;
        loc.longitude = 999;
        locName = @"";
        searchDist = 2;
    }
    [self updateLocationSearchGUI];
    [self searchUserGroup:searchStr];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"searchLoc"]) {
        WUMapViewController *cvc = (WUMapViewController *)[segue destinationViewController];
        cvc.delegate = self;
    }
    else{
        [super prepareForSegue:segue sender:sender];
    }
}

@end

