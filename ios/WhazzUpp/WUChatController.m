//
//  WUChatController.m
//  WhazzUpp
//
//  Created by Michael Knecht on 02.06.13.
//  Copyright (c) 2013 C2Call GmbH. All rights reserved.
//

#import <SocialCommunication/UIViewController+SCCustomViewController.h>
#import "WUChatController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Helper/CommonMethods.h"
#import "ResponseHandler.h"
#import "WUFriendDetailController.h"

//#define kRichMessage_ChoosePhotoOrVideo @"Choose Photo or Video"
#define kRichMessage_TakePhotoOrVideo @"Take Photo or Video"
//#define kRichMessage_SubmitLocation @"Submit Location"
//#define kRichMessage_SubmitVoiceMessage @"Submit Voice Message"
//#define kRichMessage_SendContact @"Send Contact"


typedef enum : NSUInteger {
    Action_Call,
    Action_RichMessage
} ChatAction;

@interface WUChatController (){
    BOOL isRecording;
}

@property (nonatomic, assign) CFAbsoluteTime lastTypeEventReceived;

@end

@implementation WUChatController
@synthesize audioView;

#pragma mark - UIButton Action
- (IBAction)btnCallTapped {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:nil otherButtonTitles:@"Voice Call", @"Video Call", nil];
    actionSheet.tag = Action_Call;
    [actionSheet showInView:self.view];
    
//    [[C2CallPhone currentPhone] callVoIP:self.targetUserid];
}

- (IBAction)btnRichMessageTapped:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select an option", @"") delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    actionSheet.tag = Action_RichMessage;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Choose Photo or Video", @"")];
    }
    
    if ([SIPPhone currentPhone].callStatus == SCCallStatusNone) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [actionSheet addButtonWithTitle:kRichMessage_TakePhotoOrVideo];
        }
    }
    
    if ([CLLocationManager locationServicesEnabled]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Share Location", @"")];
    }
    
    /*
    if ([SIPPhone currentPhone].callStatus == SCCallStatusNone) {
        if ([[AVAudioSession sharedInstance] inputIsAvailable]) {
            [actionSheet addButtonWithTitle:kRichMessage_SubmitVoiceMessage];
        }
    }
    */
    if ([CommonMethods osVersion] >= 5.0) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Send Contact", @"")];
    }

    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
    
    [actionSheet showInView:self.view];
}

- (IBAction)btnSendTapped:(id)sender{
    [self submit:sender];
}

-(void)viewWillAppear:(BOOL)animated{
    NSMutableArray* friends = [ResponseHandler instance].friendList;
    for (int i = 0; i < friends.count; i++) {
        WUAccount* a = [friends objectAtIndex:i];
        if([a.c2CallID isEqualToString:self.targetUserid] && a.name != nil){
            [self.titleButton setTitle:a.name forState:UIControlStateNormal];
            UIBarButtonItem *newBackButton =
            [[UIBarButtonItem alloc] initWithTitle:a.name
                                             style:UIBarButtonItemStyleBordered
                                            target:nil
                                            action:nil];
            [[self navigationItem] setBackBarButtonItem:newBackButton];
            
        }
    }
    NSMutableArray* groups = [ResponseHandler instance].groupList;
    for (int i = 0; i < groups.count; i++) {
        WUAccount* a = [groups objectAtIndex:i];
        if([a.c2CallID isEqualToString:self.targetUserid] && a.name != nil){
            [self.titleButton setTitle:a.name forState:UIControlStateNormal];
            UIBarButtonItem *newBackButton =
            [[UIBarButtonItem alloc] initWithTitle:a.name
                                             style:UIBarButtonItemStyleBordered
                                            target:nil
                                            action:nil];
            [[self navigationItem] setBackBarButtonItem:newBackButton];
            
        }
    }
    
}

#pragma mark - UIViewController Delegate
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tabBarController.tabBar.hidden = YES;
    [self.submitButton setImage:nil forState:UIControlStateHighlighted];
    

    MOC2CallUser *user = [[SCDataManager instance] userForUserid:self.targetUserid];
    if(user){
        [self.titleButton setTitle:user.displayName forState:UIControlStateNormal];
    }
    UIImage *image = [[C2CallPhone currentPhone] userimageForUserid:self.targetUserid];
    
    if (image) {
        [self.imageBtn setImage:image forState:UIControlStateNormal];
    }
    
    self.chatInput.font = [UIFont fontWithName:self.chatInput.font.fontName size:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline].pointSize * 2 - 14];

    [self.submitButton setHidden:YES];
    [self.recordButton setHidden:NO];
    [self.lblRecording setHidden:YES];
    isRecording = NO;
}

- (IBAction)btnImageTapped:(id)sender{
    [self showUserImageForUserid:self.targetUserid];
}



