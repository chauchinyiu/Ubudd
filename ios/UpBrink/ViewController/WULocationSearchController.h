//
//  WULocationSearchController.h
//  UpBrink
//
//  Created by Ming Kei Wong on 19/9/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@protocol WULocationSelectControllerDelegate <NSObject>
@required
-(void)selectedLocationWithCoord:(CLLocationCoordinate2D)coord typedName:(NSString*)typedname;
@end

@interface WULocationCell : UITableViewCell
@property(nonatomic, weak) IBOutlet UILabel *nameLabel;
@end

@interface WULocationSearchController : UITableViewController<CLLocationManagerDelegate>

@property(nonatomic,assign)id<WULocationSelectControllerDelegate>delegate;
@property (strong, nonatomic) CLGeocoder *geocoder;

@end
