//
//  WUChatHistoryController.h
//  WhazzUpp
//
//  Created by Michael Knecht on 02.06.13.
//  Copyright (c) 2013 C2Call GmbH. All rights reserved.
//

#import <SocialCommunication/SocialCommunication.h>
#import "ResponseHandler.h"

@interface WUChatHistoryCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UILabel     *nameLabel, *textLabel, *timeLabel, *missedEvents;
@property(nonatomic, weak) IBOutlet UIImageView *userImage;

@end

@interface WUHistoryRequestCell : UITableViewCell
@property(nonatomic, weak) IBOutlet UILabel     *nameLabel;
@end

@interface WUChatHistoryController : SCDataTableViewController<WUReadBroadcastDelegate>

@property (nonatomic, strong) NSString *createdGroupId;

-(IBAction)toggleEditing:(id)sender;
-(void)readBroadcastCompleted;

@end