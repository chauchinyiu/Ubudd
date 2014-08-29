//
//  WUContactListController.h
//  WhazzUpp
//
//  Created by Ming Kei Wong on 28/8/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>

@interface WUAddressBookCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UILabel     *nameLabel, *statusLabel;
@property (nonatomic, weak) IBOutlet UIImageView *userImg;

@end
@interface WUContactListController : UITableViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
