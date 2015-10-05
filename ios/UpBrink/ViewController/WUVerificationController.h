//
//  WUVerificationController.h
//  UpBrink
//
//  Created by Sahil.Khanna on 13/06/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WUVerificationController : UITableViewController<UIGestureRecognizerDelegate> {
    IBOutlet UITextField *txtCode;
    IBOutlet UILabel *lblNote;
    IBOutlet UIButton *btnResend;
}

- (IBAction)btnResendTapped;
@end