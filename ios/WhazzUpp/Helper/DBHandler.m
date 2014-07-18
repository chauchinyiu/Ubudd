//
//  DBHandler.m
//  PrankCall
//
//  Created by Sahil Khanna on 10/20/12.
//  Copyright 2012 3Embed Software Technologies. All rights reserved.
//

#import "DBHandler.h"
#import <SocialCommunication/SCDataManager.h>

@implementation DBHandler

+ (NSManagedObjectContext *)context {
    if ([SCDataManager instance].isDataInitialized) {
        WUAppDelegate *appDelegate = (WUAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        return context;
    }
    else
        return nil;
}

+ (NSFetchRequest *)fetchRequestFromTable:(NSString *)table predicate:(NSPredicate *)predicate orderBy:(NSString *)column ascending:(BOOL)asc {
    
	NSManagedObjectContext *context = [self context];
    
    if (!context)
        return nil;
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:table inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
    [fetchRequest setPredicate:predicate];
	
	if (column) {
		NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:column ascending:asc];
		[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	}
	
	return fetchRequest;
}

+ (NSFetchRequest *)fetchRequestFromTable:(NSString *)table condition:(NSString *)condition orderBy:(NSString *)column ascending:(BOOL)asc {

	NSManagedObjectContext *context = [self context];
    
    if (!context)
        return nil;
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:table inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	if (condition) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:condition];
		[fetchRequest setPredicate:predicate];
	}
	
	if (column) {
		NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:column ascending:asc];
		[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	}
	
	return fetchRequest;
}

+ (NSArray *)dataFromTable:(NSString *)table condition:(NSString *)condition orderBy:(NSString *)column ascending:(BOOL)asc {
    NSManagedObjectContext *context = [self context];
    
    NSFetchRequest *fetchRequest = [self fetchRequestFromTable:table condition:condition orderBy:column ascending:asc];
	
	NSError *error = nil;
	NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
	
	if (error) {
		//NSLog(@"Core Data: %@", [error description]);
	}
	
	return result;
}

@end