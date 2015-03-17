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
#import "Constant.h"

@implementation interestDat
@synthesize interestID;
@synthesize interestName;
@end

@implementation WUBroadcast
@synthesize messageID, message, isImage, postTime, imgData, markForDelete;

- (void)readImageData{
    if(isImage){
        
        NSString *imageUrl = [NSString stringWithFormat:@"http://128.199.145.104/uploads/%@", message];
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            imgData = data;
            if([ResponseHandler instance].bcdelegate){
                [[ResponseHandler instance].bcdelegate readBroadcastImgCompleted];
            }
        }];
    }

}

@end

@implementation WUAccount
@synthesize name, phoneNo, c2CallID, status, createTime;

- (NSComparisonResult)compare:(WUAccount *)otherObject {
    return [self.name compare:otherObject.name];
}

@end


@interface ResponseHandler (){
    NSFetchedResultsController *ubuddUsers;
    BOOL readingBroadcast;
}
@end

@implementation ResponseHandler
@synthesize managedObjectContext = _managedObjectContext;
@synthesize interestList = _interestList;
@synthesize friendList = _friendList;
@synthesize groupList = _groupList;
@synthesize broadcastList = _broadcastList;
@synthesize lastBroadcastTime;

static ResponseHandler *myInstance;

-(id)init{
    //load friend list
    
    
    self.friendList = [[NSMutableArray alloc] init];
    NSUserDefaults* u = [NSUserDefaults standardUserDefaults];
    
    int tVersion = (int)[u integerForKey:@"RefreshVersion"];
    if (tVersion >= kRefreshVersion) {
        int friendCnt = (int)[u integerForKey:@"friendCnt"];
        for (int i = 0; i < friendCnt; i++) {
            WUAccount* a = [[WUAccount alloc] init];
            a.c2CallID = [u valueForKey:[NSString stringWithFormat:@"friendID%d", i]];
            a.phoneNo = [u valueForKey:[NSString stringWithFormat:@"friendPhoneNo%d", i]];
            a.name = @"";
            [self.friendList addObject:a];
        }
        [self refreshFriendListNames];
    }
    self.groupList = [[NSMutableArray alloc] init];
    [self readGroups];
    self.broadcastList = [[NSMutableArray alloc] init];
    readingBroadcast = false;
    return self;
}

+(ResponseHandler*) instance{
    if (myInstance == nil) {
        myInstance = [[ResponseHandler alloc] init];
    }
    return myInstance;
}

-(void)verifyNewC2CallID{
    self.managedObjectContext = [DBHandler context];

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
    NSString *languageID = [[NSBundle mainBundle] preferredLocalizations].firstObject;
    
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    [data setValue:languageID forKey:@"lang"];
    dataRequest.values = data;
    
    dataRequest.requestName = @"readInterest";
    WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
    [serviceHandler execute:METHOD_DATA_REQUEST parameter:dataRequest target:self action:@selector(readInterestResponse:error:)];
    
}

