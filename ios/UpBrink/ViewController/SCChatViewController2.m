//
//  SCChatController.m
//  SimplePhone
//
//  Created by Michael Knecht on 21.04.13.
//  Copyright 2013,2014 C2Call GmbH. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <AddressBookUI/AddressBookUI.h>
#import <CoreLocation/CoreLocation.h>
#import <SocialCommunication/UIViewController+SCCustomViewController.h>

#import "SCChatViewController2.h"
#import <SocialCommunication/SCBoardController.h>
#import <SocialCommunication/SCFlexibleToolbarView.h>
#import <SocialCommunication/SCPopupMenu.h>

#import <SocialCommunication/AlertUtil.h>
#import <SocialCommunication/C2CallPhone.h>
#import <SocialCommunication/SIPPhone.h>
#import <SocialCommunication/SCUserProfile.h>
#import <SocialCommunication/SCDataManager.h>

#import <SocialCommunication/MOC2CallUser.h>

#import <SocialCommunication/IOS.h>
#import <SocialCommunication/SCWaitIndicatorController.h>
#import <SocialCommunication/C2TapImageView.h>


#import <SocialCommunication/debug.h>

@interface SCChatViewController2 ()<UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ABPeoplePickerNavigationControllerDelegate> {
    
    NSTimeInterval      lastTypeEvent, lastTypeEventReceived;
    
    CGFloat             resizeOffset, minToolbarHeight;
    CGFloat             currentKeyboardSize;
    
    BOOL                isGroupChat, isSMS, isKeyboard, hasMaxToolbarSize, hasTabBar;
}

@end

