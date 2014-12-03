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
#import "WUC2CallUser.h"

@implementation WUUserSelectCell

@synthesize titleLabel, photo;

@end

@interface WUUserSelectionController (){
    ResponseHandler *resHandler;
    NSFetchedResultsController *ubuddUsers;
    NSMutableArray* friendList;
    NSMutableArray* selection;
    NSArray* startList;
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
    resHandler = [ResponseHandler instance];
    self.managedObjectContext = [DBHandler context];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    friendList = [ResponseHandler instance].friendList;
    selection = [[NSMutableArray alloc] init];
    for (int i = 0; i < friendList.count; i++) {
        [selection addObject: [NSNumber numberWithBool:NO]];
        WUAccount *a = [friendList objectAtIndex:i];
        for (int j = 0; j < startList.count; j++) {
            NSString* u = [startList objectAtIndex:j];
            if([u isEqualToString:a.c2CallID]){
                [selection replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WUUserSelectCell *cell = (WUUserSelectCell *)[self.tableView dequeueReusableCellWithIdentifier:@"SCUserCell"];
    
    WUAccount* a = [friendList objectAtIndex:indexPath.row];
    cell.titleLabel.text = a.name;
    UIImage* image = [[C2CallPhone currentPhone] userimageForUserid:a.c2CallID];
    if(image){
        [cell.photo setImage:image];
    }
    else{
        NSDictionary* userInfo = [[C2CallPhone currentPhone] getUserInfoForUserid:a.c2CallID];
        NSString* imageName = [userInfo objectForKey:@"ImageLarge"];
        if(imageName){
            image = [[C2CallPhone currentPhone] imageForKey:imageName];
            if(image){
                [cell.photo setImage:image];
            }
        }
    }
    if (((NSNumber*)[selection objectAtIndex:indexPath.row]).boolValue) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return friendList.count;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (((NSNumber*)[selection objectAtIndex:indexPath.row]).boolValue) {
        [selection replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:NO]];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else{
        [selection replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}


- (IBAction)confirmSelection:(id)sender{
    NSMutableArray* result = [[NSMutableArray alloc] init];
    for (int i = 0; i < selection.count; i++) {
        if (((NSNumber*)[selection objectAtIndex:i]).boolValue) {
            WUAccount* a = [friendList objectAtIndex:i];
            [result addObject:a.c2CallID];
        }
    }
    [self.delegate selectedUsersUpdated:result];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setSelectedAccount:(NSArray*)users{
    startList = users;
}

@end
