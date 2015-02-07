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
#import "WUFriendDetailController.h"
#import "WUContactInfoController.h"

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
    
    NSMutableArray *ubuddSearch;
    NSMutableArray *ubuddListSection;
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
    
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString*)title atIndex:(NSInteger)index{
    return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0){
        return NSLocalizedString(@"Ubudd friends", @"");
    }
    else{
        return NSLocalizedString(@"Address book", @"");
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshList];
    [self.tableView reloadData];
}

-(void)refreshList{
    inSearch = NO;
    int favCnt = 0;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFMutableArrayRef peopleMutable = CFArrayCreateMutableCopy(kCFAllocatorDefault,
                                                               CFArrayGetCount(allPeople),
                                                               allPeople);
    
    CFArraySortValues(peopleMutable,
                      CFRangeMake(0, CFArrayGetCount(peopleMutable)),
                      (CFComparatorFunction) ABPersonComparePeopleByName,
                      kABPersonSortByFirstName);
    ubuddListSection = [ResponseHandler instance].friendList;
    addressListSection = [[NSMutableArray alloc] init];
    NSUserDefaults* u = [NSUserDefaults standardUserDefaults];
    NSString* myNumber = [u objectForKey:@"msidn"];
    
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
            //add area code if does not have one
            if ([phone characterAtIndex:0] != '+') {
                phone = [NSString stringWithFormat:@"%@%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"countryCode"], phone];
            }
            
            
            if ([phone isEqualToString:myNumber]) {
                hasUbudd = true;
            }
            else{
                for (int j = 0; j < ubuddListSection.count; j++) {
                    WUAccount* a = [ubuddListSection objectAtIndex:j];
                    if ([a.phoneNo isEqualToString:phone]) {
                        hasUbudd = true;
                    }
                }
            }
        }
        if (!hasUbudd) {
            [addressListSection addObject:(__bridge id)(record)];
        }
    }
    
    for (int j = 0; j < ubuddListSection.count; j++) {
        WUAccount* a = [ubuddListSection objectAtIndex:j];
        if ([u boolForKey:a.c2CallID]) {
            favCnt++;
        }
    }
    
    
    [[NSUserDefaults standardUserDefaults] setInteger:favCnt forKey:@"FavCount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
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
    /*
    if (section == 0 && ubuddUsers != nil) {
        return [[[[ubuddUsers sections] objectAtIndex:0] objects] count];
    }*/
    if(section == 0){
        if (inSearch) {
            return ubuddSearch.count;
        }
        else{
            return ubuddListSection.count;
        }
    }
    else{
        if (inSearch) {
            return addressSearch.count;
        }
        else{
            return addressListSection.count;
        }
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return favoritesCellHeight;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WUAddressBookCell *favocell = (WUAddressBookCell *)[self.tableView dequeueReusableCellWithIdentifier:@"WUAddressBookCell"];
    favocell.nameLabel.font = [CommonMethods getStdFontType:0];
    favocell.statusLabel.font = [CommonMethods getStdFontType:2];

    if (indexPath.section == 0) {
        WUAccount* accRecord;
        if (inSearch) {
            accRecord = [ubuddSearch objectAtIndex:indexPath.row];
        }
        else{
            accRecord = [ubuddListSection objectAtIndex:indexPath.row];
        }
        if ([accRecord.name isEqualToString:@""]) {
            favocell.nameLabel.text = [[C2CallPhone currentPhone] nameForUserid:accRecord.c2CallID];
        }
        else{
            favocell.nameLabel.text = accRecord.name;
        }
        
        if([[NSUserDefaults standardUserDefaults] boolForKey:accRecord.c2CallID]){
            favocell.statusLabel.text = NSLocalizedString(@"Added to favorites", @"");
            [favocell.addButton setHidden:YES];
            [favocell.addButton2 setHidden:YES];
        }
        else{
            favocell.statusLabel.text = NSLocalizedString(@"Using Ubudd", @"");
            favocell.addButton.tag = indexPath.row;
            favocell.addButton2.tag = indexPath.row;
            [favocell.addButton setHidden:NO];
            [favocell.addButton2 setHidden:NO];
        }
        favocell.userBtn.tag = indexPath.row;
        favocell.userBtn2.tag = indexPath.row;
        
        
        UIImage *image = [[C2CallPhone currentPhone] userimageForUserid:accRecord.c2CallID];
        
        if (image) {
            favocell.userImg.image = image;
            favocell.userImg.layer.cornerRadius = 0.0;
            favocell.userImg.layer.masksToBounds = YES;
        }
        [favocell.userBtn setHidden:NO];
        
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
    WUAccount* accRecord;
    if (inSearch) {
        accRecord = [ubuddSearch objectAtIndex:((UIButton*)sender).tag];
    }
    else{
        accRecord = [ubuddListSection objectAtIndex:((UIButton*)sender).tag];
    }
    int favCnt = [[NSUserDefaults standardUserDefaults] integerForKey:@"FavCount"];
    favCnt++;
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    [ud setInteger:favCnt forKey:@"FavCount"];
    [ud setBool:YES forKey:accRecord.c2CallID];
    [ud synchronize];
    
    WUAddressBookCell *favocell;
    if(inSearch){
        favocell= (WUAddressBookCell *)[self.searchDisplayController.searchResultsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:((UIButton*)sender).tag inSection:0]];
    }
    else{
        favocell= (WUAddressBookCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:((UIButton*)sender).tag inSection:0]];
    }
    favocell.statusLabel.text = NSLocalizedString(@"Added to favorites", @"");
    [favocell.addButton setHidden:YES];
    [favocell.addButton2 setHidden:YES];
    [self.tableView reloadData];
}



-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        WUAccount* accRecord;
        if (inSearch) {
            accRecord = [ubuddSearch objectAtIndex:indexPath.row];
        }
        else{
            accRecord = [ubuddListSection objectAtIndex:indexPath.row];
        }
        [WUBoardController setIsGroup:NO];
        [self showChatForUserid:accRecord.c2CallID];
    
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
        
        NSString * storyboardName = @"MainStoryboard";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        WUContactInfoController * vc = [storyboard instantiateViewControllerWithIdentifier:@"WUContactInfoController"];
        
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
        
        NSString *phone;
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(record, kABPersonPhoneProperty);
        if(ABMultiValueGetCount(phoneNumbers) > 0){
            phone = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
        }
        [vc setContactName:fullName Tel:phone];
        [self.navigationController pushViewController:vc animated:YES];
        
    }
        
}

-(IBAction)showFriendInfo:(id)sender{
    WUAccount* accRecord;
    if (inSearch) {
        accRecord = [ubuddSearch objectAtIndex:((UIButton*)sender).tag];
    }
    else{
        accRecord = [ubuddListSection objectAtIndex:((UIButton*)sender).tag];
    }
    [WUFriendDetailController setPhoneNo:accRecord.phoneNo];
    [self showFriendDetailForUserid:accRecord.c2CallID];
}



#pragma mark SearchDisplayController Delegate

-(void) refetchResults
{
    ubuddSearch = [[NSMutableArray alloc] init];
    for (int i = 0; i < ubuddListSection.count; i++) {
        WUAccount* accRecord = [ubuddListSection objectAtIndex:i];
        if ([accRecord.name rangeOfString:searchStr options:NSCaseInsensitiveSearch].location == NSNotFound) {
        }
        else{
            [ubuddSearch addObject:[ubuddListSection objectAtIndex:i]];
        }
    }
    
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
        if ([fullName rangeOfString:searchStr options:NSCaseInsensitiveSearch].location == NSNotFound) {
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



@end

