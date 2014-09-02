//
//  WUUserSelectionController.h
//  WhazzUpp
//
//  Created by Ming Kei Wong on 2/9/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import <SocialCommunication/SocialCommunication.h>

@interface WUUserSelectCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UILabel *titleLabel, *subTitleLabel;

@end

@interface WUUserSelectionController : SCUserSelectionController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
