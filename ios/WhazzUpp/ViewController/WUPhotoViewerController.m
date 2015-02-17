//
//  WUPhotoViewerController.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 26/10/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "WUPhotoViewerController.h"

@interface WUPhotoViewerController ()

@end

@implementation WUPhotoViewerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.translucent = NO;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setImages:(id)images currentImage:(id)imageKey{
    [super setImages:images currentImage:imageKey];
}



@end
