//
//  WURegistrationController1.h
//  UpBrink
//
//  Created by Sahil.Khanna on 30/05/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import <SocialCommunication/SocialCommunication.h>

@interface WURegistrationController : SCRegistrationController<UIGestureRecognizerDelegate, UIWebViewDelegate> {
    IBOutlet UILabel *lblCountryCode;
    IBOutlet UIImageView *countryBG;
    IBOutlet UIBarButtonItem *btnDone;
    IBOutlet UIWebView *webView;
    IBOutlet UILabel* topMessage;
    IBOutlet UILabel* lblCountryName;
}

- (IBAction)btnDoneTapped;

@end
