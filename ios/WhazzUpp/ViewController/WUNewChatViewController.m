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
#import "CommonMethods.h"

@implementation WUNewChatCell

@synthesize nameLabel, statusLabel, onlineLabel, userBtn, infoBtn;

@end


@interface WUNewChatViewController (){
    CGFloat     favoritesCellHeight;
    ResponseHandler *resHandler;
    
    NSMutableArray *friendSearch;
    NSMutableArray *friendSection;
    NSMutableArray *groupSearch;
    NSMutableArray *groupSection;

    BOOL inSearch;
    NSString* searchStr;
    
    id<WUTargetSelectControllerDelegate> myDelegate;
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
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"WUNewChatCell"];
    
    favoritesCellHeight = 36;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    [self refreshList];
    [self.tableView reloadData];
}

-(void)refreshList{
    inSearch = NO;
    friendSection = [ResponseHandler instance].friendList;
    groupSection = [ResponseHandler instance].groupList;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark Configure Cell

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return favoritesCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (inSearch) {
        return friendSearch.count + groupSearch.count;
    }
    else{
        return friendSection.count + groupSection.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WUNewChatCell *favocell = (WUNewChatCell *)[self.tableView dequeueReusableCellWithIdentifier:@"WUNewChatCell"];
    //favocell.nameLabel.font = [CommonMethods getStdFontType:0];
    //favocell.statusLabel.font = [CommonMethods getStdFontType:2];
    
    WUAccount* accRecord;
    BOOL isGroup;
    if (inSearch) {
        if (indexPath.row < friendSearch.count) {
            accRecord = [friendSearch objectAtIndex:indexPath.row];
            isGroup = NO;
        }
        else{
            accRecord = [groupSearch objectAtIndex:indexPath.row - friendSearch.count];
            isGroup = YES;
        }
    }
    else{
        if (indexPath.row < friendSection.count) {
            accRecord = [friendSection objectAtIndex:indexPath.row];
            isGroup = NO;
        }
        else{
            accRecord = [groupSection objectAtIndex:indexPath.row - friendSection.count];
            isGroup = YES;
        }
    }
    if ([accRecord.name isEqualToString:@""]) {
        favocell.nameLabel.text = [[C2CallPhone currentPhone] nameForUserid:accRecord.c2CallID];
    }
    else{
        favocell.nameLabel.text = accRecord.name;
    }
    if (isGroup) {
        favocell.statusLabel.text = NSLocalizedString(@"UBudd group", @"");
    }
    else{
        favocell.statusLabel.text = NSLocalizedString(@"UBudd user", @"");
    }
    
    UIImage *image = [[C2CallPhone currentPhone] userimageForUserid:accRecord.c2CallID];
    
    if (image) {
        favocell.userImg.image = image;
    }
    else{
        if(isGroup){
            favocell.userImg.image = [UIImage imageNamed:@"btn_ico_avatar_group2.png"];
        }
        else{
            favocell.userImg.image = [UIImage imageNamed:@"btn_ico_avatar.png"];
        }
    }
    //favocell.userImg.layer.cornerRadius = 0.0;
    favocell.userImg.layer.masksToBounds = YES;
    favocell.infoBtn.tag = indexPath.row;
    
    return favocell;
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WUAccount* accRecord;
    BOOL isGroup;
    if (inSearch) {
        if (indexPath.row < friendSearch.count) {
            accRecord = [friendSearch objectAtIndex:indexPath.row];
            isGroup = NO;
        }
        else{
            accRecord = [groupSearch objectAtIndex:indexPath.row - friendSearch.count];
            isGroup = YES;
        }
    }
    else{
        if (indexPath.row < friendSection.count) {
            accRecord = [friendSection objectAtIndex:indexPath.row];
            isGroup = NO;
        }
        else{
            accRecord = [groupSection objectAtIndex:indexPath.row - friendSection.count];
            isGroup = YES;
        }
    }

    if (myDelegate) {
        [myDelegate selectTarget:accRecord.c2CallID];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        if (isGroup) {
            [WUBoardController setIsGroup:YES];
        } else {
            [WUBoardController setIsGroup:NO];
        }
        [self showChatForUserid:accRecord.c2CallID];
    }
}

-(IBAction)showFriendInfo:(id)sender{
    WUAccount* accRecord;
    BOOL isGroup;
    if (inSearch) {
        if (((UIButton*)sender).tag < friendSearch.count) {
            accRecord = [friendSearch objectAtIndex:((UIButton*)sender).tag];
            isGroup = NO;
        }
        else{
            accRecord = [groupSearch objectAtIndex:((UIButton*)sender).tag - friendSearch.count];
            isGroup = YES;
        }
    }
    else{
        if (((UIButton*)sender).tag < friendSection.count) {
            accRecord = [friendSection objectAtIndex:((UIButton*)sender).tag];
            isGroup = NO;
        }
        else{
            accRecord = [groupSection objectAtIndex:((UIButton*)sender).tag - friendSection.count];
            isGroup = YES;
        }
    }

    if(isGroup){
        [self showGroupDetailForGroupid:accRecord.c2CallID];
    }
    else{
        [WUFriendDetailController setPhoneNo:accRecord.phoneNo];
        [self showFriendDetailForUserid:accRecord.c2CallID];
    }
}


#pragma mark SearchDisplayController Delegate

-(void) refetchResults
{
    friendSearch = [[NSMutableArray alloc] init];
    for (int i = 0; i < friendSection.count; i++) {
        WUAccount* accRecord = [friendSection objectAtIndex:i];
        if ([accRecord.name rangeOfString:searchStr options:NSCaseInsensitiveSearch].location == NSNotFound) {
        }
        else{
            [friendSearch addObject:[friendSection objectAtIndex:i]];
        }
    }
    groupSearch = [[NSMutableArray alloc] init];
    for (int i = 0; i < groupSection.count; i++) {
        WUAccount* accRecord = [groupSection objectAtIndex:i];
        if ([accRecord.name rangeOfString:searchStr options:NSCaseInsensitiveSearch].location == NSNotFound) {
        }
        else{
            [groupSearch addObject:[groupSection objectAtIndex:i]];
        }
    }
    
    [self.tableView reloadData];
    
}

-(void) setTextFilterForText:(NSString *) text
{
    
    searchStr = text;
}

-(void) removeTextFilter
{
    //NSFetchRequest *fetch = [ubuddUsers fetchRequest];
    //[fetch setPredicate:nil];
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
    inSearch = YES;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    inSearch = NO;
    
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

-(void)switchToSelectionMode:(id<WUTargetSelectControllerDelegate>)delegate{
    myDelegate = delegate;
}


@end
