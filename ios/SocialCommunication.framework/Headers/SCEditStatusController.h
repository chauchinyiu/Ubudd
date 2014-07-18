//
//  SCEditStatusController.h
//  C2CallPhone
//
//  Created by Michael Knecht on 27.11.13.
//
//

#import <UIKit/UIKit.h>

@interface SCEditStatusController : UITableViewController<UITextViewDelegate>

@property(nonatomic, weak) IBOutlet UITextView      *statusTextView;
@property(nonatomic) BOOL                           saveStatusAsTemplate;

-(IBAction)save:(id)sender;
-(IBAction)close:(id)sender;

@end
