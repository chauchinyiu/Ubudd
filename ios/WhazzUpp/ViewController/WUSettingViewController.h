//
//  WUSettingViewController.h
//  WhazzUpp
//
//  Created by Ming Kei Wong on 7/10/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WUSettingViewController : UITableViewController
@property(nonatomic, weak) IBOutlet UILabel *lblConnectionStatus;
@property(nonatomic, weak) IBOutlet UILabel *lblMyProfile;
@property(nonatomic, weak) IBOutlet UILabel *lblAboutUbudd;
@property(nonatomic, weak) IBOutlet UILabel *lblTellAFriend;
@property(nonatomic, weak) IBOutlet UILabel *lblConnectionStatusHeader;
@property(nonatomic, weak) IBOutlet UILabel *lblFontSizeSetting;
@property(nonatomic, weak) IBOutlet UILabel *lblContactUs;
@property(nonatomic, weak) IBOutlet UILabel *lblHelp;

@end
