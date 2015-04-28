//
//  WUContactListController.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 28/8/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//
#import <SocialCommunication/UIViewController+SCCustomViewController.h>
#import "WUContactListController.h"
#import "WebserviceHandler.h"
#import "ServiceURL.h"
#import "ResponseBase.h"
#import "CommonMethods.h"
#import "DataResponse.h"
#import "DataRequest.h"
#import "WUBoardController.h"
#import "WUFriendDetailController.h"
#import "WUContactInfoController.h"

#import "DBHandler.h"

@implementation WUAddressBookCell
@synthesize nameLabel, statusLabel, userBtn;
@end

@implementation WUAddressBaseCell
@synthesize nameLabel;
@end

@implementation WUNameGroupCell
@synthesize nameLabel;
@end

@interface WUContactListController ()<UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>
{
    CGFloat favoritesCellHeight;
    NSMutableArray *addressListSection;
    NSMutableArray *addressSearch;
    NSFetchedResultsController *ubuddUsers;
    ResponseHandler *resHandler;
    BOOL inSearch;
    
    NSMutableArray *ubuddSearch;
    NSMutableArray *ubuddListSection;
    
    NSMutableArray* headers;
    NSMutableArray* entries;
    NSMutableArray* sectionSize;
    
}
@property (nonatomic, strong) UISearchController *searchController;
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

- (void)customizeUI
{

    
    [[self.tabBarController.viewControllers objectAtIndex:0] setTabBarItem:[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Contacts", @"") image:[UIImage imageNamed:@"contacscreen_contacts_icon_off"] selectedImage:[UIImage imageNamed:@"contacscreen_contacts_icon_on"]]];
    [[self.tabBarController.viewControllers objectAtIndex:1] setTabBarItem:[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"UBudd List", @"") image:[UIImage imageNamed:@"contacscreen_status_icon_on"] selectedImage:[UIImage imageNamed:@"contacscreen_status_icon_on"]]];
    [[self.tabBarController.viewControllers objectAtIndex:2] setTabBarItem:[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Chats", @"") image:[UIImage imageNamed:@"contacscreen_chat_icon_off"] selectedImage:[UIImage imageNamed:@"contacscreen_chat_icon_on"]]];
    [[self.tabBarController.viewControllers objectAtIndex:3] setTabBarItem:[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"More", @"") image:[UIImage imageNamed:@"contacscreen_more_icon_off"] selectedImage:[UIImage imageNamed:@"contacscreen_more_icon_on"]]];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self customizeUI];
    
    resHandler = [ResponseHandler instance];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:@"WUAddressBookCell"];
    favoritesCellHeight = cell.frame.size.height;
    self.managedObjectContext = [DBHandler context];
    
    [ResponseHandler instance].stdelegate = self;
    [[ResponseHandler instance] readStatus];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString*)title atIndex:(NSInteger)index{
    return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0){
        return NSLocalizedString(@"Ubudd", @"");
    }
    else{
        return NSLocalizedString(@"Address book", @"");
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    //set up search bar
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    // we want to be the delegate for our filtered table so didSelectRowAtIndexPath is called for both tables
    self.tableView.delegate = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO; // default is YES
    self.searchController.searchBar.delegate = self; // so we can monitor text changes + others
    
    // Search is now just presenting a view controller. As such, normal view controller
    // presentation semantics apply. Namely that presentation will walk up the view controller
    // hierarchy until it finds the root view controller or one that defines a presentation context.
    //
    self.definesPresentationContext = YES;
    
    self.navigationController.navigationBar.translucent = NO;
    [self refreshList];
    [self.tableView reloadData];
}





#pragma mark - UISearchControllerDelegate

// Called after the search controller's search bar has agreed to begin editing or when
// 'active' is set to YES.
// If you choose not to present the controller yourself or do not implement this method,
// a default presentation is performed on your behalf.
//
// Implement this method if the default presentation is not adequate for your purposes.
//
- (void)presentSearchController:(UISearchController *)searchController {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    inSearch = YES;
}

- (void)willDismissSearchController:(UISearchController *)searchController
{
   NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)didDismissSearchController:(UISearchController *)searchController {
   NSLog(@"%@", NSStringFromSelector(_cmd));
   inSearch = NO;
}

