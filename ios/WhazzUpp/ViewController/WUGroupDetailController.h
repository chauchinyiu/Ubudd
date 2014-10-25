//
//  WUGroupDetailController.h
//  WhazzUpp
//
//  Created by Ming Kei Wong on 21/9/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import <SocialCommunication/SocialCommunication.h>
#import "WUInterestViewController.h"
#import "WULocationSearchController.h"

@interface WUGroupDetailCellEdit : UITableViewCell
@property(nonatomic, weak) IBOutlet UIButton *btnGroupImageEdit;
@property(nonatomic, weak) IBOutlet UITextField *txtTopicEdit;
@property(nonatomic, weak) IBOutlet UITextField *txtTopic2Edit;
@property(nonatomic, weak) IBOutlet UIButton *btnInterestEdit;
@property(nonatomic, weak) IBOutlet UITextField *txtSubInterestEdit;
@property(nonatomic, weak) IBOutlet UIButton *btnLocationEdit;
@property(nonatomic, weak) IBOutlet UIButton *btnIsPublicEdit;
@property(nonatomic, weak) IBOutlet UILabel *lblMemberCntEdit;

@end

@interface WUGroupDetailCellReadOnly : UITableViewCell
    @property(nonatomic, weak) IBOutlet UIImageView *groupImg;
    @property(nonatomic, weak) IBOutlet UILabel *lblTopic, *lblTopicDesc, *lblLocation, *lblInterest, *lblSubinterest, *lblPublic, *lblHost, *lblMemberCnt, *lblJoinStatus;
    @property(nonatomic, weak) IBOutlet UIButton *btnJoin;
@end

@interface WUGroupDetailController : SCGroupDetailController<UIActionSheetDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate, UINavigationControllerDelegate, WUInterestViewControllerDelegate, WULocationSelectControllerDelegate>

- (IBAction)btnPhotoTapped:(id)sender;
- (IBAction)btnIsPublicTapped:(id)sender;
- (IBAction)editEnded;
- (IBAction)btnJoinTapped:(id)sender;

@end
