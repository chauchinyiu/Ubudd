//
//  ResponseHandler.h
//  WhazzUpp
//
//  Created by Ming Kei Wong on 2/9/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface interestDat : NSObject
@property int interestID;
@property(strong, nonatomic) NSString *interestName;
@end

@interface ResponseHandler : NSObject
-(void)verifyC2CallID:(NSString*)c2CallID;
-(void)verifyNewC2CallID;
-(BOOL)c2CallIDVerified:(NSString*)c2CallID;
-(BOOL)c2CallIDPassed:(NSString*)c2CallID;
-(void)readInterests;
-(void)checkPhoneNumber;
-(NSString*)getInterestNameForID:(int) intID;
+(ResponseHandler*) instance;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSMutableArray *interestList;

@end