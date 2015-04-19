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

@interface WUAccount : NSObject

- (NSComparisonResult)compare:(WUAccount *)otherObject;

@property NSString* name;
@property NSString* phoneNo;
@property NSString* c2CallID;
@property NSString* status;
@property NSDate* createTime;
@property NSMutableAttributedString* attributedName;
@property NSString* lastName;
@end

@interface WUBroadcast : NSObject

- (void)readImageData;
@property int messageID;
@property NSString* message;
@property BOOL isImage;
@property NSDate* postTime;
@property NSData* imgData;
@property BOOL markForDelete;
@end


@protocol WUReadBroadcastDelegate <NSObject>
@required
-(void)readBroadcastCompleted;
-(void)readBroadcastImgCompleted;
@end


@protocol WUReadStatusDelegate <NSObject>
@required
-(void)readStatusCompleted;
@end


@interface ResponseHandler : NSObject
-(void)verifyC2CallID:(NSString*)c2CallID;
-(void)verifyNewC2CallID;
-(BOOL)c2CallIDVerified:(NSString*)c2CallID;
-(BOOL)c2CallIDPassed:(NSString*)c2CallID;
-(void)readInterests;
-(void)readGroups;
-(void)readStatus;
-(void)readBroadcasts;
-(void)checkPhoneNumberFromIndex:(int)fIndex;
-(NSString*)getInterestNameForID:(int) intID;
+(ResponseHandler*) instance;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSMutableArray *interestList;
@property (strong, nonatomic) NSMutableArray *friendList;
@property (strong, nonatomic) NSMutableArray *groupList;
@property (strong, nonatomic) NSMutableArray *broadcastList;
@property (nonatomic,assign)id<WUReadBroadcastDelegate>bcdelegate;
@property (nonatomic,assign)id<WUReadStatusDelegate>stdelegate;
@property NSDate* lastBroadcastTime;


@end