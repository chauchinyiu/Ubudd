//
//  WUUbuddMapViewController.h
//  UpBrink
//
//  Created by Ming Kei Wong on 23/10/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import <SocialCommunication/SocialCommunication.h>
#import "WUMapViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface WUUbuddMapViewAnnotation : MKPointAnnotation
@property int groupIndex;
@end

@interface WUUbuddMapViewController : UIViewController<UISearchBarDelegate, UISearchControllerDelegate, UISearchDisplayDelegate, WUMapControllerDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate, MKMapViewDelegate>

@property(nonatomic, weak) IBOutlet UILabel *locationLabel, *distanceLabel;
@property(nonatomic, weak) IBOutlet MKMapView* mapview;
@property(nonatomic, weak) id parentController;

-(void)useResult:(NSDictionary*) result;

@end
