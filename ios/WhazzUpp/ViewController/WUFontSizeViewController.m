//
//  WUFontSizeViewController.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 15/8/2015.
//  Copyright (c) 2015年 3Embed Technologies. All rights reserved.
//

#import "WUFontSizeViewController.h"
#import "CommonMethods.h"

@interface WUFontSizeViewController ()

@end

@implementation WUFontSizeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.messageLabel setFont:[CommonMethods getStdFontType:1]];
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
