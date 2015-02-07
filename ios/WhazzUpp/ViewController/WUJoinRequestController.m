//
//  WUJoinRequestController.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 14/10/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "WUJoinRequestController.h"
#import <SocialCommunication/UIViewController+SCCustomViewController.h>
#import <SocialCommunication/debug.h>
#import "DBHandler.h"
#import "DataRequest.h"
#import "WebserviceHandler.h"
#import "ResponseBase.h"
#import "DataResponse.h"
#import "WURequestUserDetailController.h"


@implementation WUJoinRequestListCell

@synthesize nameLabel, groupLabel, userBtn;

@end


@interface WUJoinRequestController (){
    CGFloat favoritesCellHeight;
    NSDictionary* fetchResult;
}
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation WUJoinRequestController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"WUJoinRequestListCell"];
    favoritesCellHeight = cell.frame.size.height;
}

- (void)viewDidAppear:(BOOL)animated {
    [self readOutStandingRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void)readOutStandingRequest{
    
    [self showActivityView];
    
    DataRequest* datRequest = [[DataRequest alloc] init];
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    [data setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"msidn"] forKey:@"userID"];
    datRequest.values = data;
    datRequest.requestName = @"readOutStandingRequest";
    
    WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
    [serviceHandler execute:METHOD_DATA_REQUEST parameter:datRequest target:self action:@selector(readOutStandingRequestResponse:error:)];
    
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



- (void)readOutStandingRequestResponse:(ResponseBase *)response error:(NSError *)error{
    [self.activityView stopAnimating];
    fetchResult = ((DataResponse*)response).data;
    [self.tableView reloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
    WUJoinRequestListCell *favocell = (WUJoinRequestListCell *)[self.tableView dequeueReusableCellWithIdentifier:@"WUJoinRequestListCell"];
    [favocell.userBtn setTag:indexPath.row];
    
    NSString* requestUserID = [fetchResult objectForKey:[NSString stringWithFormat:@"c2CallID%d", indexPath.row ]];
    
    
    favocell.nameLabel.text = [fetchResult objectForKey:[NSString stringWithFormat:@"userName%d", indexPath.row]];
    favocell.groupLabel.text = [fetchResult objectForKey:[NSString stringWithFormat:@"topic%d", indexPath.row]];
   
    NSDictionary* userData = [[C2CallPhone currentPhone] getUserInfoForUserid:requestUserID];
    
    UIImage *image = [userData objectForKey:@"ImageSamll"];
    
    if (image) {
        favocell.userImg.image = image;
    }
    else{
        favocell.userImg.image = [UIImage imageNamed:@"btn_ico_avatar.png"];
    }
    favocell.userImg.layer.cornerRadius = 0.0;
    favocell.userImg.layer.masksToBounds = YES;
    
    return favocell;
}



-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Join Request", @"") message:@"How will you handle the request?" delegate:self cancelButtonTitle:@"Later" otherButtonTitles: @"Accept", @"Reject", nil];
    [alert setTag:indexPath.row];
    [alert show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        NSString* groupID = [fetchResult objectForKey:[NSString stringWithFormat:@"groupC2CallID%d", [alertView tag]]];
        NSString* userID = [fetchResult objectForKey:[NSString stringWithFormat:@"c2CallID%d", [alertView tag]]];
        SCGroup *group = [[SCGroup alloc] initWithGroupid:groupID];
        [group addGroupMember:userID];
        [group saveGroupWithCompletionHandler:^(BOOL success){
            DataRequest* datRequest = [[DataRequest alloc] init];
            NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
            [data setValue:[fetchResult objectForKey:[NSString stringWithFormat:@"msisdn%d", [alertView tag]]] forKey:@"userID"];
            [data setValue:[fetchResult objectForKey:[NSString stringWithFormat:@"groupID%d", [alertView tag]]] forKey:@"groupID"];
            datRequest.values = data;
            datRequest.requestName = @"acceptRequest";
            
            WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
            [serviceHandler execute:METHOD_DATA_REQUEST parameter:datRequest target:self action:@selector(handleJoinRequestResponse:error:)];
        }];
        
    }
    else if(buttonIndex == 2){
        DataRequest* datRequest = [[DataRequest alloc] init];
        NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
        [data setValue:[fetchResult objectForKey:[NSString stringWithFormat:@"msisdn%d", [alertView tag]]] forKey:@"userID"];
        [data setValue:[fetchResult objectForKey:[NSString stringWithFormat:@"groupID%d", [alertView tag]]] forKey:@"groupID"];
        datRequest.values = data;
        datRequest.requestName = @"rejectRequest";
        
        WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
        [serviceHandler execute:METHOD_DATA_REQUEST parameter:datRequest target:self action:@selector(handleJoinRequestResponse:error:)];
        
    }
}
         
- (void)handleJoinRequestResponse:(ResponseBase *)response error:(NSError *)error{
    [self readOutStandingRequest];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"RequestUserDetail"]) {
        NSMutableDictionary* userData = [[NSMutableDictionary alloc] init];
        
        [userData setObject:[fetchResult objectForKey:[NSString stringWithFormat:@"userName%d", [sender tag]]] forKey:@"userName"];
        [userData setObject:[fetchResult objectForKey:[NSString stringWithFormat:@"interestID%d", [sender tag]]] forKey:@"interestID"];
        [userData setObject:[fetchResult objectForKey:[NSString stringWithFormat:@"interestDescription%d", [sender tag]]] forKey:@"interestDescription"];
        [userData setObject:[fetchResult objectForKey:[NSString stringWithFormat:@"dob%d", [sender tag]]] forKey:@"dob"];
        [userData setObject:[fetchResult objectForKey:[NSString stringWithFormat:@"gender%d", [sender tag]]] forKey:@"gender"];
        
        WURequestUserDetailController *controller = (WURequestUserDetailController *)segue.destinationViewController;
        controller.userData = userData;
    }
}

@end
