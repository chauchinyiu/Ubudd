//
//  WUUbuddMapViewController.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 23/10/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "WUUbuddMapViewController.h"
#import <SocialCommunication/UIViewController+SCCustomViewController.h>
#import <SocialCommunication/debug.h>
#import "DBHandler.h"
#import "WUBoardController.h"
#import "DataRequest.h"
#import "WebserviceHandler.h"
#import "ResponseBase.h"
#import "DataResponse.h"
#import <MapKit/MapKit.h>

@implementation WUUbuddMapViewAnnotation
@synthesize groupIndex;

@end

@interface WUUbuddMapViewController (){
    NSDictionary* fetchResult;
    BOOL inSearch;
    NSString* searchStr;
    CLLocationCoordinate2D loc;
    NSString* locName;
    int searchDist;
    
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    NSString* curLocName;

}
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation WUUbuddMapViewController
@synthesize locationLabel, distanceLabel, mapview;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(hidekeybord)];
    [tap setDelegate:self];
    [self.view addGestureRecognizer:tap];
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
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

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!(error))
         {
             CLPlacemark* placemark = (CLPlacemark*)[placemarks objectAtIndex:0];
             curLocName = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
             [mapview.userLocation setTitle:curLocName];
         }
     }];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    [locationManager stopUpdatingLocation];
    
    currentLocation = [locations lastObject];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!(error))
         {
             CLPlacemark* placemark = (CLPlacemark*)[placemarks objectAtIndex:0];
             curLocName = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
             locName = curLocName;
             [self updateLocationSearchGUI];
         }
     }];
    loc = currentLocation.coordinate;
    [self updateLocationSearchGUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [self searchUpdated];
    [self reloadMap];
}

-(void)useResult:(NSDictionary*) result{
    fetchResult = [NSDictionary dictionaryWithDictionary:result];
}

- (void)readUserGroup{
    
    [self showActivityView];
    
    DataRequest* datRequest = [[DataRequest alloc] init];
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    [data setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"msidn"] forKey:@"userID"];
    datRequest.values = data;
    datRequest.requestName = @"readUserGroups";
    
    WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
    [serviceHandler execute:METHOD_DATA_REQUEST parameter:datRequest target:self action:@selector(readUserGroupResponse:error:)];
    
}


- (void)searchUserGroup:(NSString*)searchTxt{
    
    [self showActivityView];
    searchStr = searchTxt;
    
    DataRequest* datRequest = [[DataRequest alloc] init];
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    [data setValue:searchTxt forKey:@"searchString"];
    MKCoordinateRegion r = MKCoordinateRegionMakeWithDistance(loc, searchDist * 2000, searchDist * 2000);
    
    [data setValue:[NSNumber numberWithFloat:loc.latitude - (r.span.latitudeDelta / 2)] forKey:@"latFrom"];
    [data setValue:[NSNumber numberWithFloat:loc.latitude + (r.span.latitudeDelta / 2)] forKey:@"latTo"];
    [data setValue:[NSNumber numberWithFloat:loc.longitude - (r.span.longitudeDelta / 2)] forKey:@"longFrom"];
    [data setValue:[NSNumber numberWithFloat:loc.longitude + (r.span.longitudeDelta / 2)] forKey:@"longTo"];
    
    [data setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"msidn"] forKey:@"userID"];
    datRequest.values = data;
    datRequest.requestName = @"searchGroup";
    
    WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
    [serviceHandler execute:METHOD_DATA_REQUEST parameter:datRequest target:self action:@selector(readUserGroupResponse:error:)];
    
}

- (void) showActivityView {
    if (self.activityView==nil) {
        self.activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
        [self.view addSubview:self.activityView];
        self.activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray ;
        self.activityView.hidesWhenStopped = YES;
    }
    // Center
    CGFloat x = UIScreen.mainScreen.applicationFrame.size.width/2;
    CGFloat y = UIScreen.mainScreen.applicationFrame.size.height/2;
    self.activityView.frame = CGRectMake(x, y, 0, 0);
    
    self.activityView.hidden = NO;
    [self.activityView startAnimating];
    [self.view bringSubviewToFront:self.activityView];
}