@implementation SCChatViewController2
@synthesize chatboard, targetUserid, toolbarView, chatInput, submitButton;
@synthesize chatInputBorderColor, chatInputBorderWidth, chatInputCornerRadius, startEdit, dontShowCallEvents, toolbarBottomContraint;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.chatInputBorderWidth = 1.;
        self.chatInputCornerRadius = 5.;
        self.chatInputBorderColor = [UIColor grayColor];
        self.dontShowCallEvents = YES;
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.chatInputBorderWidth = 1.;
        self.chatInputCornerRadius = 5.;
        self.chatInputBorderColor = [UIColor grayColor];
        self.dontShowCallEvents = YES;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(BOOL) isPhoneNumber:(NSString *) uid
{
    if ([uid hasPrefix:@"+"] && [uid rangeOfString:@"@"].location == NSNotFound) {
        return YES;
    }
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    for (UIViewController *vc in self.childViewControllers) {
        if ([vc isKindOfClass:[SCBoardController class]]) {
            self.chatboard = (SCBoardController *) vc;
            self.chatboard.dontShowCallEvents = self.dontShowCallEvents;
        }
    }
    
    [self addCloseButtonIfNeeded];
    
    if (self.chatInputBorderWidth > 0.) {
        CALayer *l = self.chatInput.layer;
        l.borderWidth = self.chatInputBorderWidth;
        l.cornerRadius = self.chatInputCornerRadius;
        l.borderColor = [self.chatInputBorderColor CGColor];
    }
    
    CGRect tvframe = chatInput.frame;
    CGRect svframe = toolbarView.toolbarView.frame;
    
    if ([self.chatInput respondsToSelector:@selector(textContainer)]) {
        self.chatInput.textContainer.heightTracksTextView = YES;
    }
    
    resizeOffset = svframe.size.height - tvframe.size.height - 3;
    minToolbarHeight = svframe.size.height;
    
    DLog(@"minToolbarHeight : %f / %f", minToolbarHeight, resizeOffset);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"UIKeyboardWillShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"UIKeyboardDidShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"UIKeyboardWillHideNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"UIKeyboardDidHideNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"SIPHandler:TypingEvent" object:nil];
    
    NSString *name = [[C2CallPhone currentPhone] nameForUserid:self.targetUserid];
    DLog(@"Name : %@ / %@", name, self.targetUserid);
    
    self.title = name;
    
    isGroupChat = NO;

    isSMS = NO;
    if ([SCDataManager instance].isDataInitialized) {
        MOC2CallUser *user = [[SCDataManager instance] userForUserid:self.targetUserid];
        isGroupChat = [user.userType intValue] == 2;
    }
    
    if (startEdit) {
        [self.chatInput becomeFirstResponder];
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    hasTabBar = !self.tabBarController.tabBar.isHidden;
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.chatInput isFirstResponder]) {
        [self.chatInput resignFirstResponder];
    }
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    DLog(@"willRotateToInterfaceOrientation : %d", interfaceOrientation);
    
    CGRect frame1 = chatInput.frame;
    
    if (frame1.size.width == 0)
        return;
    
    CGSize maximumLabelSize;
    if (interfaceOrientation == UIDeviceOrientationLandscapeLeft || interfaceOrientation == UIDeviceOrientationLandscapeRight) {
        maximumLabelSize = [@"\n \n \n \n " sizeWithFont:chatInput.font constrainedToSize:CGSizeMake(frame1.size.width - 16, 999.)];
        maximumLabelSize.width = frame1.size.width - 16;
        //maximumLabelSize = CGSizeMake(frame1.size.width - 16,64);
    } else {
        maximumLabelSize = [@"\n \n \n \n \n \n \n " sizeWithFont:chatInput.font constrainedToSize:CGSizeMake(frame1.size.width - 16, 999.)];
        maximumLabelSize.width = frame1.size.width - 16;
        //maximumLabelSize = CGSizeMake(frame1.size.width - 16,128);
    }
    
    NSString *text = chatInput.text;
    if ([text hasSuffix:@"\n"]) {
        text = [NSString stringWithFormat:@"%@ ", text];
    }
    [self resizeToolbar:text textView:chatInput maxLabelSize:maximumLabelSize];
    
    return;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TextView Delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    @try {
        if (!isGroupChat && !isSMS) {
            if (CFAbsoluteTimeGetCurrent() - lastTypeEvent > 2.0) {
                lastTypeEvent = CFAbsoluteTimeGetCurrent();
                [[SIPPhone currentPhone] submitTypingEventToUser:self.targetUserid];
            }
        }
        
        NSString *newtext = nil;
        
        if ([text isEqualToString:@"\n"]) {
            newtext = [textView.text stringByReplacingCharactersInRange:range withString:text];
        } else {
            newtext = [textView.text stringByReplacingCharactersInRange:range withString:text];
        }
        
        if ([newtext hasSuffix:@"\n"]) {
            newtext = [NSString stringWithFormat:@"%@ ", newtext];
        }
        
        
        if ([newtext length] > 1500) {
            return NO;
        }
        
        if ([newtext length] > 0) {
            [[NSUserDefaults standardUserDefaults] setObject:newtext forKey:[NSString stringWithFormat:@"text-%@", self.targetUserid]];
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"text-%@", self.targetUserid]];
        }
        
        CGRect frame1 = textView.frame;
        CGSize maximumLabelSize;
        
        CGFloat inset = 16;
        if ([IOS iosVersion] >= 7.) {
            UIEdgeInsets edges = self.chatInput.textContainerInset;
            inset = edges.left + edges.right;
        }
        
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
            maximumLabelSize = [@"\n \n \n \n " sizeWithFont:textView.font constrainedToSize:CGSizeMake(frame1.size.width - inset, 999.)];
            maximumLabelSize.width = frame1.size.width - inset;
            //maximumLabelSize = CGSizeMake(frame1.size.width - 16,64);
        } else {
            maximumLabelSize = [@"\n \n \n \n \n \n \n " sizeWithFont:textView.font constrainedToSize:CGSizeMake(frame1.size.width - inset, 999.)];
            maximumLabelSize.width = frame1.size.width - inset;
            //maximumLabelSize = CGSizeMake(frame1.size.width - 16,128);
        }
        
        [self resizeToolbar:newtext textView:textView maxLabelSize:maximumLabelSize];
    }
    @catch (NSException *exception) {
    }
    
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    
    if(![textView.text hasSuffix:@"\n"] && hasMaxToolbarSize && [IOS iosVersion] >= 7.) {
        int pos = textView.selectedRange.location;
        int len = textView.text.length;
        NSString *temp = [NSString stringWithFormat:@"%@\n", textView.text];
        textView.text = temp;
        NSRange selected = textView.selectedRange;
        if(pos == len) {
            selected.location -= 1;
            textView.selectedRange = selected;
        } else {
            selected.location = pos;
            textView.selectedRange = selected;
        }
    }
    
    NSRange range = textView.selectedRange;
    DLog(@"scrollRangeToVisible: %d/%d", range.location, range.length);
    [textView scrollRangeToVisible:range];
    
}

-(void) resizeToolbar:(NSString *) newtext textView:(UITextView *)textView maxLabelSize:(CGSize) maximumLabelSize
{
    CGSize expectedTextSize = [newtext sizeWithFont:textView.font
                                  constrainedToSize:maximumLabelSize];
    
    CGFloat sz = expectedTextSize.height;
    sz += 12;
    
    if (sz < maximumLabelSize.height) {
        textView.scrollEnabled = YES;
    } else {
        textView.scrollEnabled = YES;
    }
    
    
    sz += resizeOffset;
    
    int maxSZ = maximumLabelSize.height + resizeOffset;
    if (sz >= maxSZ) {
        sz = maxSZ;
        hasMaxToolbarSize = YES;
    } else {
        hasMaxToolbarSize = NO;
    }
    
    if (sz < minToolbarHeight)
        sz = minToolbarHeight;
    
    [self.toolbarView resizeToolbar:sz];
}

