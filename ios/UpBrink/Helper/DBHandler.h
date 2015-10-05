//
//  DBHandler.h
//  PrankCall
//
//  Created by Sahil Khanna on 10/20/12.
//  Copyright 2012 3Embed Software Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WUAppDelegate.h"
#import "Constant.h"

@interface DBHandler : NSObject

+ (NSArray *)dataFromTable:(NSString *)table condition:(NSString *)condition orderBy:(NSString *)column ascending:(BOOL)asc;
+ (NSFetchRequest *)fetchRequestFromTable:(NSString *)table condition:(NSString *)condition orderBy:(NSString *)column ascending:(BOOL)asc;
+ (NSFetchRequest *)fetchRequestFromTable:(NSString *)table predicate:(NSPredicate *)predicate orderBy:(NSString *)column ascending:(BOOL)asc;

+ (NSManagedObjectContext *)context;

@end
