//
//  WUAddressbookController.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 28/8/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//
#import <CoreData/CoreData.h>
#import "WUAddressbookController.h"
#import "WUAppDelegate.h"


@implementation WUAddressbookController

@synthesize checkIndex = checkIndex;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    
    /*
    NSManagedObjectContext *context = [(WUAppDelegate* )([[UIApplication sharedApplication] delegate]) managedObjectContext];
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
    NSArray *allPeople = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    //check exists in local storage
    NSInteger totalContacts =[allPeople count];
    
    for(NSUInteger loop= 0 ; loop < totalContacts; loop++)
    {
        ABRecordRef record = (__bridge ABRecordRef)[allPeople objectAtIndex:loop]; // get address book record
        if(ABRecordGetRecordType(record) ==  kABPersonType){
            ABRecordID recordId = ABRecordGetRecordID(record);
            NSNumber *recordNo = [NSNumber numberWithInt:(int)recordId];
            NSString *firstNameString = (__bridge NSString*)ABRecordCopyValue(record,kABPersonFirstNameProperty); // fetch contact first name from address book
            
            NSString *lastNameString = (__bridge NSString*)ABRecordCopyValue(record,kABPersonLastNameProperty); // fetch contact last name from address book
            
            NSString * fullName = [NSString stringWithFormat:@"%@ %@", firstNameString, lastNameString];

            ABMultiValueRef phoneNumbers = ABRecordCopyValue(record, kABPersonPhoneProperty);
            NSString * compositePhone = @"";
            // If the contact has multiple phone numbers, iterate on each of them
            for (int i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
                NSString *phone = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                
                // Remove all formatting symbols that might be in both phone number being compared
                NSCharacterSet *toExclude = [NSCharacterSet characterSetWithCharactersInString:@"/.()- "];
                phone = [[phone componentsSeparatedByCharactersInSet:toExclude] componentsJoinedByString: @""];
                if (i == 0) {
                    compositePhone = [NSString stringWithString:phone];
                }
                else{
                    compositePhone = [NSString stringWithFormat:@"%@, %@", compositePhone, phone];
                }
            }
            
            
            //check id first
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription
                                           entityForName:@"PhoneRecord" inManagedObjectContext:context];
            [fetchRequest setEntity:entity];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                      @"recordID == %@", recordNo];
            [fetchRequest setPredicate:predicate];
            
            NSError *error;
            bool hasRecord = false;
            NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
            if (fetchedObjects != nil) {
                hasRecord = ([fetchedObjects count] > 0); // May be 0 if the object has been deleted.
            }
            if (hasRecord) {
                //refresh full name and phone number
                NSManagedObject *record = (NSManagedObject *)[fetchedObjects objectAtIndex:0];
                
                [record setValue:fullName forKey:@"fullName"];
                [record setValue:compositePhone forKey:@"phoneNo"];
                [record.managedObjectContext save:&error];
            }
            else{
                //check full name
                predicate = [NSPredicate predicateWithFormat:
                                          @"(fullName == %@)", fullName];
                [fetchRequest setPredicate:predicate];
                
                hasRecord = false;
                fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
                if (fetchedObjects != nil) {
                    hasRecord = ([fetchedObjects count] > 0);
                }
                if (hasRecord) {
                    //refresh id and phone number
                    NSManagedObject *record = (NSManagedObject *)[fetchedObjects objectAtIndex:0];
                    
                    [record setValue:recordNo forKey:@"recordID"];
                    [record setValue:compositePhone forKey:@"phoneNo"];
                    [record.managedObjectContext save:&error];
                }
                else{
                    //add new record
                    NSManagedObject *record = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
                    [record setValue:recordNo forKey:@"recordID"];
                    [record setValue:fullName forKey:@"fullName"];
                    [record setValue:0 forKey:@"checkResult"];
                    [record setValue:compositePhone forKey:@"phoneNo"];
                    [record.managedObjectContext save:&error];
                }
            }
        }
    }
     */
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Using Ubudd";
    }
    else{
        return @"Contact";
    }
}

@end