#pragma mark - ChatController Methods
-(IBAction)openProfile:(id)sender
{
    MOC2CallUser *user = [[SCDataManager instance] userForUserid:self.targetUserid];
    if ([user.userType intValue] == 2) {
        [self showGroupDetailForGroupid:self.targetUserid];
    } else {
        NSMutableArray* friendList = [[ResponseHandler instance] friendList];
        for (int i = 0; i < friendList.count; i++) {
            WUAccount* a = [friendList objectAtIndex:i];
            if ([a.c2CallID isEqualToString:self.targetUserid]) {
                [WUFriendDetailController setPhoneNo:a.phoneNo];
            }
        }
        
        [self showFriendDetailForUserid:self.targetUserid];
    }
}


-(void) handleTypingEvent:(NSString *) fromUserid
{
    // Typing Event for this chat?
    if ([fromUserid isEqualToString:self.targetUserid]) {
        self.lastTypeEventReceived = CFAbsoluteTimeGetCurrent();
        
        // Show prompt
        self.navigationItem.prompt = NSLocalizedString(@" is typing...", [[C2CallPhone currentPhone] nameForUserid:fromUserid]);
        double delayInSeconds = 2.5;
        
        // And remove if no further event has been receive in the past few seconds
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (CFAbsoluteTimeGetCurrent() - self.lastTypeEventReceived > 2.4) {
                self.navigationItem.prompt = nil;
            }
        });
    }
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == Action_Call) {
        if (buttonIndex == 0)
            [[C2CallPhone currentPhone] callVoIP:self.targetUserid];
        else if (buttonIndex == 1) {
            [[C2CallPhone currentPhone] callVideo:self.targetUserid];
        }
    }
    else if (actionSheet.tag == Action_RichMessage) {
        if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Choose Photo or Video", @"")]) {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = NO;
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, kUTTypeMovie, nil];
            imagePicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
        else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kRichMessage_TakePhotoOrVideo]) {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = NO;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, kUTTypeMovie, nil];
            imagePicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
        else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Share Location", @"")]) {
            [self requestLocation:^(NSString *key) {
                [[C2CallPhone currentPhone] submitRichMessage:key message:nil toTarget:self.targetUserid preferEncrytion:self.encryptMessageButton.selected];
            }];
        }
        else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Send Contact", @"")]) {
            [self showPicker:nil];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];

     [[C2CallPhone currentPhone] submitImage:image withQuality:UIImagePickerControllerQualityTypeMedium andMessage:nil toTarget:self.targetUserid withCompletionHandler:^(BOOL success, NSString *richMediaKey, NSError *error) {
         //TODO MingKei, please take care of the error handling and successful
         
         if(success)
         {
             NSLog(@"success");
         }
         else
         {
            NSLog(@"error");
         }
          [self dismissViewControllerAnimated:YES completion:NULL];
     }];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    NSLog(@"went here ...");
    
    [self.view endEditing:YES];
    return NO; // handle the touch
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"audioRecorder"]){
        self.audioView = (SCAudioRecorderController *)segue.destinationViewController;
        [self.audioView setSubmitAction:^(NSString *key) {
            [[C2CallPhone currentPhone] submitRichMessage:key message:nil toTarget:self.targetUserid preferEncrytion:self.encryptMessageButton.selected];
        }];
    }
    else{
        [super prepareForSegue:segue sender:sender];
    }
}

- (IBAction)recordBtnPress:(id)sender{
    if (!isRecording) {
        [self.audioView toogleRecording:self.audioView.btnRecord];
        [self.recordButton setImage:[UIImage imageNamed:@"Mic_press.png"] forState:UIControlStateHighlighted];
        isRecording = YES;
        [self.lblRecording setHidden:NO];
    }
}

- (IBAction)recordBtnUnpress:(id)sender{
    if(isRecording){
        [self.audioView togglePlayback:self.audioView.btnPlay];
        isRecording = NO;
        [self.lblRecording setHidden:YES];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Send voice message"
                                                        message:@"Send the recorded voice message?"
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
        [alert show];

    }
    
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self.audioView submitMessage:self.audioView.btnSubmit];
    }
    SCAudioRecorderController* newVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SCAudioRecorderController"];
    [newVC setSubmitAction:^(NSString *key) {
        [[C2CallPhone currentPhone] submitRichMessage:key message:nil toTarget:self.targetUserid preferEncrytion:self.encryptMessageButton.selected];
    }];
    newVC.view.frame = self.audioContainer.bounds;
    [self.audioContainer addSubview:newVC.view];
    [self addChildViewController:newVC];
    [newVC didMoveToParentViewController:self];
    self.audioView = newVC;

}

-(void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text length] > 0) {
        [self.submitButton setHidden:NO];
        [self.recordButton setHidden:YES];
    }
    else{
        [self.submitButton setHidden:YES];
        [self.recordButton setHidden:NO];
    }
}

@end