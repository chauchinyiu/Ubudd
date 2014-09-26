//
//  WUStatusSelectController.h
//  WhazzUpp
//
//  Created by Ming Kei Wong on 26/9/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WUStatusSelectControllerDelegate <NSObject>
@required
-(void)selectedStatus:(NSString*)status;
@end

@interface WUStatusSelectController : UITableViewController<UITextFieldDelegate>

@property(nonatomic, weak) IBOutlet UITextField *userStatus;
@property(nonatomic,assign)id<WUStatusSelectControllerDelegate>delegate;
@property NSString* currentStatus;

-(void) doneEditing:(id)sender;
@end