-(void) resizeToolbar:(NSString *) newtext{
    CGRect frame1 = chatInput.frame;
    NSString* useText;
    if ([newtext isEqualToString:@""]) {
        useText = @"A";
    }
    else{
        useText = newtext;
    }
    CGSize maximumLabelSize = [@"\n \n \n \n \n \n \n " sizeWithFont:chatInput.font constrainedToSize:CGSizeMake(frame1.size.width - 16, 999.)];
    maximumLabelSize.width = frame1.size.width - 16;
    [self resizeToolbar:useText textView:chatInput maxLabelSize:maximumLabelSize];

}


-(void) resetTextInput
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.chatInput.text = nil;
        [self.toolbarView resizeToolbar:minToolbarHeight];
    });
}

#pragma mark Notification Handling

-(CGFloat) keyboardSize:(NSNotification *) notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect appFrame = [UIApplication sharedApplication].keyWindow.frame;
    CGFloat w = appFrame.size.width;
    if (w > appFrame.size.height)
        w = appFrame.size.height;
    
    //BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    CGFloat height = keyboardFrame.size.height;//isPortrait ? keyboardFrame.size.height : keyboardFrame.size.width;
    if (height == w) {
        height = keyboardFrame.size.width;
    }
    
    return height;
}

-(void) handleNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"UIKeyboardWillShowNotification"]) {
        CGFloat keyboardSize = [self keyboardSize:notification];
        
        if (keyboardSize == currentKeyboardSize)
            return;
        
        CGRect frame = self.toolbarView.frame;
        //DLog(@"Frame : %f / %f ", frame.size.width, frame.size.height);
        //DLog(@"Keyboard : %f / %f ", keyboardSize.width, keyboardSize.height);
        
        CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
        if (!hasTabBar) {
            tabBarHeight = 0.;
        }
        
        CGFloat kbNewHeight = keyboardSize - tabBarHeight;
        CGFloat kbCurrentHeight = currentKeyboardSize - tabBarHeight;
        CGFloat diff = (currentKeyboardSize > 0)? kbNewHeight - kbCurrentHeight : kbNewHeight;
        
        frame.size.height -= diff;
        
        currentKeyboardSize = keyboardSize;
        
        
        if (self.toolbarBottomContraint) {
            DLog(@"keyboardWillShow : %f", diff);
            self.toolbarBottomContraint.constant += diff;
            //[self.toolbarView setNeedsUpdateConstraints];
            [self.toolbarView layoutIfNeeded];
        }
        else
        {
            self.toolbarView.frame = frame;
        }
         
        [self.chatboard keywordShown:notification];
    }
    if ([[notification name] isEqualToString:@"UIKeyboardWillHideNotification"]) {
        if (currentKeyboardSize == 0)
            return;
        
        isKeyboard = NO;
        
        CGRect frame = self.toolbarView.frame;
        CGFloat keyboardSize = [self keyboardSize:notification];
        CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
        if (!hasTabBar) {
            tabBarHeight = 0.;
        }
        
        CGFloat kbHeight = keyboardSize - tabBarHeight;
        frame.size.height = self.view.frame.size.height;
        
        //DLog(@"Frame : %f / %f ", frame.size.width, frame.size.height);
        //DLog(@"Keyboard : %f / %f ", keyboardSize.width, keyboardSize.height);
        
        if (self.toolbarBottomContraint) {
            DLog(@"keyboardWillHide : %f", kbHeight);
            self.toolbarBottomContraint.constant -= kbHeight;
            [self.toolbarView setNeedsUpdateConstraints];
             [self.toolbarView layoutIfNeeded];

        } else {
              self.toolbarView.frame = frame;

        }
    }
    
    if ([[notification name] isEqualToString:@"UIKeyboardDidShowNotification"]) {
        if (isKeyboard)
            return;
        
        isKeyboard = YES;
    }
    
    if ([[notification name] isEqualToString:@"UIKeyboardDidHideNotification"]) {
        currentKeyboardSize = 0;
    }
    
    if ([[notification name] isEqualToString:@"SIPHandler:TypingEvent"] && [[notification object] isEqualToString:self.targetUserid]) {
        [self handleTypingEvent:self.targetUserid];
    }
    
    if ([[notification name] isEqualToString:@"PriceInfoEvent"] && [[[notification userInfo] objectForKey:@"Number"] isEqualToString:self.targetUserid] && [[[notification userInfo] objectForKey:@"sms"] boolValue]) {
        DLog(@"Price : %@", [[notification userInfo] objectForKey:@"PriceString"]);
        NSString *smsPriceInfo = [[notification userInfo] objectForKey:@"PriceString"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateSMSPriceInfo:smsPriceInfo];
        });
    }
    
}


