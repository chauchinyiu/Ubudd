//
//  WUMediaController.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 15/11/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "WUMediaController.h"
#import <SocialCommunication/UIViewController+AdSpace.h>
#import <SocialCommunication/UIViewController+SCCustomViewController.h>
#import <SocialCommunication/SCDataManager.h>

#import <SocialCommunication/debug.h>
#import "WUPhotoViewController.h"

@implementation WUMediaCell
@synthesize userImage, mediaID;
@end

@interface WUMediaController ()

@end

@implementation WUMediaController
@synthesize cellIdentifier, sectionNameKeyPath, fetchedResultsController, targetUserid;

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    self.cellIdentifier = @"WUMediaCell";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInitDataEvent:) name:@"C2CallDataManager:initData" object:nil];
    
    [self initFetchedResultsController];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) handleInitDataEvent:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"C2CallDataManager:initData"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self initFetchedResultsController];
            [self.collectionView reloadData];
        });
    }
}

-(NSFetchRequest *) fetchRequest
{
    if (![SCDataManager instance].isDataInitialized)
        return nil;
    
    self.sectionNameKeyPath = nil;
    self.useDidChangeContentOnly = YES;
    
    NSFetchRequest *fetchRequest = [[SCDataManager instance] fetchRequestForEventHistory:nil sort:YES];
    
    NSPredicate *predicate = nil;
        
    predicate = [NSPredicate predicateWithFormat:@"contact == %@ AND (text contains[cd] %@ OR text contains[cd] %@)", self.targetUserid, @"image://", @"video://"];
        
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchBatchSize:0];
    return fetchRequest;
}

-(void) initFetchedResultsController
{
    NSFetchRequest *fetchRequest = [self fetchRequest];
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    
    if (!fetchRequest)
        return;
    
    @try {
        NSFetchedResultsController *aFetchedResultsController = [[SCDataManager instance] fetchedResultsControllerWithFetchRequest:fetchRequest sectionNameKeyPath:sectionNameKeyPath cacheName:nil];
        
        if (!aFetchedResultsController)
            return;
        
        if (self.fetchedResultsController) {
            self.fetchedResultsController.delegate = nil;
            self.fetchedResultsController = nil;
        }
        self.fetchedResultsController = aFetchedResultsController;
        
        aFetchedResultsController.delegate = self;
        
        NSError *error = nil;
        if (![self.fetchedResultsController performFetch:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
    @catch (NSException *exception) {
        DLog(@"Exeption : %@", exception);
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
        return 1;
    }
    
    return [[self.fetchedResultsController sections] count];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (!self.fetchedResultsController) {
        return 0;
    }
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    DLog(@"numberOfRowsInSection : %d / %d", section, [sectionInfo numberOfObjects]);
    return [sectionInfo numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = self.cellIdentifier?self.cellIdentifier : @"Cell";

    WUMediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath;
{
    if (self.useDidChangeContentOnly)
        return;
    
    UICollectionView *tableView = self.collectionView;
    
    @try {
        switch(type) {
                
            case NSFetchedResultsChangeInsert:
                [tableView insertItemsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]];
                break;
                
            case NSFetchedResultsChangeDelete:
                [tableView deleteItemsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]];
                break;
                
            case NSFetchedResultsChangeUpdate:
                [self configureCell:[tableView cellForItemAtIndexPath:indexPath]
                        atIndexPath:indexPath];
                break;
                
            case NSFetchedResultsChangeMove:
                [tableView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
                [tableView insertItemsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]];
                break;
        }
        
    }
    @catch (NSException *exception) {
        DLog(@"Error : didChangeObject : %@", exception);
        [tableView reloadData];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type;
{
    if (self.useDidChangeContentOnly)
        return;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            break;
        case NSFetchedResultsChangeMove:
        case NSFetchedResultsChangeUpdate:
            break;
            
    }
}


-(void) configureCell:(WUMediaCell *) cell atIndexPath:(NSIndexPath *) indexPath;
{
    MOC2CallEvent *elem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.userImage.image = [[C2CallPhone currentPhone] imageForKey:elem.text];
    cell.mediaID = elem.text;
    cell.btnImage.tag = indexPath.item;
}

-(void) showImage:(NSString *) key
{
    @try {
        NSMutableArray *imageList = [NSMutableArray array];
        for (MOC2CallEvent *elem in [self.fetchedResultsController fetchedObjects]) {
            if ([elem.text hasPrefix:@"image://"]) {
                NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:3];
                [info setObject:elem.text forKey:@"image"];
                [info setObject:elem.eventId forKey:@"eventId"];
                [info setObject:elem.timeStamp forKey:@"timeStamp"];
                [info setObject:elem.eventType forKey:@"eventType"];
                if (elem.senderName)
                    [info setObject:elem.senderName forKey:@"senderName"];
                
                [imageList addObject:info];
            }
        }
        
        NSString * storyboardName = @"MainStoryboard";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        WUPhotoViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"WUPhotoViewController"];
        [vc showPhotos:imageList currentPhoto:key];
        [self.navigationController pushViewController:vc animated:YES];
    }
    @catch (NSException *exception) {
        
    }
}




-(IBAction)showButtonClicked:(id)sender{
    NSIndexPath* indexPath = [NSIndexPath indexPathForItem:((UIButton*)sender).tag inSection:0];
    MOC2CallEvent *elem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([elem.text hasPrefix:@"image://"]) {
        [self showImage:elem.text];
    }
    if ([elem.text hasPrefix:@"video://"]) {
        [self showVideo:elem.text];
    }
}

@end
