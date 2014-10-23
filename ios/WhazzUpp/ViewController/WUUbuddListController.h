//
//  WUUbuddListController.h
//  WhazzUpp
//
//  Created by Ming Kei Wong on 27/9/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import <SocialCommunication/SocialCommunication.h>
#import "WUMapViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface WUUbuddListCell : UITableViewCell
@property(nonatomic, weak) IBOutlet UILabel     *nameLabel, *statusLabel, *accessLabel;
@property (nonatomic, weak) IBOutlet UIImageView *userImg;
@property (nonatomic, weak) IBOutlet UIButton *userBtn;
@property (nonatomic, weak) IBOutlet UIButton *addButton;

@end

@interface WUUbuddListController : UITableViewController<UISearchBarDelegate, UISearchControllerDelegate, UISearchDisplayDelegate, WUMapControllerDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate>

@property(nonatomic, weak) IBOutlet UILabel *locationLabel, *distanceLabel;


-(IBAction)showFriendInfo:(id)sender;
-(IBAction)joinGroup:(id)sender;

@end
