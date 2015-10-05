//
//  WUInterestViewController.h
//  UpBrink
//
//  Created by Ming Kei Wong on 12/9/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WUInterestViewControllerDelegate <NSObject>
@required
-(void)selectedInerestID:(int) i withName:(NSString*) name;
@end

@interface WUInterestCell : UITableViewCell
@property(nonatomic, weak) IBOutlet UILabel     *nameLabel;
@end



@interface WUInterestViewController : UITableViewController
@property(nonatomic,assign)id<WUInterestViewControllerDelegate>delegate;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@end
