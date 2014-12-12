//
//  WUNewChatViewController.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 2/9/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "WUNewChatViewController.h"
#import <SocialCommunication/UIViewController+SCCustomViewController.h>
#import <SocialCommunication/debug.h>
#import "DBHandler.h"
#import "ResponseHandler.h"
#import "WUBoardController.h"
#import "WUFriendDetailController.h"

@implementation WUNewChatCell

@synthesize nameLabel, statusLabel, onlineLabel, userBtn;

@end


@interface WUNewChatViewController (){
    CGFloat     favoritesCellHeight;
    ResponseHandler *resHandler;
}

@end


@implementation WUNewChatViewController

#pragma mark - Other Methods


#pragma mark - UIViewController Delegate
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    resHandler = [ResponseHandler instance];
    self.cellIdentifier = @"WUNewChatCell";
        
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    favoritesCellHeight = cell.frame.size.height;
}

- (void)viewDidAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
    [resHandler verifyNewC2CallID];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark fetchRequest

-(NSFetchRequest *) fetchRequest {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(userType == 0 OR userType == 2) AND callmeLink == 0"];
    return [DBHandler fetchRequestFromTable:@"MOC2CallUser" predicate:predicate orderBy:@"firstname" ascending:YES];
}

#pragma mark Configure Cell

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MOC2CallUser *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if([resHandler c2CallIDPassed:user.userid]
       || user.userType.intValue == 2){
        return favoritesCellHeight;
    }
    else{
        return 0;
    }
}

-(void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    MOC2CallUser *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if([resHandler c2CallIDPassed:user.userid]){
        if ([cell isKindOfClass:[WUNewChatCell class]]) {
            WUNewChatCell *favocell = (WUNewChatCell *) cell;
            favocell.nameLabel.text = [[C2CallPhone currentPhone] nameForUserid:user.userid];
            favocell.statusLabel.text = user.userStatus? user.userStatus : @"Hi there, I'm using Ubudd?";
            
            [favocell.userBtn setTag:indexPath.row];
            UIImage *image = [[C2CallPhone currentPhone] userimageForUserid:user.userid];
            
            if (image) {
                favocell.userImg.image = image;
            }
        }
    }
    else if(user.userType.intValue == 2){
        if ([cell isKindOfClass:[WUNewChatCell class]]) {
            WUNewChatCell *favocell = (WUNewChatCell *) cell;
            favocell.nameLabel.text = [[C2CallPhone currentPhone] nameForUserid:user.userid];
            favocell.statusLabel.text = user.userStatus? user.userStatus : @"Ubudd Group";
            
            [favocell.userBtn setTag:indexPath.row];
            UIImage *image = [[C2CallPhone currentPhone] userimageForUserid:user.userid];
            
            if (image) {
                favocell.userImg.image = image;
            }
            else{
                favocell.userImg.image = [UIImage imageNamed:@"btn_ico_avatar_group2.png"];
            }
            favocell.userImg.layer.cornerRadius = 0.0;
            favocell.userImg.layer.masksToBounds = YES;
            
        }
    }
    else{
        [cell setHidden:YES];
    }
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"didSelectRowAtIndexPath : %d / %d", indexPath.section, indexPath.row);
    
    MOC2CallUser *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    
    if ([user.userType intValue] == 2) {
        [WUBoardController setIsGroup:YES];
    } else {
        [WUBoardController setIsGroup:NO];
    }
    [self showChatForUserid:user.userid];
}

-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"accessoryButtonTappedForRowWithIndexPath : %d / %d", indexPath.section, indexPath.row);
    
    MOC2CallUser *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([user.userType intValue] == 2) {
        [self showGroupDetailForGroupid:user.userid];
    } else {
        NSMutableArray* friendList = [[ResponseHandler instance] friendList];
        for (int i = 0; i < friendList.count; i++) {
            WUAccount* a = [friendList objectAtIndex:i];
            if ([a.c2CallID isEqualToString:user.userid]) {
                [WUFriendDetailController setPhoneNo:a.phoneNo];
            }
        }
        [self showFriendDetailForUserid:user.userid];
    }
}


-(IBAction)showFriendInfo:(id)sender{
    MOC2CallUser *user = [[[[self.fetchedResultsController sections] objectAtIndex:0] objects] objectAtIndex:[sender tag]];
    
    if ([user.userType intValue] == 2) {
        [self showGroupDetailForGroupid:user.userid];
    }
    else {
        NSMutableArray* friendList = [[ResponseHandler instance] friendList];
        for (int i = 0; i < friendList.count; i++) {
            WUAccount* a = [friendList objectAtIndex:i];
            if ([a.c2CallID isEqualToString:user.userid]) {
                [WUFriendDetailController setPhoneNo:a.phoneNo];
            }
        }
        [self showFriendDetailForUserid:user.userid];
    }
}

#pragma mark SearchDisplayController Delegate

-(void) refetchResults
{
    [self.fetchedResultsController performFetch:nil];
}

-(void) setTextFilterForText:(NSString *) text
{
    NSFetchRequest *fetch = [self.fetchedResultsController fetchRequest];
    
    //    NSPredicate *textFilter = [NSPredicate predicateWithFormat:@"displayName contains[cd] %@ OR email contains[cd] %@", text, text];
    
    
    NSPredicate *textFilter = [NSPredicate predicateWithFormat:@"userType == 0 AND callmeLink == 0 AND not (userid in %@) AND displayName contains[cd] %@", [NSArray arrayWithObjects:@"9bc2858f1194dc1c107", nil], text];
    
    [fetch setPredicate:textFilter];
}

-(void) removeTextFilter
{
    NSFetchRequest *fetch = [self.fetchedResultsController fetchRequest];
    [fetch setPredicate:nil];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self setTextFilterForText:searchString];
    [self refetchResults];
    
    // Return NO, as the search will be done in the background
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self setTextFilterForText:[self.searchDisplayController.searchBar text]];
    [self refetchResults];
    
    // Return NO, as the search will be done in the background
    return YES;
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    DLog(@"searchDisplayControllerDidBeginSearch");
    
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    DLog(@"searchDisplayControllerDidEndSearch");
    [self removeTextFilter];
    [self refetchResults];
    
    
    return;
}
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)_tableView
{
}



@end