-(void) handleTypingEvent:(NSString *) fromUserid
{
    if ([fromUserid isEqualToString:self.targetUserid]) {
        lastTypeEventReceived = CFAbsoluteTimeGetCurrent();
        self.navigationItem.prompt = NSLocalizedString(@"is typing", "TypingEvent Title");
        double delayInSeconds = 2.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (CFAbsoluteTimeGetCurrent() - lastTypeEventReceived > 2.4) {
                self.navigationItem.prompt = nil;
            }
        });
    }
}

#pragma mark Segue Handling

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self customPrepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:@"SCBoardControllerSegue"] || [segue.destinationViewController isKindOfClass:[SCBoardController class]]) {
        UIViewController *vc = segue.destinationViewController;
        SCBoardController *smc = nil;
        if ([vc isKindOfClass:[UINavigationController class]]) {
            smc = (SCBoardController *)((UINavigationController *)vc).topViewController;
        }
        
        if ([vc isKindOfClass:[SCBoardController class]]) {
            smc = (SCBoardController *)vc;
        }
        smc.targetUserid = targetUserid;
        smc.dontShowCallEvents = self.dontShowCallEvents;
    }
}



-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    // Get the selected image.
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeMovie]) {
        NSURL *mediaUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        
        DLog(@"mediaUrl : %@", [mediaUrl absoluteString]);
        
        @autoreleasepool {
            SCWaitIndicatorController *pleaseWait = [SCWaitIndicatorController controllerWithTitle:NSLocalizedString(@"Exporting Video", @"Exporting Video...") andWaitMessage:nil];
            pleaseWait.autoHide = NO;
            [pleaseWait show:[[UIApplication sharedApplication] keyWindow]];
            
            [[C2CallPhone currentPhone] submitVideo:mediaUrl withMessage:nil toTarget:self.targetUserid withCompletionHandler:^(BOOL success, NSString *richMediaKey, NSError *error) {
                [pleaseWait hide];
                [picker dismissViewControllerAnimated:YES completion:NULL];
                
            }];
        }
    } else {
        UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        SCWaitIndicatorController *pleaseWait = [SCWaitIndicatorController controllerWithTitle:NSLocalizedString(@"Exporting Image", @"Exporting Image...") andWaitMessage:nil];
        [pleaseWait show:[[UIApplication sharedApplication] keyWindow]];
        
        [[C2CallPhone currentPhone] submitImage:originalImage withQuality:UIImagePickerControllerQualityTypeMedium andMessage:nil toTarget:self.targetUserid withCompletionHandler:^(BOOL success, NSString *richMediaKey, NSError *error) {
            [pleaseWait hide];
            [picker dismissViewControllerAnimated:YES completion:NULL];
        }];
    }
    
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark people picker

- (void)peoplePickerNavigationControllerDidCancel:
(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
    [[C2CallPhone currentPhone] submitVCard:person withMessage:nil toTarget:self.targetUserid withCompletionHandler:^(BOOL success, NSString *richMediaKey, NSError *error) {
        
        [self dismissViewControllerAnimated:YES completion:NULL];
    }];
    
    return NO;
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
                         didSelectPerson:(ABRecordRef)person
{
    [self peoplePickerNavigationController:peoplePicker shouldContinueAfterSelectingPerson:person];
}


- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier{
    return NO;
}

#pragma mark Actions



- (IBAction)showPicker:(id)sender
{
    ABPeoplePickerNavigationController *picker =
    [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

-(IBAction) submit:(id) sender;
{
    NSString *text = [chatInput.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (!text || [text length] == 0) {
        [AlertUtil showPleaseEnterText];
        return;
    }
    
    [self resetTextInput];
    [[SIPPhone currentPhone] submitMessage:text toUser:self.targetUserid preferEncryption:self.encryptMessageButton.selected];
    
    if ([self.chatInput isFirstResponder]) {
        [self.chatInput resignFirstResponder];
    }
    
}

-(IBAction)hideKeyboard:(id)sender
{
    if ([self.chatInput isFirstResponder]) {
        [self.chatInput resignFirstResponder];
    }
}

-(IBAction) close:(id) sender
{
    UIViewController *vc = [self.navigationController popViewControllerAnimated:YES];
    if (!vc)
        [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
