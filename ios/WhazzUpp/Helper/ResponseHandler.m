//
//  ResponseHandler.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 2/9/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "ResponseHandler.h"
#import "WebserviceHandler.h"
#import "ServiceURL.h"
#import "ResponseBase.h"

#import "VerifyC2CallID.h"
#import "VerifyC2CallIDDTO.h"
#import "DataRequest.h"
#import "DataResponse.h"
#import "DBHandler.h"

@interface ResponseHandler (){
    NSFetchedResultsController *ubuddUsers;
}
@end

@implementation ResponseHandler
@synthesize managedObjectContext = _managedObjectContext;

static ResponseHandler *myInstance;

-(id)init{
    self.managedObjectContext = [DBHandler context];
    return self;
}

+(ResponseHandler*) instance{
    if (myInstance == nil) {
        myInstance = [[ResponseHandler alloc] init];
    }
    return myInstance;
}

-(void)verifyNewC2CallID{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(userType == 0 OR userType == 2) AND callmeLink == 0"];
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
            if(![self c2CallIDVerified:user.userid]){
                [self verifyC2CallID:user.userid];
            }
        }
    }
    [[NSUserDefaults standardUserDefaults] setInteger:favCnt forKey:@"FavCount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    

}

-(void)verifyC2CallID:(NSString*)c2CallID{
    VerifyC2CallIDDTO *vDTO = [[VerifyC2CallIDDTO alloc] init];
    vDTO.c2CallID = c2CallID;
    
    WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
    [serviceHandler execute:METHOD_VERIFY_C2CALLID parameter:vDTO target:self action:@selector(verifyC2CallResponse:error:)];
}

- (void)verifyC2CallResponse:(ResponseBase *)response error:(NSError *)error {
    VerifyC2CallID *vOBj = (VerifyC2CallID *)response;
    
    if (error){
    }
    else{
        NSString* keyName = [NSString stringWithFormat:@"verified_%@", [vOBj c2CallID]];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:keyName];
        keyName = [NSString stringWithFormat:@"verifyResult_%@", [vOBj c2CallID]];
        [[NSUserDefaults standardUserDefaults] setInteger:vOBj.resultCode forKey:keyName];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(BOOL)c2CallIDVerified:(NSString*)c2CallID{
    NSString* keyName = [NSString stringWithFormat:@"verified_%@", c2CallID];
    return [[NSUserDefaults standardUserDefaults] boolForKey:keyName];
}

-(BOOL)c2CallIDPassed:(NSString*)c2CallID{
    NSString* keyName = [NSString stringWithFormat:@"verified_%@", c2CallID];
    if([[NSUserDefaults standardUserDefaults] boolForKey:keyName]){
        keyName = [NSString stringWithFormat:@"verifyResult_%@", c2CallID];
        return ([[NSUserDefaults standardUserDefaults] integerForKey:keyName] == 1);
    }
    return NO;
}

-(void)readInterests{
    //read from server
    DataRequest *dataRequest = [[DataRequest alloc] init];
    dataRequest.requestName = @"readInterest";
    WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
    [serviceHandler execute:METHOD_DATA_REQUEST parameter:dataRequest target:self action:@selector(readInterestResponse:error:)];
    
}

- (void)readInterestResponse:(ResponseBase *)response error:(NSError *)error {
    DataResponse *res = (DataResponse *)response;
    
    if (error){
        
    }
    else {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Interest" inManagedObjectContext:self.managedObjectContext];
        NSError *dberror = nil;
        
        //clean all old interest
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entityDescription];
        NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&dberror];
        for (int i = 0; i < result.count; i++) {
            NSManagedObject *interest = (NSManagedObject *)[result objectAtIndex:i];
            [self.managedObjectContext deleteObject:interest];
            [interest.managedObjectContext save:&dberror];
        }
        
        int rowCnt = [[res.data objectForKey:@"rowCnt"] integerValue];
        for (int i = 0; i < rowCnt; i++) {
            NSManagedObject *interest = [[NSManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.managedObjectContext];
            [interest setValue:[res.data objectForKey:[NSString stringWithFormat: @"id%d", i]] forKey:@"id"];
            [interest setValue:[res.data objectForKey:[NSString stringWithFormat: @"name%d", i]] forKey:@"interestName"];
            [interest.managedObjectContext save:&dberror];
        }
        //save time stamp
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"interestRefreshTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(NSString*)getInterestNameForID:(int) intID{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Interest" inManagedObjectContext:self.managedObjectContext];
    NSError *dberror = nil;
    NSString* resultName = @"";
    
    //clean all old interest
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&dberror];
    for (int i = 0; i < result.count; i++) {
        NSManagedObject *interest = (NSManagedObject *)[result objectAtIndex:i];
        if (((NSNumber*)[interest valueForKey:@"id"]).intValue == intID) {
            resultName = (NSString*)[interest valueForKey:@"interestName"];
        }
    }
    return resultName;
}


-(void)checkPhoneNumber{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userType == 0 AND callmeLink == 0"];
    NSFetchRequest *fetch = [DBHandler fetchRequestFromTable:@"MOC2CallUser" predicate:predicate orderBy:@"firstname" ascending:YES];
    
    ubuddUsers = [[NSFetchedResultsController alloc] initWithFetchRequest:fetch managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    [ubuddUsers performFetch:nil];
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFMutableArrayRef peopleMutable = CFArrayCreateMutableCopy(kCFAllocatorDefault,
                                                               CFArrayGetCount(allPeople),
                                                               allPeople);
    
    CFArraySortValues(peopleMutable,
                      CFRangeMake(0, CFArrayGetCount(peopleMutable)),
                      (CFComparatorFunction) ABPersonComparePeopleByName,
                      kABPersonSortByFirstName);

    NSUInteger phoneCnt = 0;
    NSMutableArray* phoneArray = [NSMutableArray array];
   
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
            
            
            for (int j = 0; j < [[[[ubuddUsers sections] objectAtIndex:0] objects] count]; j++) {
                MOC2CallUser *user = [[[[ubuddUsers sections] objectAtIndex:0] objects] objectAtIndex:j];
                //filter verified c2callID only
                if([self c2CallIDPassed:user.userid]){
                    if ([phone isEqualToString: user.ownNumber]) {
                        hasUbudd = true;
                    }
                }
            }
            if (!hasUbudd) {
                [phoneArray addObject:[NSString stringWithFormat:@"%@@mobifyi.com", phone]];
                phoneCnt++;
            }
        }
    }
    [[C2CallPhone currentPhone] findFriends:phoneArray];
}



@end
