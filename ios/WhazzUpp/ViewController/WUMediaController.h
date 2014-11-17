//
//  WUMediaController.h
//  WhazzUpp
//
//  Created by Ming Kei Wong on 15/11/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface WUMediaCell : UICollectionViewCell

@property(nonatomic, weak) IBOutlet UIImageView *userImage;
@property(nonatomic, weak) IBOutlet UIButton *btnImage;
@property(nonatomic, strong) NSString       *mediaID;

@end

@interface WUMediaController : UICollectionViewController<NSFetchedResultsControllerDelegate>

-(NSFetchRequest *) fetchRequest;
-(void) initFetchedResultsController;
-(void) configureCell:(WUMediaCell *) cell atIndexPath:(NSIndexPath *) indexPath;

@property(nonatomic, strong) NSString       *targetUserid;
@property(nonatomic, strong) NSString       *cellIdentifier;
@property(nonatomic, strong) NSString       *sectionNameKeyPath;
@property(nonatomic) BOOL                   useDidChangeContentOnly;
@property(nonatomic, strong) NSFetchedResultsController     *fetchedResultsController;

-(IBAction)showButtonClicked:(id)sender;
-(void) showImage:(NSString *) key;

@end
