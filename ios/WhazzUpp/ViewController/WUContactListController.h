//
//  WUContactListController.h
//  WhazzUpp
//
//  Created by Ming Kei Wong on 28/8/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ResponseHandler.h"

@interface WUAddressBookCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UILabel *nameLabel, *statusLabel;
@property (nonatomic, weak) IBOutlet UIImageView *userImg;
@property (nonatomic, weak) IBOutlet UIButton *userBtn, *userBtn2;

@end

@interface WUAddressBaseCell : UITableViewCell
@property(nonatomic, weak) IBOutlet UILabel *nameLabel;
@end

@interface WUNameGroupCell : UITableViewCell
@property(nonatomic, weak) IBOutlet UILabel *nameLabel;
@end


@interface WUContactListController : UITableViewController<WUReadStatusDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

-(IBAction)showFriendInfo:(id)sender;

@end
