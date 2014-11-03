//
//  WUContactListController.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 28/8/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//
#import <SocialCommunication/UIViewController+SCCustomViewController.h>
#import "WUContactListController.h"
#import "WUFavoritesViewController.h"
#import "WebserviceHandler.h"
#import "ServiceURL.h"
#import "ResponseBase.h"
#import "CommonMethods.h"
#import "DataResponse.h"
#import "DataRequest.h"
#import "ResponseHandler.h"
#import "WUBoardController.h"

#import "DBHandler.h"

@implementation WUAddressBookCell

@synthesize nameLabel, statusLabel, addButton, userBtn, addButton2;

@end

@interface WUContactListController (){
    CGFloat favoritesCellHeight;
    NSMutableArray *addressListSection;
    NSMutableArray *addressSearch;
    NSFetchedResultsController *ubuddUsers;
    ResponseHandler *resHandler;
    BOOL inSearch;
    NSString* searchStr;
}
@end

@implementation WUContactListController
@synthesize managedObjectContext = _managedObjectContext;

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
    
    resHandler = [ResponseHandler instance];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:@"WUAddressBookCell"];
    favoritesCellHeight = cell.frame.size.height;
    self.managedObjectContext = [DBHandler context];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString*)title atIndex:(NSInteger)index{
    return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0){
        return @"Ubudd friends";
    }
    else{
        return @"Address book";
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    inSearch = NO;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userType == 0 AND callmeLink == 0"];
    NSFetchRequest *fetch = [DBHandler fetchRequestFromTable:@"MOC2CallUser" predicate:predicate orderBy:@"firstname" ascending:YES];
    
    ubuddUsers = [[NSFetchedResultsController alloc] initWithFetchRequest:fetch managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    [ubuddUsers performFetch:nil];
    
    //count fav
    int favCnt = 0;
    for (int j = 0; j < [[[[ubuddUsers sections] objectAtIndex:0] objects] count]; j++) {
        MOC2CallUser *user = [[[[ubuddUsers sections] objectAtIndex:0] objects] objectAtIndex:j];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:user.userid]) {
            favCnt++;
        }
        if(user.userType.intValue != 2){
            //verify the c2call id with our server
            if(![resHandler c2CallIDVerified:user.userid]){
                [resHandler verifyC2CallID:user.userid];
            }
        }
    }
    [[NSUserDefaults standardUserDefaults] setInteger:favCnt forKey:@"FavCount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFMutableArrayRef peopleMutable = CFArrayCreateMutableCopy(kCFAllocatorDefault,
                                                               CFArrayGetCount(allPeople),
                                                               allPeople);
    
    CFArraySortValues(peopleMutable,
                      CFRangeMake(0, CFArrayGetCount(peopleMutable)),
                      (CFComparatorFunction) ABPersonComparePeopleByName,
                      kABPersonSortByFirstName);
    
    
    
    addressListSection = [[NSMutableArray alloc] init];
    for (CFIndex loop = 0; loop < CFArrayGetCount(peopleMutable); loop++){
        BOOL hasUbudd = false;
        ABRecordRef record = CFArrayGetValueAtIndex(peopleMutable, loop); // get address book record
        
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(record, kABPersonPhoneProperty);
        // If the contact has multiple phone numbers, iterate on each of them
        for (int i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
            NSString *phone = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, i);
            
            // Remove all formatting symbols that might be in both phone number being compared
            NSCharacterSet *toExclude = [NSCharacterSet characterSetWithCharactersInString:@"/.()- "];
            phone = [[phone componentsSeparatedByCharactersInSet:toExclude] componentsJoinedByString: @""];
            phone = [[phone componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString: @""];
            
            
            for (int j = 0; j < [[[[ubuddUsers sections] objectAtIndex:0] objects] count]; j++) {
                MOC2CallUser *user = [[[[ubuddUsers sections] objectAtIndex:0] objects] objectAtIndex:j];
                //filter verified c2callID only
                if([resHandler c2CallIDPassed:user.userid]){
                    if ([phone isEqualToString: user.ownNumber]) {
                        hasUbudd = true;
                    }
                }
            }
        }
        if (!hasUbudd) {
            [addressListSection addObject:(__bridge id)(record)];
        }
    }
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0 && ubuddUsers != nil) {
        return [[[[ubuddUsers sections] objectAtIndex:0] objects] count];
    }
    else{
        if (inSearch) {
            return [addressSearch count];
        }
        else{
            return [addressListSection count];
        }
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        MOC2CallUser *user = [[[[ubuddUsers sections] objectAtIndex:0] objects] objectAtIndex:indexPath.row];
        if(user.userType.intValue == 2){
            return 0;
        }
        else if(![resHandler c2CallIDPassed:user.userid]){
            return 0;
        }
        else{
            return favoritesCellHeight;
        }
    }
    else{
        return favoritesCellHeight;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WUAddressBookCell *favocell = (WUAddressBookCell *)[self.tableView dequeueReusableCellWithIdentifier:@"WUAddressBookCell"];
    
    if (indexPath.section == 0) {
        
        MOC2CallUser *user = [[[[ubuddUsers sections] objectAtIndex:0] objects] objectAtIndex:indexPath.row];
        
        if(user.userType.intValue == 2){
            [favocell setHidden:YES];
        }
        else if(![resHandler c2CallIDPassed:user.userid]){
            [favocell setHidden:YES];
        }
        else{
            favocell.nameLabel.text = [[C2CallPhone currentPhone] nameForUserid:user.userid];
            if([[NSUserDefaults standardUserDefaults] boolForKey:user.userid]){
                favocell.statusLabel.text = @"Added to favorites";
                [favocell.addButton setHidden:YES];
                [favocell.addButton2 setHidden:YES];
            }
            else{
                favocell.statusLabel.text = @"Using Ubudd";
                favocell.addButton.tag = indexPath.row;
                favocell.addButton2.tag = indexPath.row;
                [favocell.addButton setHidden:NO];
                [favocell.addButton2 setHidden:NO];
            }
            favocell.userBtn.tag = indexPath.row;
            favocell.userBtn2.tag = indexPath.row;
            
            
            UIImage *image = [[C2CallPhone currentPhone] userimageForUserid:user.userid];
            
            if (image) {
                favocell.userImg.image = image;
                favocell.userImg.layer.cornerRadius = 15.0;
                favocell.userImg.layer.masksToBounds = YES;
            }
            [favocell.userBtn setHidden:NO];
            
        }
    }
    else{
        ABRecordRef record;
        if (inSearch) {
            record = (__bridge ABRecordRef)([addressSearch objectAtIndex:indexPath.row]);
        }
        else{
            record = (__bridge ABRecordRef)([addressListSection objectAtIndex:indexPath.row]);
        }
        NSString *firstName = CFBridgingRelease(ABRecordCopyValue(record, kABPersonFirstNameProperty));
        NSString *lastName = CFBridgingRelease(ABRecordCopyValue(record, kABPersonLastNameProperty));
        NSString * fullName;
        if (lastName == nil) {
            fullName = firstName;
        }
        else if (firstName == nil) {
            fullName = lastName;
        }
        else{
            fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        }
        favocell.nameLabel.text = fullName;
        
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(record, kABPersonPhoneProperty);
        
        NSString *phone = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
        
        // Remove all formatting symbols that might be in both phone number being compared
        NSCharacterSet *toExclude = [NSCharacterSet characterSetWithCharactersInString:@"/.()- "];
        phone = [[phone componentsSeparatedByCharactersInSet:toExclude] componentsJoinedByString: @""];
        
        //favocell.statusLabel.text = phone;
        favocell.statusLabel.text = @"";
        [favocell.userImg setHidden:YES];
        [favocell.addButton setHidden:YES];
        [favocell.addButton2 setHidden:YES];
        [favocell.userBtn setHidden:YES];
    }
    
    
    return favocell;
}

