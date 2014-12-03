//
//  WUUserSelectionController.h
//  WhazzUpp
//
//  Created by Ming Kei Wong on 2/9/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import <SocialCommunication/SocialCommunication.h>

@protocol WUUserSelectClientDelegate <NSObject>
@required
-(void)selectedUsersUpdated:(NSArray*)users;
@end


@interface WUUserSelectCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UILabel *titleLabel;
@property(nonatomic, weak) IBOutlet UIImageView *photo;

@end

@interface WUUserSelectionController : UITableViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property(nonatomic,assign)id<WUUserSelectClientDelegate>delegate;

-(void)setSelectedAccount:(NSArray*)users;

@end
