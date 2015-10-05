//
//  WUJoinRequestController.h
//  UpBrink
//
//  Created by Ming Kei Wong on 14/10/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WUJoinRequestListCell : UITableViewCell
@property(nonatomic, weak) IBOutlet UILabel     *nameLabel, *groupLabel;
@property (nonatomic, weak) IBOutlet UIImageView *userImg;
@property (nonatomic, weak) IBOutlet UIButton *userBtn;

@end


@interface WUJoinRequestController : UITableViewController<UIAlertViewDelegate>

@end