-(IBAction)addToFriend:(id)sender{
    MOC2CallUser *user = [[[[ubuddUsers sections] objectAtIndex:0] objects] objectAtIndex:((UIButton*)sender).tag];
    int favCnt = [[NSUserDefaults standardUserDefaults] integerForKey:@"FavCount"];
    favCnt++;
    [[NSUserDefaults standardUserDefaults] setInteger:favCnt forKey:@"FavCount"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:user.userid];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    WUAddressBookCell *favocell;
    if(inSearch){
        favocell= (WUAddressBookCell *)[self.searchDisplayController.searchResultsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:((UIButton*)sender).tag inSection:0]];
    }
    else{
        favocell= (WUAddressBookCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:((UIButton*)sender).tag inSection:0]];
    }
    favocell.statusLabel.text = @"Added to favorites";
    [favocell.addButton setHidden:YES];
    [favocell.addButton2 setHidden:YES];
}



-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        MOC2CallUser *user = [[[[ubuddUsers sections] objectAtIndex:0] objects] objectAtIndex:indexPath.row];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.selected = NO;
        
        if ([user.userType intValue] == 2) {
            [WUBoardController setIsGroup:YES];
        } else {
            [WUBoardController setIsGroup:NO];
        }
        
        [self showChatForUserid:user.userid];
    }
    else
    {
        // TODO : add the contact page
        ABRecordRef record;
        if (inSearch) {
            record = (__bridge ABRecordRef)([addressSearch objectAtIndex:indexPath.row]);
        }
        else{
            record = (__bridge ABRecordRef)([addressListSection objectAtIndex:indexPath.row]);
        }
    }
        
}

