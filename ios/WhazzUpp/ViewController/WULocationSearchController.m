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
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    CLLocationCoordinate2D loc;
    NSString* locName;

}
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

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
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
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
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return result.count;
    }
    else{
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WULocationCell *cell;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"WULocationCell"];
        // Configure the cell...
        CLPlacemark* placemark = (CLPlacemark*)[result objectAtIndex:indexPath.row];
        
        NSArray* addressArray = [placemark.addressDictionary objectForKey:@"FormattedAddressLines"];
        NSString* displayString = [addressArray objectAtIndex:0];
        for (int i = 1; i < addressArray.count; i++) {
            displayString = [NSString stringWithFormat:@"%@, %@", displayString, [addressArray objectAtIndex:i]];
        }
        
        [cell.nameLabel setText:displayString];
    }
    else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"WULocationCell" forIndexPath:indexPath];
        [cell.nameLabel setText: NSLocalizedString(@"Current location", @"")];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        CLPlacemark* placemark = (CLPlacemark*)[result objectAtIndex:indexPath.row];
        WULocationCell *cell = (WULocationCell*)[tableView cellForRowAtIndexPath:indexPath];
        [self.delegate selectedLocationWithCoord:placemark.location.coordinate typedName:cell.nameLabel.text];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [locationManager startUpdatingLocation];    
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    [locationManager stopUpdatingLocation];
    
    currentLocation = [locations lastObject];
    loc = currentLocation.coordinate;
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!(error))
         {
             CLPlacemark* placemark = (CLPlacemark*)[placemarks objectAtIndex:0];
             locName = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
             [self.delegate selectedLocationWithCoord:loc typedName:locName];
             [self.navigationController popViewControllerAnimated:YES];
         }
     }];
    
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
    [self showActivityView];
    
    //check to see if geocoder initialized, if not initialize it
    if(self.geocoder == nil){
        self.geocoder = [[CLGeocoder alloc] init];
    }
    CLRegion* refRegion = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"location"]];
    [self.geocoder geocodeAddressString:searchStr inRegion:refRegion completionHandler:^(NSArray *placemarks, NSError *error){
        result = [[NSArray alloc] initWithArray:placemarks copyItems:YES];
        
        [self.activityView stopAnimating];
        [self.searchDisplayController.searchResultsTableView reloadData];
    }];
    
}

- (void) showActivityView {
    if (self.activityView==nil) {
        self.activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
        [self.tableView addSubview:self.activityView];
        self.activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray ;
        self.activityView.hidesWhenStopped = YES;
    }
    // Center
    CGFloat x = UIScreen.mainScreen.applicationFrame.size.width/2;
    CGFloat y = UIScreen.mainScreen.applicationFrame.size.height/2;
    // Offset. If tableView has been scrolled
    CGFloat yOffset = self.tableView.contentOffset.y;
    self.activityView.frame = CGRectMake(x, y + yOffset, 0, 0);
    
    self.activityView.hidden = NO;
    [self.activityView startAnimating];
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
