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
#import "WUUserSelectionController.h"
#import <SocialCommunication/C2TapImageView.h>

@interface WUGroupDetailCellEdit : UITableViewCell
@property(nonatomic, weak) IBOutlet UIButton *btnGroupImageEdit;
@property(nonatomic, weak) IBOutlet UITextField *txtTopicEdit;
@property(nonatomic, weak) IBOutlet UIButton *btnInterestEdit;
@property(nonatomic, weak) IBOutlet UIButton *btnLocationEdit;
@property(nonatomic, weak) IBOutlet UIButton *btnIsPublicEdit;
@property(nonatomic, weak) IBOutlet C2TapImageView *btnPhoto;

@end

@interface WUGroupDetailCellReadOnly : UITableViewCell
    @property(nonatomic, weak) IBOutlet C2TapImageView *groupImg;
    @property(nonatomic, weak) IBOutlet UILabel *lblTopic, *lblLocation, *lblInterest, *lblPublic,  *lblJoinStatus;
@end

@interface WUGroupViewMediaCell : UITableViewCell
    @property(nonatomic, weak) IBOutlet UIButton *btnViewMedia;
    @property(nonatomic, weak) IBOutlet UIButton *btnEnterChat;
@end

@interface WUGroupAdminActionCell : UITableViewCell
    @property(nonatomic, weak) IBOutlet UIButton *btnAddMember;
    @property(nonatomic, weak) IBOutlet UIButton *btnDeleteGroup;
    @property(nonatomic, weak) IBOutlet UIButton *btnClearChat;
@end

@interface WUGroupMemberActionCell : UITableViewCell
    @property(nonatomic, weak) IBOutlet UIButton *btnClearChat;
    @property(nonatomic, weak) IBOutlet UIButton *btnLeaveGroup;

@end

@interface WUGroupPublicActionCell : UITableViewCell
    @property(nonatomic, weak) IBOutlet UIButton *btnEnterChat;
@end

@interface WUGroupNonMemberActionCell : UITableViewCell
    @property(nonatomic, weak) IBOutlet UIButton *btnJoinGroup;

@end

@interface WUGroupMemberCell : UITableViewCell
@end

@interface WUGroupMemberCntHeaderCell : UITableViewCell
@property(nonatomic, weak) IBOutlet UILabel *lblMemberCnt;
@end




@interface WUGroupDetailController : SCGroupDetailController<UIActionSheetDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate, UINavigationControllerDelegate, WUInterestViewControllerDelegate, WULocationSelectControllerDelegate, UITextFieldDelegate, WUUserSelectClientDelegate>

- (IBAction)btnPhotoTapped:(id)sender;
- (IBAction)btnIsPublicTapped:(id)sender;
- (IBAction)editEnded;
- (IBAction)btnJoinTapped:(id)sender;
- (IBAction)btnLeaveTapped:(id)sender;
- (IBAction)btnDeleteTapped:(id)sender;
- (IBAction)btnChatTapped:(id)sender;
- (IBAction)btnBlockMemberTapped:(id)sender;
- (IBAction)btnClearChatTapped:(id)sender;

@end
