//
//  WUContactDetailController.h
//  WhazzUpp
//
//  Created by Ming Kei Wong on 13/12/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WUContactInfoController : UIViewController
@property(nonatomic, weak) IBOutlet UILabel *nameLabel, *telLabel;
-(IBAction)callButtonClicked:(id)sender;
-(void)setContactName:(NSString*) name Tel:(NSString*)tel;
@end
