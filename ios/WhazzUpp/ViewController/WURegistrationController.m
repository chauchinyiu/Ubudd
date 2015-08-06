//
//  WURegistrationController.m
//  WhazzUpp
//
//  Created by Sahil.Khanna on 30/05/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import "WURegistrationController.h"
#import "RegisterUserDTO.h"
#import "WebserviceHandler.h"
#import "User.h"
#import "CommonMethods.h"
#import <sys/sysctl.h>
#import <SocialCommunication/EditCell.h>

@implementation WURegistrationController


#pragma mark - Other Methods
- (NSString *)countryCode {
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"country_code" ofType:@"json"]];
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSArray *countries = [[dictionary objectForKey:@"countries"] objectForKey:@"country"];

    NSArray *filtered = [countries filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name CONTAINS[cd] %@)", self.country.textLabel.text]];
    
    NSDictionary *country = filtered.firstObject;
    return [country objectForKey:@"code"];
}

#pragma mark - UIViewController Delegate
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.country.contentView sendSubviewToBack:countryBG];
    self.country.textLabel.backgroundColor = [UIColor clearColor];
    
    [self setRegisterDoneAction:^(void){
        [self performSegueWithIdentifier:@"VerificationSegue" sender:self];
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(hidekeybord)];
    [tap setDelegate:self];
    [self.view addGestureRecognizer:tap];
    
    [webView loadHTMLString:NSLocalizedString(@"webString", @"") baseURL:NULL];
    NSString* jsString = [[NSString alloc] initWithFormat: @"document.getElementsByTagName('div')[0].style.webkitTextSizeAdjust='%d%%'", 13 * 100 / 20];
    [webView stringByEvaluatingJavaScriptFromString:jsString];
}
- (void)viewWillAppear:(BOOL)animated {
    lblCountryCode.text = [self countryCode];
    self.navigationController.navigationBar.translucent = NO;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [self.phoneNumber.textContent becomeFirstResponder];
}

#pragma mark - Other Methods
- (NSString *)platform {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    return platform;
}

- (NSString *)model {
    NSString *platform = [self platform];
    
    if ([platform rangeOfString:@"iPhone1,1"].length)
        return @"iPhone 1G";
    else if ([platform rangeOfString:@"iPhone1,2"].length)
        return @"iPhone 3G";
    else if ([platform rangeOfString:@"iPhone2"].length)
        return @"iPhone 3GS";
    else if ([platform rangeOfString:@"iPhone3"].length)
        return @"iPhone 4";
    else if ([platform rangeOfString:@"iPhone4,1"].length)
        return @"iPhone 4S";
    else if ([platform rangeOfString:@"iPhone5,1"].length || [platform rangeOfString:@"iPhone5,2"].length)
        return @"iPhone 5";
    else if ([platform rangeOfString:@"iPhone5,3"].length || [platform rangeOfString:@"iPhone5,4"].length)
        return @"iPhone 5c";
    else if ([platform rangeOfString:@"iPhone6"].length)
        return @"iPhone 5s";
    
    else if ([platform rangeOfString:@"iPod1"].length)
        return @"iPod Touch 1G";
    else if ([platform rangeOfString:@"iPod2"].length)
        return @"iPod Touch 2G";
    else if ([platform rangeOfString:@"iPod3"].length)
        return @"iPod Touch 3G";
    else if ([platform rangeOfString:@"iPod4"].length)
        return @"iPod Touch 4G";
    
    else if ([platform rangeOfString:@"iPad1"].length)
        return @"iPad 1";
    else if ([platform rangeOfString:@"iPad2"].length)
        return @"iPad 2";
    else if ([platform rangeOfString:@"iPad3,1"].length)
        return @"iPad 3";
    else if ([platform rangeOfString:@"iPad3,4"].length)
        return @"iPad 4";
    else if ([platform rangeOfString:@"iPad4,1"].length || [platform rangeOfString:@"iPad4,2"].length)
        return @"iPad Air";
    else if ([platform rangeOfString:@"iPad4,4"].length || [platform rangeOfString:@"iPad4,5"].length || [platform rangeOfString:@"iPad2,5"].length)
        return @"iPad Mini";
    
    else
        return @"Simulator";
}