- (void)readUserGroupResponse:(ResponseBase *)response error:(NSError *)error{
    [self.activityView stopAnimating];
    fetchResult = ((DataResponse*)response).data;
    [self reloadMap];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if ([searchBar.text isEqualToString:@""]) {
        inSearch = false;
        [self readUserGroup];
    }
    else{
        inSearch = true;
        [self searchUserGroup:searchBar.text];
    }
    
}


- (void)reloadMap{
    [mapview removeAnnotations:[mapview annotations]];
    [mapview setShowsUserLocation:YES];
    
    CLLocation* mapCentre = [[CLLocation alloc] initWithLatitude:loc.latitude longitude:loc.longitude];
    
    if (fetchResult) {
        CLLocationDistance maxDist = 0;
        int rowCnt = ((NSNumber*)[fetchResult objectForKey:@"rowCnt"]).intValue;
        for (int i = 0; i < rowCnt; i++) {
            
            if (((NSNumber*)[fetchResult objectForKey:[NSString stringWithFormat:@"isMember%d", i ]]).intValue != 4) {
                float grouplag = ((NSNumber*)[fetchResult objectForKey:[NSString stringWithFormat:@"locationLag%d", i]]).floatValue;
                float grouplong = ((NSNumber*)[fetchResult objectForKey:[NSString stringWithFormat:@"locationLong%d", i]]).floatValue;
                
                CLLocation* groupLoc = [[CLLocation alloc] initWithLatitude:grouplag longitude:grouplong];
                CLLocationDistance distance = [mapCentre distanceFromLocation:groupLoc];
                if (distance > maxDist) {
                    maxDist = distance;
                }
                
                WUUbuddMapViewAnnotation* pin = [[WUUbuddMapViewAnnotation alloc] init];
                pin.title = [fetchResult objectForKey:[NSString stringWithFormat:@"topic%d", i]];
                pin.coordinate = groupLoc.coordinate;
                pin.groupIndex = i;
                [mapview addAnnotation:pin];
            
            }
           
        }
        if (loc.latitude != 999) {
            [mapview setRegion:MKCoordinateRegionMakeWithDistance(loc, maxDist * 2.5, maxDist * 2.5) animated:YES];
        }
    }
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if([annotation isKindOfClass: [MKUserLocation class]]){
        return nil;
    }
    MKAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"loc"];
    annotationView.canShowCallout = YES;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ([view.annotation isKindOfClass:[WUUbuddMapViewAnnotation class]]) {
        int i = ((WUUbuddMapViewAnnotation*)(view.annotation)).groupIndex;
        [self showGroupDetailForGroupid:[fetchResult objectForKey:[NSString stringWithFormat:@"c2CallID%d", i]]];
    }
}

-(void)updateLocationSearchGUI{
    distanceLabel.text = [NSString stringWithFormat:@"Within %dKm radius in", searchDist];
    locationLabel.text = locName;
}

-(void)searchUpdated{
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    if ([ud boolForKey:@"hasLocSearch"]) {
        loc.latitude = [ud floatForKey:@"searchLat"];
        loc.longitude = [ud floatForKey:@"searchLong"];
        locName = [ud stringForKey:@"searchLoc"];
        searchDist = [ud integerForKey:@"searchDist"];
    }
    else{
        loc.latitude = 999;
        loc.longitude = 999;
        locName = @"";
        searchDist = 2;
        [locationManager startUpdatingLocation];
    }
    [self updateLocationSearchGUI];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"searchLoc"]) {
        WUMapViewController *cvc = (WUMapViewController *)[segue destinationViewController];
        cvc.delegate = self;
    }
    else{
        [super prepareForSegue:segue sender:sender];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    NSLog(@"went here ...");
    
    [self.view endEditing:YES];
    return NO; // handle the touch
}

-(void)hidekeybord
{
    [self.view endEditing:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    if ([searchBar.text isEqualToString:@""]) {
        inSearch = false;
        [self readUserGroup];
    }
}

@end