- (void)readInterestResponse:(ResponseBase *)response error:(NSError *)error {
    DataResponse *res = (DataResponse *)response;
    
    if (error){
        
    }
    else {
        self.interestList = [[NSMutableArray alloc] init];
        int rowCnt = (int)[[res.data objectForKey:@"rowCnt"] integerValue];
        for (int i = 0; i < rowCnt; i++) {
            interestDat *objint = [[interestDat alloc] init];
            objint.interestID = [(NSNumber*)[res.data objectForKey:[NSString stringWithFormat: @"id%d", i]] intValue];
            objint.interestName = [res.data objectForKey:[NSString stringWithFormat: @"name%d", i]];
            [self.interestList addObject:objint];
        }
        //save time stamp
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"interestRefreshTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(NSString*)getInterestNameForID:(int) intID{
    NSString* resultName = @"";
    for (int i = 0; i < self.interestList.count; i++) {
        if (((interestDat*)[self.interestList objectAtIndex:i]).interestID == intID) {
            resultName = ((interestDat*)[self.interestList objectAtIndex:i]).interestName;
        }
    }
    return resultName;
}




-(void)checkPhoneNumberFromIndex:(int)fIndex{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFMutableArrayRef peopleMutable = CFArrayCreateMutableCopy(kCFAllocatorDefault,
                                                               CFArrayGetCount(allPeople),
                                                               allPeople);
    
    CFArraySortValues(peopleMutable,
                      CFRangeMake(0, CFArrayGetCount(peopleMutable)),
                      (CFComparatorFunction) ABPersonComparePeopleByName,
                      kABPersonSortByFirstName);
    
    NSMutableArray* phoneArray = [NSMutableArray array];
    NSMutableArray* addressPhones = [NSMutableArray array];
    NSString* myNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"msidn"];

    //run 30 per round
    for (CFIndex loop = fIndex; loop < CFArrayGetCount(peopleMutable) && loop < fIndex + 30; loop++){
        BOOL hasUbudd = false;
        ABRecordRef record = CFArrayGetValueAtIndex(peopleMutable, loop); // get address book record
        
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(record, kABPersonPhoneProperty);
        
        [addressPhones removeAllObjects];
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
                for (int j = 0; j < self.friendList.count; j++) {
                    WUAccount* a = [self.friendList objectAtIndex:j];
                    if ([phone isEqualToString:a.phoneNo]) {
                        hasUbudd = true;
                    }
                }
                if (!hasUbudd) {
                    for (int j = 0; j < phoneArray.count; j++) {
                        NSString* a = [phoneArray objectAtIndex:j];
                        if ([phone isEqualToString:a]) {
                            hasUbudd = true;
                        }
                    }
                }
            }
            
            if (!hasUbudd) {
                [addressPhones addObject:phone];
            }
        }
        //the phone is not list, add to check list
        if (!hasUbudd) {
            [phoneArray addObjectsFromArray:addressPhones];
        }
    }
    //send phone list to server
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for (int i = 0; i < [phoneArray count]; i++) {
        [dictionary setValue:[phoneArray objectAtIndex:i] forKey:[NSString stringWithFormat:@"phoneNo%d", i]];
    }
    [dictionary setValue:[NSNumber numberWithInt:(int)[phoneArray count]] forKey:@"phoneNoCnt"];
    if (fIndex + 30 < CFArrayGetCount(peopleMutable)) {
        [dictionary setValue:[NSNumber numberWithInt:fIndex + 30] forKey:@"toPhoneNoIndex"];
    }
    else{
        [dictionary setValue:[NSNumber numberWithInt:-1] forKey:@"toPhoneNoIndex"];
    }

    DataRequest *dataRequest = [[DataRequest alloc] init];
    dataRequest.requestName = @"checkPhoneNumbers";
    dataRequest.values = dictionary;
    
    WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
    [serviceHandler execute:METHOD_DATA_REQUEST parameter:dataRequest target:self action:@selector(checkPhoneNumbers:error:)];
}

- (void)checkPhoneNumbers:(ResponseBase *)response error:(NSError *)error {
    DataResponse *res = (DataResponse *)response;
    
    if (error){
        
    }
    else {
        NSUserDefaults* u = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary* addressbookInfo = [[NSMutableDictionary alloc] initWithDictionary:res.data];
        NSNumber* matchCnt = [addressbookInfo objectForKey:@"matchCnt"];
        for (int i = 0; i < [matchCnt intValue]; i++) {
            NSString* phoneNo = [addressbookInfo objectForKey:[NSString stringWithFormat:@"phoneMatch%d", i]];
            NSString* c2CallID = [addressbookInfo objectForKey:[NSString stringWithFormat:@"c2CallID%d", i]];
            WUAccount* a = [[WUAccount alloc] init];
            a.c2CallID = c2CallID;
            a.phoneNo = phoneNo;
            [self.friendList addObject:a];
        }
        
        self.friendList = [NSMutableArray arrayWithArray:[self.friendList sortedArrayUsingSelector:@selector(compare:)]];

        for (int j = 0; j < self.friendList.count; j++) {
            WUAccount* a = [self.friendList objectAtIndex:j];
            [u setValue:a.c2CallID forKey:[NSString stringWithFormat:@"friendID%d", j]];
            [u setValue:a.phoneNo forKey:[NSString stringWithFormat:@"friendPhoneNo%d", j]];
        }
        [u setInteger:self.friendList.count forKey:@"friendCnt"];
        [u synchronize];
        
        NSNumber* phoneIndex = [addressbookInfo objectForKey:@"toPhoneNoIndex"];
        if ([phoneIndex intValue] != -1) {
            [self checkPhoneNumberFromIndex:[phoneIndex intValue]];
        }
        else{
            [self refreshFriendListNames];
        }
    }
}

