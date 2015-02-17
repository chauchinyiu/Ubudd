//
//  WURequestUserDetailController.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 14/10/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "WURequestUserDetailController.h"
#import "ResponseHandler.h"
#import <SocialCommunication/UIViewController+SCCustomViewController.h>
#import <SocialCommunication/debug.h>

@implementation WURequestUserInfoCell
@synthesize displayName, lblGender, lblDateOfBirth, lblInterest, lblSubinterest, userPhoto;
@end

@interface WURequestUserDetailController ()
@end

@implementation WURequestUserDetailController
@synthesize userData;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.translucent = NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WURequestUserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WURequestUserInfoCell" forIndexPath:indexPath];
    
    // Configure the cell...
    [cell.displayName setText:[userData objectForKey:@"userName"]];
    [cell.lblGender setText:([(NSString*)[userData objectForKey:@"gender"] isEqualToString:@"F"] ? NSLocalizedString(@"Female", @"") : NSLocalizedString(@"Male", @""))];
    [cell.lblDateOfBirth setText:[NSDateFormatter localizedStringFromDate:[userData objectForKey:@"dob"]
                                                             dateStyle:NSDateFormatterMediumStyle
                                                             timeStyle:NSDateFormatterNoStyle]];
    [cell.lblInterest setText:[[ResponseHandler instance] getInterestNameForID:[[userData objectForKey:@"interestID"] integerValue]]];
    [cell.lblSubinterest setText:[userData objectForKey:@"interestDescription"]];
    
    NSDictionary* userProfile = [[C2CallPhone currentPhone] getUserInfoForUserid:[userData objectForKey:@"c2CallID"]];
    
    UIImage *image = [userProfile objectForKey:@"ImageSamll"];
    
    if (image) {
        cell.userPhoto.image = image;
    }
    else{
        cell.userPhoto.image = [UIImage imageNamed:@"btn_ico_avatar.png"];
    }
    
    
    return cell;
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

@end
