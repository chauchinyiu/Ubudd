//
//  WULocationSearchControllerTableViewController.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 19/9/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "WULocationSearchController.h"

@implementation WULocationCell
@synthesize nameLabel;
@end

@interface WULocationSearchController (){
    NSArray *result;
    NSString* searchStr;
}
@end

@implementation WULocationSearchController

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
    return result.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WULocationCell *cell;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"WULocationCell"];
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"WULocationCell" forIndexPath:indexPath];
    }
    
    
    // Configure the cell...
    CLPlacemark* placemark = (CLPlacemark*)[result objectAtIndex:indexPath.row];
    
    NSArray* addressArray = [placemark.addressDictionary objectForKey:@"FormattedAddressLines"];
    NSString* displayString = [addressArray objectAtIndex:0];
    for (int i = 1; i < addressArray.count; i++) {
        displayString = [NSString stringWithFormat:@"%@, %@", displayString, [addressArray objectAtIndex:i]];
    }
    
    [cell.nameLabel setText:displayString];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CLPlacemark* placemark = (CLPlacemark*)[result objectAtIndex:indexPath.row];
    WULocationCell *cell = (WULocationCell*)[tableView cellForRowAtIndexPath:indexPath];
    [self.delegate selectedLocationWithCoord:placemark.location.coordinate typedName:cell.nameLabel.text];
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
#pragma mark SearchDisplayController Delegate

-(void) refetchResults
{
    //check to see if geocoder initialized, if not initialize it
    if(self.geocoder == nil){
        self.geocoder = [[CLGeocoder alloc] init];
    }
    [self.geocoder geocodeAddressString:searchStr completionHandler:^(NSArray *placemarks, NSError *error){
        result = [[NSArray alloc] initWithArray:placemarks copyItems:YES];
        [self.searchDisplayController.searchResultsTableView reloadData];
    }];
    
}

-(void) setTextFilterForText:(NSString *) text
{
    searchStr = text;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    [self setTextFilterForText:searchString];
    // Return NO, as the search will be done in the background
    return NO;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption{
    // Return NO, as the search will be done in the background
    return NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self refetchResults];
}


@end