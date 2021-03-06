//
//  WUPhotoViewController.h
//  UpBrink
//
//  Created by Ming Kei Wong on 19/12/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SocialCommunication/SocialCommunication.h>
#import "WUNewChatViewController.h"

@interface WUPhotoViewController : UIPageViewController<UIPageViewControllerDataSource, UIPageViewControllerDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate, WUTargetSelectControllerDelegate>

@property NSString* chatTitle;

-(void) showPhotos:(NSArray *) imageList currentPhoto:(NSString *) imageKey;

@end
