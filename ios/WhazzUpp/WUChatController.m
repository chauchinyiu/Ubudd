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

#define kRichMessage_ChoosePhotoOrVideo @"Choose Photo or Video"
#define kRichMessage_TakePhotoOrVideo @"Take Photo or Video"
#define kRichMessage_SubmitLocation @"Submit Location"
#define kRichMessage_SubmitVoiceMessage @"Submit Voice Message"
#define kRichMessage_SendContact @"Send Contact"

typedef enum : NSUInteger {
    Action_Call,
    Action_RichMessage
} ChatAction;

@interface WUChatController ()

@property (nonatomic, assign) CFAbsoluteTime lastTypeEventReceived;

@end

@implementation WUChatController

#pragma mark - UIButton Action
- (IBAction)btnCallTapped {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Voice Call", @"Video Call", nil];
    actionSheet.tag = Action_Call;
    [actionSheet showInView:self.view];
    
//    [[C2CallPhone currentPhone] callVoIP:self.targetUserid];
}

- (IBAction)btnRichMessageTapped:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select an option" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    actionSheet.tag = Action_RichMessage;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [actionSheet addButtonWithTitle:kRichMessage_ChoosePhotoOrVideo];
    }
    
    if ([SIPPhone currentPhone].callStatus == SCCallStatusNone) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [actionSheet addButtonWithTitle:kRichMessage_TakePhotoOrVideo];
        }
    }
    
    if ([CLLocationManager locationServicesEnabled]) {
        [actionSheet addButtonWithTitle:kRichMessage_SubmitLocation];
    }
    
    if ([SIPPhone currentPhone].callStatus == SCCallStatusNone) {
        if ([[AVAudioSession sharedInstance] inputIsAvailable]) {
            [actionSheet addButtonWithTitle:kRichMessage_SubmitVoiceMessage];
        }
    }
    
    if ([CommonMethods osVersion] >= 5.0) {
        [actionSheet addButtonWithTitle:kRichMessage_SendContact];
    }

    [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
    
    [actionSheet showInView:self.view];
}

#pragma mark - UIViewController Delegate
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tabBarController.tabBar.hidden = YES;
    [self.submitButton setImage:nil forState:UIControlStateHighlighted];
    
    if (self.sendWelcomeText) {
        self.chatInput.text = @"Welcome!";
        [self submit:self.submitButton];
    }

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(hidekeybord)];
    [tap setDelegate:self];
    [self.view addGestureRecognizer:tap];

    MOC2CallUser *user = [[SCDataManager instance] userForUserid:self.targetUserid];
    [self.titleButton setTitle:user.displayName forState:UIControlStateNormal];
}
    


#pragma mark - ChatController Methods
-(IBAction)openProfile:(id)sender
{
    MOC2CallUser *user = [[SCDataManager instance] userForUserid:self.targetUserid];
    if ([user.userType intValue] == 2) {
        [self showGroupDetailForGroupid:self.targetUserid];
    } else {
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
        if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kRichMessage_ChoosePhotoOrVideo]) {
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
        else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kRichMessage_SubmitLocation]) {
            [self requestLocation:^(NSString *key) {
                [[C2CallPhone currentPhone] submitRichMessage:key message:nil toTarget:self.targetUserid preferEncrytion:self.encryptMessageButton.selected];
            }];
        }
        else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kRichMessage_SubmitVoiceMessage]) {
            [self recordVoiceMail:^(NSString *key) {
                [[C2CallPhone currentPhone] submitRichMessage:key message:nil toTarget:self.targetUserid preferEncrytion:self.encryptMessageButton.selected];
            }];
        }
        else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kRichMessage_SendContact]) {
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

-(void)hidekeybord
{
    [self.view endEditing:YES];
}

@end