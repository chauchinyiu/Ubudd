//
//  WUUserImageController.m
//  UpBrink
//
//  Created by Ming Kei Wong on 6/12/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "WUUserImageController.h"

@interface WUUserImageController ()

@end

@implementation WUUserImageController
@synthesize viewImage;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.translucent = NO;
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationItem.title = NSLocalizedString(@"Profile Pic", @"");
    if (viewImage) {
        [self.userimageView setImage:viewImage];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
