//
//  WUImageViewController.h
//  WhazzUpp
//
//  Created by Ming Kei Wong on 19/12/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WUImageViewController : UIViewController<UIScrollViewDelegate>
@property(nonatomic, weak) IBOutlet UIImageView *imageView;
@property(nonatomic, weak) IBOutlet UIScrollView *imageFrame;
@property(nonatomic, strong) UIImage* viewImage;
@property int pageID;
@property NSDictionary* info;


-(void)imageClicked;

@end
