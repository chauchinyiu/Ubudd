//
//  WUMapViewController.m
//  UpBrink
//
//  Created by Ming Kei Wong on 15/10/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "WUMapViewController.h"
#import "CommonMethods.h"

@interface WUMapViewController (){
    CLLocationCoordinate2D loc;
    NSString* locName;
    NSString* computedName;
    int searchDist;
}

@end

@implementation WUMapViewController
@synthesize mapview, lblLocName;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    if ([ud boolForKey:@"hasLocSearch"]) {
        loc.latitude = [ud floatForKey:@"searchLat"];
        loc.longitude = [ud floatForKey:@"searchLong"];
        locName = [ud stringForKey:@"searchLoc"];
        searchDist = (int)[ud integerForKey:@"searchDist"];
    }
    else{
        loc.latitude = 999;
        loc.longitude = 999;
        locName = @"";
        searchDist = 2;
    }
    [self refreshGUI];
    
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
    return 6;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MapCell" forIndexPath:indexPath];
    [cell.textLabel setFont:[CommonMethods getStdFontType:1]];
    // Configure the cell...
    switch (indexPath.row) {
        case 0:
            [cell setTag:2];
            break;
        case 1:
            [cell setTag:5];
            break;
        case 2:
            [cell setTag:10];
            break;
        case 3:
            [cell setTag:20];
            break;
        case 4:
            [cell setTag:50];
            break;
        case 5:
            [cell setTag:100];
            break;
        default:
            break;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%dKm", (int)[cell tag]];
    if ([cell tag] == searchDist) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    searchDist = (int)[cell tag];
    [self saveSelection];
    [self refreshGUI];
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!(error))
         {
             CLPlacemark* placemark = (CLPlacemark*)[placemarks objectAtIndex:0];
             computedName = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
             [mapView.userLocation setTitle:computedName];
         }
     }];

}


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

-(void)selectedLocationWithCoord:(CLLocationCoordinate2D)coord typedName:(NSString*)typedname{
    loc = coord;
    locName = typedname;
    [self saveSelection];
    [self refreshGUI];
}

-(void)saveSelection{
    
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:YES forKey:@"hasLocSearch"];
    [ud setFloat:loc.latitude forKey:@"searchLat"];
    [ud setFloat:loc.longitude forKey:@"searchLong"];
    [ud setObject:locName forKey:@"searchLoc"];
    [ud setInteger:searchDist forKey:@"searchDist"];
    [ud synchronize];
    [self.delegate searchUpdated];
}

-(void)refreshGUI{
    [mapview removeAnnotations:[mapview annotations]];
    [mapview setShowsUserLocation:YES];
    [lblLocName setFont:[CommonMethods getStdFontType:1]];
    [self.lblWith setFont:[CommonMethods getStdFontType:1]];

    lblLocName.text = locName;
    if (loc.longitude < 999) {
        MKPointAnnotation* pin = [[MKPointAnnotation alloc] init];
        pin.title= locName;
        pin.coordinate=loc;
        [mapview addAnnotation:pin];
        [mapview setRegion:MKCoordinateRegionMakeWithDistance(loc, searchDist * 2000, searchDist * 2000) animated:YES];
    }
    
    [self.tableView reloadData];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    WULocationSearchController *cvc = (WULocationSearchController *)[segue destinationViewController];
    cvc.delegate = self;
}


@end
