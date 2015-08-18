//
//  WUContactDetailController.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 13/12/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "WUContactInfoController.h"
#import "CommonMethods.h"

@interface WUContactInfoController (){
    NSString* telNo;
    NSString* contactName;
}
@end

@implementation WUContactInfoController
@synthesize nameLabel, telLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.translucent = NO;
    [nameLabel setFont:[CommonMethods getStdFontType:1]];
    [telLabel setFont:[CommonMethods getStdFontType:1]];
    
    [nameLabel setText:contactName];
    [telLabel setText:telNo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)callButtonClicked:(id)sender{
    NSString* phoneNumber;
    phoneNumber = [@"telprompt://" stringByAppendingString:telNo];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

-(void)setContactName:(NSString*) name Tel:(NSString*)tel{
    telNo = tel;
    contactName = name;
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