-(IBAction)showFriendInfo:(id)sender{
    MOC2CallUser *user = [[[[ubuddUsers sections] objectAtIndex:0] objects] objectAtIndex:((UIButton*)sender).tag];
    if ([user.userType intValue] == 2) {
        [self showGroupDetailForGroupid:user.userid];
    } else {
        [self showFriendDetailForUserid:user.userid];
    }
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
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
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark SearchDisplayController Delegate

-(void) refetchResults
{
    [ubuddUsers performFetch:nil];
    addressSearch = [[NSMutableArray alloc] init];
    for (int i = 0; i < addressListSection.count; i++) {
        ABRecordRef record = (__bridge ABRecordRef)([addressListSection objectAtIndex:i]);
        NSString *firstName = CFBridgingRelease(ABRecordCopyValue(record, kABPersonFirstNameProperty));
        NSString *lastName = CFBridgingRelease(ABRecordCopyValue(record, kABPersonLastNameProperty));
        NSString * fullName;
        if (lastName == nil) {
            fullName = firstName;
        }
        else if (firstName == nil) {
            fullName = lastName;
        }
        else{
            fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        }
        if ([fullName rangeOfString:searchStr].location == NSNotFound) {
        }
        else{
            [addressSearch addObject:[addressListSection objectAtIndex:i]];
        }
    }
    [self.tableView reloadData];
}

-(void) setTextFilterForText:(NSString *) text
{
    searchStr = text;
    NSFetchRequest *fetch = [ubuddUsers fetchRequest];
    
    //    NSPredicate *textFilter = [NSPredicate predicateWithFormat:@"displayName contains[cd] %@ OR email contains[cd] %@", text, text];
    
    
    NSPredicate *textFilter = [NSPredicate predicateWithFormat:@"userType == 0 AND callmeLink == 0 AND not (userid in %@) AND displayName contains[cd] %@", [NSArray arrayWithObjects:@"9bc2858f1194dc1c107", nil], text];
    
    [fetch setPredicate:textFilter];
}

-(void) removeTextFilter
{
    NSFetchRequest *fetch = [ubuddUsers fetchRequest];
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



@end

