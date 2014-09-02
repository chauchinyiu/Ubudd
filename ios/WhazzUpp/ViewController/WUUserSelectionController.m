//
//  WUUserSelectionController.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 2/9/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "WUUserSelectionController.h"
#import "DBHandler.h"
#import "ResponseHandler.h"

@implementation WUUserSelectCell

@synthesize titleLabel, subTitleLabel;

@end

@interface WUUserSelectionController (){
    ResponseHandler *resHandler;
    NSFetchedResultsController *ubuddUsers;
}
@end

@implementation WUUserSelectionController
@synthesize managedObjectContext = _managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    resHandler = [[ResponseHandler alloc] init];
    self.managedObjectContext = [DBHandler context];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(userType == 0 OR userType == 2) AND callmeLink == 0"];
    NSFetchRequest *fetch = [DBHandler fetchRequestFromTable:@"MOC2CallUser" predicate:predicate orderBy:@"firstname" ascending:YES];
    
    ubuddUsers = [[NSFetchedResultsController alloc] initWithFetchRequest:fetch managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    [ubuddUsers performFetch:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL) validUser:(NSString*)userName Email:(NSString*)email{
    BOOL hasValid = NO;
    for (int j = 0; j < [[[[ubuddUsers sections] objectAtIndex:0] objects] count]; j++) {
        MOC2CallUser *user = [[[[ubuddUsers sections] objectAtIndex:0] objects] objectAtIndex:j];
        if(user.userType.intValue != 2){
            if ([[[C2CallPhone currentPhone] nameForUserid:user.userid] isEqualToString:userName] && [user.email isEqualToString:email] ) {
                if ([resHandler c2CallIDPassed:user.userid]) {
                    hasValid = YES;
                }
            }
        }
    }
    return hasValid;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    WUUserSelectCell* cell = (WUUserSelectCell*)[super tableView:tableView cellForRowAtIndexPath: indexPath];
    if ([self validUser:cell.titleLabel.text Email:cell.subTitleLabel.text]) {
        return [super tableView:tableView heightForRowAtIndexPath: indexPath];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WUUserSelectCell* cell = (WUUserSelectCell*)[super tableView:tableView cellForRowAtIndexPath: indexPath];
    if (![self validUser:cell.titleLabel.text Email:cell.subTitleLabel.text]) {
        [cell setHidden:YES];
    }
    
    return cell;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
