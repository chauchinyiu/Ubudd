//
//  WUUbuddListController.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 27/9/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "WUUbuddListController.h"
#import <SocialCommunication/UIViewController+SCCustomViewController.h>
#import <SocialCommunication/debug.h>
#import "DBHandler.h"
#import "WUBoardController.h"
#import "DataRequest.h"
#import "WebserviceHandler.h"
#import "ResponseBase.h"
#import "DataResponse.h"
#import <MapKit/MapKit.h>
#import "WUUbuddMapViewController.h"
#import "WUAddGroupController.h"
#import "CommonMethods.h"

@implementation WUUbuddListCell

@synthesize nameLabel, statusLabel, hostLabel, memberLabel;


@end

@interface WUUbuddListController (){
    CGFloat favoritesCellHeight;
    NSDictionary* fetchResult;
    BOOL inSearch;
    NSString* searchStr;
    id joinCell;
    CLLocationCoordinate2D loc;
    NSString* locName;
    int searchDist;
    
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    
}
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation WUUbuddListController
@synthesize locationLabel, distanceLabel;


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

    //reset search
    inSearch = NO;
    searchStr = @"";
    locName = @"";
    
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:NO forKey:@"hasLocSearch"];
    [ud synchronize];
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"WUUbuddListCell"];
    favoritesCellHeight = cell.frame.size.height;
    
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

             NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
             [ud setBool:YES forKey:@"hasLocSearch"];
             [ud setFloat:loc.latitude forKey:@"searchLat"];
             [ud setFloat:loc.longitude forKey:@"searchLong"];
             [ud setObject:locName forKey:@"searchLoc"];
             [ud setInteger:searchDist forKey:@"searchDist"];
             [ud synchronize];
             
             [self updateLocationSearchGUI];
         }
     }];
    
}


- (void)viewDidAppear:(BOOL)animated {
    if (inSearch){
        [self searchUserGroup:searchStr];
    }
    else{
        [self readUserGroup];
    }
    
    [self.tableView reloadData];
    [self searchUpdated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self.tableView bringSubviewToFront:self.activityView];
}



- (void)readUserGroupResponse:(ResponseBase *)response error:(NSError *)error{
    [self.activityView stopAnimating];
    fetchResult = ((DataResponse*)response).data;
    [self.tableView reloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (fetchResult) {
        return ((NSNumber*)[fetchResult objectForKey:@"rowCnt"]).intValue;
    }
    else{
        return 0;
    }
}



-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 105;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WUUbuddListCell *favocell = (WUUbuddListCell *)[self.tableView dequeueReusableCellWithIdentifier:@"WUUbuddListCell"];
    
    SCGroup *group = [[SCGroup alloc] initWithGroupid:[fetchResult objectForKey:[NSString stringWithFormat:@"c2CallID%d", indexPath.row ]]];
    
    favocell.nameLabel.font = [CommonMethods getStdFontType:0];
    favocell.statusLabel.font = [CommonMethods getStdFontType:2];
    favocell.hostHeaderLabel.font = [CommonMethods getStdFontType:2];
    favocell.memberHeaderLabel.font = [CommonMethods getStdFontType:2];
    favocell.hostLabel.font = [CommonMethods getStdFontType:2];
    favocell.hostLabel.font = [CommonMethods getStdFontType:2];
            
    favocell.nameLabel.text = [fetchResult objectForKey:[NSString stringWithFormat:@"topic%d", indexPath.row]];
    favocell.statusLabel.text = [fetchResult objectForKey:[NSString stringWithFormat:@"topicDescription%d", indexPath.row]];
    favocell.hostLabel.text = [fetchResult objectForKey:[NSString stringWithFormat:@"userName%d", indexPath.row]];
    NSNumber* memberCnt = [fetchResult objectForKey:[NSString stringWithFormat:@"memberCnt%d", indexPath.row]];
    favocell.memberLabel.text = [NSString stringWithFormat:@"%d OF 200", memberCnt.intValue + 1];
    
    
    UIImage *image = [[C2CallPhone currentPhone] userimageForUserid:group.groupid];
    
    if (image) {
        favocell.userImg.image = image;
    }
    else{
        favocell.userImg.image = [UIImage imageNamed:@"btn_ico_avatar_group2.png"];
    }
    
    return favocell;
}



-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"didSelectRowAtIndexPath : %d / %d", indexPath.section, indexPath.row);
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    
    [self showGroupDetailForGroupid:[fetchResult objectForKey:[NSString stringWithFormat:@"c2CallID%d", indexPath.row]]];
    
    
}

-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"accessoryButtonTappedForRowWithIndexPath : %d / %d", indexPath.section, indexPath.row);
    
    [self showGroupDetailForGroupid:[fetchResult objectForKey:[NSString stringWithFormat:@"c2CallID%d", indexPath.row]]];
}

-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
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
    else if ([[segue identifier] isEqualToString:@"SwitchMap"]) {
        WUUbuddMapViewController *cvc = (WUUbuddMapViewController *)[segue destinationViewController];
        cvc.parentController = self;
        [cvc useResult:fetchResult];
    }
    else if ([segue.destinationViewController isKindOfClass:[WUAddGroupController class]]) {
        WUAddGroupController *addGroupController = (WUAddGroupController *)segue.destinationViewController;
        addGroupController.parentController = self;
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

-(void)useResult:(NSDictionary*) result{
    fetchResult = [NSDictionary dictionaryWithDictionary:result];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    if ([searchBar.text isEqualToString:@""]) {
        inSearch = false;
        [self readUserGroup];
    }
}

@end

