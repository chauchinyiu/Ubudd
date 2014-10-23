//
//  WUMapViewController.h
//  WhazzUpp
//
//  Created by Ming Kei Wong on 15/10/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "WULocationSearchController.h"

@protocol WUMapControllerDelegate <NSObject>
@required
-(void)searchUpdated;
@end


@interface WUMapViewController : UITableViewController<WULocationSelectControllerDelegate, MKMapViewDelegate>
@property(nonatomic, weak) IBOutlet MKMapView* mapview;
@property(nonatomic, weak) IBOutlet UILabel* lblLocName;
@property(nonatomic,assign)id<WUMapControllerDelegate>delegate;

@end