#pragma mark - Webservice Request
- (void)registerUserRequest:(RegisterUserDTO *)registerUserDTO {
    [CommonMethods showLoading:YES title:nil message: NSLocalizedString(@"Loading", @"")];
    
    WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
    [serviceHandler execute:METHOD__REGISTER parameter:registerUserDTO target:self action:@selector(registerUserResponse:error:)];
}

#pragma mark - Webservice Response
- (void)registerUserResponse:(ResponseBase *)response error:(NSError *)error {
    [CommonMethods showLoading:NO title:nil message:nil];
    
    User *user = (User *)response;
    
    if (error){
        [CommonMethods showAlertWithTitle:NSLocalizedString(@"Registration Error", @"") message:[error localizedDescription] delegate:nil];
        [btnDone setEnabled:YES];
    }
    else if (user.errorCode){
        [CommonMethods showAlertWithTitle:NSLocalizedString(@"Registration Error", @"") message:user.message delegate:nil];
        [btnDone setEnabled:YES];

    }
    else if (!user.email || !user.password){
        [CommonMethods showAlertWithTitle:NSLocalizedString(@"Registration Error", @"") message:@"Failed to register. Please try again" delegate:nil];
        [btnDone setEnabled:YES];        
    }
    else {
        self.firstName.text = @" ";
        self.lastName.text = @" ";
        
        self.email.textContent.text = user.email;
        self.password1.textContent.text = user.password;
        self.password2.textContent.text = user.password;

        [self registerUser:self];
    }
}

#pragma mark - UIButton Action
- (IBAction)btnDoneTapped {
    [btnDone setEnabled:NO];
    self.phoneNumber.textContent.text = [CommonMethods trimText:self.phoneNumber.textContent.text];
    
    if (self.phoneNumber.textContent.text.length > 0) {
        //add area code if does not have one

        CLGeocoder *geocoder;
        geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:self.country.textLabel.text completionHandler:^(NSArray *placemarks, NSError *error){
            NSArray* result = [[NSArray alloc] initWithArray:placemarks copyItems:YES];
            if (result.count > 0) {
                CLPlacemark* placemark = (CLPlacemark*)[result objectAtIndex:0];
                NSData *encodedRegion = [NSKeyedArchiver archivedDataWithRootObject:placemark.region];
                [[NSUserDefaults standardUserDefaults] setObject:encodedRegion forKey:@"location"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }];

        
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithString:lblCountryCode.text] forKey:@"countryCode"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithString:self.phoneNumber.textContent.text] forKey:@"phoneNo"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@%@", lblCountryCode.text, self.phoneNumber.textContent.text] forKey:@"msidn"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        RegisterUserDTO *registerUserDTO = [[RegisterUserDTO alloc] init];
        registerUserDTO.msisdn = [NSString stringWithFormat:@"%@%@", lblCountryCode.text, self.phoneNumber.textContent.text];
        registerUserDTO.model = [self model];
        registerUserDTO.brand = @"Apple";
        registerUserDTO.uid = [UIDevice currentDevice].identifierForVendor.UUIDString;
        registerUserDTO.os = [NSString stringWithFormat:@"iOS %@", [UIDevice currentDevice].systemVersion];
        registerUserDTO.countryCode = lblCountryCode.text;
        registerUserDTO.phoneNo = self.phoneNumber.textContent.text;
        
        [self registerUserRequest:registerUserDTO];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"VerificationSegue"]) {
    }
    else{
        [super prepareForSegue:segue sender:sender];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    NSLog(@"went here ...");
    
    if((![touch.view isKindOfClass:[UITextView class]])
       && (![touch.view isKindOfClass:[UITextField class]])){
        [self.view endEditing:YES];
    }
    return NO; // handle the touch
}

-(void)hidekeybord
{
    [self.view endEditing:YES];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        if ([request.URL.absoluteString  hasSuffix:@"a"]) {
            [self performSegueWithIdentifier:@"privacypolicy" sender:self];
            
        }
        else{
            [self performSegueWithIdentifier:@"termsandconditions" sender:self];

        
        }
    }
    return YES;
}

@end