//
//  WUUbuddListController.h
//  UpBrink
//
//  Created by Ming Kei Wong on 27/9/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import <SocialCommunication/SocialCommunication.h>
#import "WUMapViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface WUUbuddListCell : UITableViewCell
@property(nonatomic, weak) IBOutlet UILabel *nameLabel, *statusLabel, *memberLabel, *memberHeaderLabel, *hosetedByLabel, *hostedByHeaderLabel;
@property (nonatomic, weak) IBOutlet UIImageView *userImg;
@property (nonatomic, weak) IBOutlet UIView *detailView;

@end

@interface WUUbuddListController : UITableViewController<UISearchBarDelegate, UISearchControllerDelegate, UISearchDisplayDelegate, WUMapControllerDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate>

@property(nonatomic, weak) IBOutlet UILabel *locationLabel, *distanceLabel;
@property (nonatomic, strong) NSString *createdGroupId;
@property (nonatomic, weak) IBOutlet UISearchBar *searchB;


-(void)useResult:(NSDictionary*) result;


@end
