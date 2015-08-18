//
//  WUSettingViewController.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 7/10/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "WUSettingViewController.h"
#import "WUAppDelegate.h"
#import "CommonMethods.h"


@interface WUSettingViewController ()

@end

@implementation WUSettingViewController
@synthesize lblConnectionStatus, lblAboutUbudd, lblConnectionStatusHeader, lblFontSizeSetting, lblMyProfile, lblTellAFriend, lblContactUs, lblHelp;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    WUAppDelegate *appDelegate = (WUAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    lblAboutUbudd.font = [CommonMethods getStdFontType:1];
    lblConnectionStatus.font = [CommonMethods getStdFontType:1];
    lblConnectionStatusHeader.font = [CommonMethods getStdFontType:1];
    lblFontSizeSetting.font = [CommonMethods getStdFontType:1];
    lblMyProfile.font = [CommonMethods getStdFontType:1];
    lblTellAFriend.font = [CommonMethods getStdFontType:1];
    lblContactUs.font = [CommonMethods getStdFontType:1];
    lblHelp.font = [CommonMethods getStdFontType:1];
    
    if (appDelegate.loginCompleted) {
        [lblConnectionStatus setText:NSLocalizedString(@"Connected", @"")];
        [lblConnectionStatus setTextColor:[UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:100.0/255.0 alpha:1.0]];
    }
    else{
        [lblConnectionStatus setText:NSLocalizedString(@"Not connected", @"")];
        [lblConnectionStatus setTextColor:[UIColor redColor]];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.translucent = NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 10;
}

- (void)preferredContentSizeChanged:(NSNotification *)aNotification {
    [self.tableView reloadData];
    
    lblAboutUbudd.font = [CommonMethods getStdFontType:1];
    lblConnectionStatus.font = [CommonMethods getStdFontType:1];
    lblConnectionStatusHeader.font = [CommonMethods getStdFontType:1];
    lblFontSizeSetting.font = [CommonMethods getStdFontType:1];
    lblMyProfile.font = [CommonMethods getStdFontType:1];
    lblTellAFriend.font = [CommonMethods getStdFontType:1];
    lblContactUs.font = [CommonMethods getStdFontType:1];
    lblHelp.font = [CommonMethods getStdFontType:1];
    
}


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