-(void)refreshList{
    inSearch = NO;
    int favCnt = 0;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
    if (!addressBook) {
        return;
    }
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFMutableArrayRef peopleMutable = CFArrayCreateMutableCopy(kCFAllocatorDefault,
                                                               CFArrayGetCount(allPeople),
                                                               allPeople);
    
    CFArraySortValues(peopleMutable,
                      CFRangeMake(0, CFArrayGetCount(peopleMutable)),
                      (CFComparatorFunction) ABPersonComparePeopleByName,
                      kABPersonSortByLastName);
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
    
    [self rebuildEntries];
    
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
    return ((NSNumber*)[sectionSize objectAtIndex:section]).integerValue;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (int i = 0; i < entries.count; i++) {
        WUListEntry* e = [entries objectAtIndex:i];
        if (e.mapToPath.row == indexPath.row && e.mapToPath.section == indexPath.section) {
            if ([e.source isEqualToString:@"NameHeader"]) {
                return 22;
            }
            else{
                return favoritesCellHeight;
            }
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
    for (int i = 0; i < entries.count; i++) {
        WUListEntry* e = [entries objectAtIndex:i];
        if (e.mapToPath.row == indexPath.row && e.mapToPath.section == indexPath.section) {
            if ([e.source isEqualToString:@"NameHeader"]) {
                cell = [self.tableView dequeueReusableCellWithIdentifier:@"WUNameGroupCell"];
                ((WUNameGroupCell *)cell).nameLabel.text = [e.data valueForKey:@"nameChar"];
            }
            else if ([e.source isEqualToString:@"Friend"]) {
                WUAddressBookCell *favocell = (WUAddressBookCell *)[self.tableView dequeueReusableCellWithIdentifier:@"WUAddressBookCell"];
                favocell.statusLabel.font = [CommonMethods getStdFontType:2];
                
                WUAccount* accRecord = [e.data valueForKey:@"Friend"];
                if ([accRecord.name isEqualToString:@""]) {
                    favocell.nameLabel.text = [[C2CallPhone currentPhone] nameForUserid:accRecord.c2CallID];
                }
                else{
                    favocell.nameLabel.attributedText = accRecord.attributedName;
                }
                
                favocell.statusLabel.text = accRecord.status;
                favocell.userBtn.tag = indexPath.row;
                favocell.userBtn2.tag = indexPath.row;
                
                
                UIImage *image = [[C2CallPhone currentPhone] userimageForUserid:accRecord.c2CallID];
                
                if (image) {
                    favocell.userImg.image = image;
                    favocell.userImg.layer.cornerRadius = 0.0;
                    favocell.userImg.layer.masksToBounds = YES;
                }
                [favocell.userBtn setHidden:NO];
                
                cell = favocell;
                
            }
            else if ([e.source isEqualToString:@"Address"]) {
                WUAddressBaseCell *favocell = (WUAddressBaseCell *)[self.tableView dequeueReusableCellWithIdentifier:@"WUAddressBaseCell"];
                favocell.nameLabel.font = [CommonMethods getStdFontType:0];
                
                ABRecordRef record;
                if (inSearch) {
                    record = (__bridge ABRecordRef)([addressSearch objectAtIndex:e.sourcePath.row]);
                }
                else{
                    record = (__bridge ABRecordRef)([addressListSection objectAtIndex:e.sourcePath.row]);
                }
                NSString *firstName = CFBridgingRelease(ABRecordCopyValue(record, kABPersonFirstNameProperty));
                NSString *lastName = CFBridgingRelease(ABRecordCopyValue(record, kABPersonLastNameProperty));
                NSString * fullName;
                NSMutableAttributedString* attributedName;
                UIFont* fontBold = [CommonMethods getStdFontType:0];
                UIFont* fontStd = [CommonMethods getStdFontType:1];
                
                if (lastName == nil) {
                    if (firstName == nil) {
                        attributedName = nil;
                    }
                    else{
                        fullName = firstName;
                        attributedName = [[NSMutableAttributedString alloc] initWithString:fullName];
                        [attributedName addAttribute:NSFontAttributeName value:fontBold range:NSMakeRange(0, fullName.length)];
                    }
                }
                else if (firstName == nil) {
                    fullName = lastName;
                    attributedName = [[NSMutableAttributedString alloc] initWithString:fullName];
                    [attributedName addAttribute:NSFontAttributeName value:fontBold range:NSMakeRange(0, fullName.length)];
                }
                else{
                    fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
                    attributedName = [[NSMutableAttributedString alloc] initWithString:fullName];
                    [attributedName addAttribute:NSFontAttributeName value:fontStd range:NSMakeRange(0, firstName.length)];
                    [attributedName addAttribute:NSFontAttributeName value:fontBold range:NSMakeRange(firstName.length + 1, lastName.length)];
                }
                
                favocell.nameLabel.attributedText = attributedName;
                
                ABMultiValueRef phoneNumbers = ABRecordCopyValue(record, kABPersonPhoneProperty);
                
                NSString *phone = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
                
                // Remove all formatting symbols that might be in both phone number being compared
                NSCharacterSet *toExclude = [NSCharacterSet characterSetWithCharactersInString:@"/.()- "];
                phone = [[phone componentsSeparatedByCharactersInSet:toExclude] componentsJoinedByString: @""];
                
                cell = favocell;
                
            }
        }
    }
    
    return cell;
}



-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (int i = 0; i < entries.count; i++) {
        WUListEntry* e = [entries objectAtIndex:i];
        if (e.mapToPath.row == indexPath.row && e.mapToPath.section == indexPath.section) {
            if ([e.source isEqualToString:@"Friend"]) {
                WUAddressBookCell *favocell = (WUAddressBookCell *)[self.tableView dequeueReusableCellWithIdentifier:@"WUAddressBookCell"];
                favocell.statusLabel.font = [CommonMethods getStdFontType:2];
                
                WUAccount* accRecord = [e.data valueForKey:@"Friend"];
                [WUBoardController setIsGroup:NO];
                [self showChatForUserid:accRecord.c2CallID];
            }
            else if ([e.source isEqualToString:@"Address"]) {
                ABRecordRef record;
                if (inSearch) {
                    record = (__bridge ABRecordRef)([addressSearch objectAtIndex:e.sourcePath.row]);
                }
                else{
                    record = (__bridge ABRecordRef)([addressListSection objectAtIndex:e.sourcePath.row]);
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
    }
}

-(IBAction)showFriendInfo:(id)sender{
    WUAccount* accRecord;
    
    for (int i = 0; i < entries.count; i++) {
        WUListEntry* e = [entries objectAtIndex:i];
        if (e.mapToPath.row == ((UIButton*)sender).tag && e.mapToPath.section == 0) {
            accRecord = [e.data valueForKey:@"Friend"];
            [WUFriendDetailController setPhoneNo:accRecord.phoneNo];
            [self showFriendDetailForUserid:accRecord.c2CallID];
        }
    }
}



#pragma mark SearchDisplayController Delegate

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    
    if (!searchController.searchBar.text) {
        searchController.searchBar.text = @"";
    }
    ubuddSearch = [[NSMutableArray alloc] init];
    for (int i = 0; i < ubuddListSection.count; i++) {
        WUAccount* accRecord = [ubuddListSection objectAtIndex:i];
        if ([accRecord.name rangeOfString:searchController.searchBar.text options:NSCaseInsensitiveSearch].location != NSNotFound)
        {

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
        if ([fullName rangeOfString:searchController.searchBar.text options:NSCaseInsensitiveSearch].location != NSNotFound)
        {

            [addressSearch addObject:[addressListSection objectAtIndex:i]];
        }
    }
    [self rebuildEntries];
    [self.tableView reloadData];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    inSearch = YES;
    [searchBar resignFirstResponder];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    inSearch = NO;
    [searchBar resignFirstResponder];
}



-(void)readStatusCompleted{
    [self.tableView reloadData];
}

-(void)rebuildEntries{
    NSString* lastNameChar;
    NSString* oldLastNameChar;
    
    headers = [[NSMutableArray alloc] init];
    entries = [[NSMutableArray alloc] init];
    sectionSize = [[NSMutableArray alloc] init];
    
    
    WUListEntry* e;
    e = [[WUListEntry alloc] init];
    e.source = [NSMutableString stringWithString:@"FriendHeader"];
    [headers addObject:e];
    [sectionSize addObject:[NSNumber numberWithInt:0]];
    
    oldLastNameChar = @"";
    
    if (inSearch) {
        for (int i = 0; i < ubuddSearch.count; i++) {
            WUAccount* a = [ubuddSearch objectAtIndex:i];
            if (a.lastName) {
                if (a.lastName.length > 0) {
                    lastNameChar = [[a.lastName substringToIndex:1] uppercaseString];
                    if (![oldLastNameChar isEqualToString:lastNameChar]) {
                        WUListEntry* e;
                        e = [[WUListEntry alloc] init];
                        e.source = [NSMutableString stringWithString:@"NameHeader"];
                        e.data = [[NSMutableDictionary alloc] init];
                        [e.data setValue:lastNameChar forKey:@"nameChar"];
                        [self addEntry:e];
                        oldLastNameChar = lastNameChar;
                    }
                }
            }
            WUListEntry* e;
            e = [[WUListEntry alloc] init];
            e.source = [NSMutableString stringWithString:@"Friend"];
            e.data = [[NSMutableDictionary alloc] init];
            [e.data setValue:a forKey:@"Friend"];
            [self addEntry:e];
        }
    }
    else{
        
        for (int i = 0; i < ubuddListSection.count; i++) {
            WUAccount* a = [ubuddListSection objectAtIndex:i];
            if (a.lastName) {
                if (a.lastName.length > 0) {
                    lastNameChar = [[a.lastName substringToIndex:1] uppercaseString];
                    if (![oldLastNameChar isEqualToString:lastNameChar]) {
                        WUListEntry* e;
                        e = [[WUListEntry alloc] init];
                        e.source = [NSMutableString stringWithString:@"NameHeader"];
                        e.data = [[NSMutableDictionary alloc] init];
                        [e.data setValue:lastNameChar forKey:@"nameChar"];
                        [self addEntry:e];
                        oldLastNameChar = lastNameChar;
                    }
                }
            }
            WUListEntry* e;
            e = [[WUListEntry alloc] init];
            e.source = [NSMutableString stringWithString:@"Friend"];
            e.data = [[NSMutableDictionary alloc] init];
            [e.data setValue:a forKey:@"Friend"];
            [self addEntry:e];
        }
    }
    
    e = [[WUListEntry alloc] init];
    e.source = [NSMutableString stringWithString:@"AddressHeader"];
    [headers addObject:e];
    [sectionSize addObject:[NSNumber numberWithInt:0]];
    
    oldLastNameChar = @"";
    
    if (inSearch) {

        for (int i = 0; i < addressSearch.count; i++) {
            ABRecordRef record = (__bridge ABRecordRef)([addressSearch objectAtIndex:i]);
            NSString *lastName = CFBridgingRelease(ABRecordCopyValue(record, kABPersonLastNameProperty));
            
            if (!lastName) {
                lastName = CFBridgingRelease(ABRecordCopyValue(record, kABPersonFirstNameProperty ));
            }
            if (lastName.length > 0) {
                lastNameChar = [[lastName substringToIndex:1] uppercaseString];
                if (![oldLastNameChar isEqualToString:lastNameChar]) {
                    WUListEntry* e;
                    e = [[WUListEntry alloc] init];
                    e.source = [NSMutableString stringWithString:@"NameHeader"];
                    e.data = [[NSMutableDictionary alloc] init];
                    [e.data setValue:lastNameChar forKey:@"nameChar"];
                    [self addEntry:e];
                    oldLastNameChar = lastNameChar;
                }
            }
            
            WUListEntry* e;
            e = [[WUListEntry alloc] init];
            e.source = [NSMutableString stringWithString:@"Address"];
            e.sourcePath = [NSIndexPath indexPathForRow:i inSection:1];
            [self addEntry:e];
        }
    }
    else{
        for (int i = 0; i < addressListSection.count; i++) {
            ABRecordRef record = (__bridge ABRecordRef)([addressListSection objectAtIndex:i]);
            NSString *lastName = CFBridgingRelease(ABRecordCopyValue(record, kABPersonLastNameProperty));
            
            if (!lastName) {
                lastName = CFBridgingRelease(ABRecordCopyValue(record, kABPersonFirstNameProperty ));
            }
            if (lastName.length > 0) {
               lastNameChar = [[lastName substringToIndex:1] uppercaseString];
                if (![oldLastNameChar isEqualToString:lastNameChar]) {
                    WUListEntry* e;
                    e = [[WUListEntry alloc] init];
                    e.source = [NSMutableString stringWithString:@"NameHeader"];
                    e.data = [[NSMutableDictionary alloc] init];
                    [e.data setValue:lastNameChar forKey:@"nameChar"];
                    [self addEntry:e];
                    oldLastNameChar = lastNameChar;
                }
            }
            WUListEntry* e;
            e = [[WUListEntry alloc] init];
            e.source = [NSMutableString stringWithString:@"Address"];
            e.sourcePath = [NSIndexPath indexPathForRow:i inSection:1];
            [self addEntry:e];
        }
    }
}

-(void)addEntry:(WUListEntry*)e{
    int currentSectionLen  = ((NSNumber*)[sectionSize objectAtIndex:sectionSize.count - 1]).intValue;
    e.mapToPath = [NSIndexPath indexPathForRow:currentSectionLen inSection:sectionSize.count - 1 ];
    
    
    [entries addObject:e];
    
    [sectionSize replaceObjectAtIndex:sectionSize.count - 1 withObject:[NSNumber numberWithInt:currentSectionLen + 1]];
    
}


@end