-(void)refreshFriendListNames{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFMutableArrayRef peopleMutable = CFArrayCreateMutableCopy(kCFAllocatorDefault,
                                                               CFArrayGetCount(allPeople),
                                                               allPeople);
    
    CFArraySortValues(peopleMutable,
                      CFRangeMake(0, CFArrayGetCount(peopleMutable)),
                      (CFComparatorFunction) ABPersonComparePeopleByName,
                      kABPersonSortByFirstName);
    
    
    //refresh name
    for (int j = 0; j < self.friendList.count; j++) {
        WUAccount* a = [self.friendList objectAtIndex:j];
        for (CFIndex loop = 0; loop < CFArrayGetCount(peopleMutable); loop++){
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
                
                if ([phone isEqualToString:a.phoneNo]){
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
                    a.name = fullName;
                }
            }
        }
    }

}

-(void)readGroups{
    DataRequest* datRequest = [[DataRequest alloc] init];
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    [data setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"msidn"] forKey:@"userID"];
    datRequest.values = data;
    datRequest.requestName = @"readUserGroups";
    
    WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
    [serviceHandler execute:METHOD_DATA_REQUEST parameter:datRequest target:self action:@selector(readUserGroupResponse:error:)];
}

- (void)readUserGroupResponse:(ResponseBase *)response error:(NSError *)error{
    NSDictionary* fetchResult = ((DataResponse*)response).data;
    [self.groupList removeAllObjects];

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"EST"];
    [dateFormat setTimeZone:gmt];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    int groupCnt = ((NSNumber*)[fetchResult objectForKey:@"rowCnt"]).intValue;
    for (int i = 0; i < groupCnt; i++) {
        if(((NSNumber*)[fetchResult objectForKey:[NSString stringWithFormat:@"isMember%d", i]]).intValue < 3){
            WUAccount* a = [[WUAccount alloc] init];
            a.c2CallID = [fetchResult objectForKey:[NSString stringWithFormat:@"c2CallID%d", i]];
            a.name = [fetchResult objectForKey:[NSString stringWithFormat:@"topic%d", i]];
            a.createTime = [dateFormat dateFromString:[fetchResult objectForKey:[NSString stringWithFormat:@"createTime%d", i]]];
            [self.groupList addObject:a];
        }
    }
}

-(void)readBroadcasts{
    if(!readingBroadcast){
        DataRequest* datRequest = [[DataRequest alloc] init];
        NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
        datRequest.values = data;
        datRequest.requestName = @"readBroadcasts";
        readingBroadcast = true;
        WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
        [serviceHandler execute:METHOD_DATA_REQUEST parameter:datRequest target:self action:@selector(readBoardcastResponse:error:)];
    }
}

- (void)readBoardcastResponse:(ResponseBase *)response error:(NSError *)error{
    NSDictionary* fetchResult = ((DataResponse*)response).data;

    WUBroadcast* msg;
    for (int i = 0; i < self.broadcastList.count; i++) {
        msg = [self.broadcastList objectAtIndex:i];
        msg.markForDelete = YES;
    }
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"EST"];
    [dateFormat setTimeZone:gmt];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    int cnt = ((NSNumber*)[fetchResult objectForKey:@"rowCnt"]).intValue;
    for (int i = 0; i < cnt; i++) {
        int mID = ((NSNumber*)[fetchResult objectForKey:[NSString stringWithFormat:@"messageID%d", i]]).intValue;
        BOOL hasOldCopy = NO;
        for (int j = 0; j < self.broadcastList.count; j++) {
            msg = [self.broadcastList objectAtIndex:j];
            if (msg.messageID == mID) {
                msg.markForDelete = NO;
                hasOldCopy = YES;
            }
        }
        if (!hasOldCopy) {
            msg = [[WUBroadcast alloc] init];
            msg.messageID = mID;
            msg.message = [fetchResult objectForKey:[NSString stringWithFormat:@"message%d", i]];
            msg.isImage = (((NSNumber*)[fetchResult objectForKey:[NSString stringWithFormat:@"isImage%d", i]]).intValue == 1);
            msg.postTime = [dateFormat dateFromString:[fetchResult objectForKey:[NSString stringWithFormat:@"addtime%d", i]]];
            if (msg.isImage) {
                [msg readImageData];
            }
            [self.broadcastList addObject:msg];
        }
       lastBroadcastTime = [dateFormat dateFromString:[fetchResult objectForKey:[NSString stringWithFormat:@"addtime%d", i]]];
    }
    NSMutableIndexSet* iset = [[NSMutableIndexSet alloc] init];
    for (int i = 0; i < self.broadcastList.count; i++) {
        msg = [self.broadcastList objectAtIndex:i];
        if (msg.markForDelete) {
            [iset addIndex:i];
        }
    }
    [self.broadcastList removeObjectsAtIndexes:iset];
    readingBroadcast = false;
    if (self.bcdelegate) {
        [self.bcdelegate readBroadcastCompleted];
    }
}

@end
