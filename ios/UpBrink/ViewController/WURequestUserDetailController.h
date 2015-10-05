//
//  WURequestUserDetailController.h
//  UpBrink
//
//  Created by Ming Kei Wong on 14/10/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SocialCommunication/C2TapImageView.h>

@interface WURequestUserInfoCell : UITableViewCell
@property(nonatomic, weak) IBOutlet UILabel *displayName;
@property(nonatomic, weak) IBOutlet C2TapImageView *userPhoto;

@end

@interface WURequestUserDetailController : UITableViewController
@property NSDictionary* userData;

@end
