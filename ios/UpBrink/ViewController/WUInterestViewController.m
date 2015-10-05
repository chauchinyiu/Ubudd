//
//  WUInterestViewController.m
//  UpBrink
//
//  Created by Ming Kei Wong on 12/9/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "WUInterestViewController.h"
#import "DBHandler.h"
#import "ResponseHandler.h"
#import "CommonMethods.h"

@implementation WUInterestCell

@synthesize nameLabel;

@end


@interface WUInterestViewController (){
    NSArray *result;
}

@end

@implementation WUInterestViewController
@synthesize managedObjectContext = _managedObjectContext;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    /*
    self.managedObjectContext = [DBHandler context];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Interest" inManagedObjectContext:self.managedObjectContext];
    NSError *dberror = nil;
    
    //clean all old interest
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&dberror];
*/
    result = [[NSArray alloc] initWithArray:[ResponseHandler instance].interestList];
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.translucent = NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [result count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WUInterestCell *cell = (WUInterestCell*)[tableView dequeueReusableCellWithIdentifier:@"WUInterestCell" forIndexPath:indexPath];
    
    // Configure the cell...
    [cell.nameLabel setFont:[CommonMethods getStdFontType:1]];
    [cell.nameLabel setText:((interestDat *)[result objectAtIndex:indexPath.row]).interestName];

    /*
    [cell.nameLabel setText:[((NSManagedObject *)[result objectAtIndex:indexPath.row]) valueForKey:@"interestName"]];
    */
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    /*
    [self.delegate selectedInerestID:((NSNumber*)[((NSManagedObject *)[result objectAtIndex:indexPath.row]) valueForKey:@"id"]).intValue
                            withName:(NSString*)[((NSManagedObject *)[result objectAtIndex:indexPath.row]) valueForKey:@"interestName"]];
     */
    [self.delegate selectedInerestID:((interestDat *)[result objectAtIndex:indexPath.row]).interestID
                            withName:((interestDat *)[result objectAtIndex:indexPath.row]).interestName];
    [self.navigationController popViewControllerAnimated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
