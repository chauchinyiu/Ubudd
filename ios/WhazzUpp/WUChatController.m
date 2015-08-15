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
#import "WUBoardController.h"
#import "WUPhotoViewController.h"

//#define kRichMessage_ChoosePhotoOrVideo @"Choose Photo or Video"
//#define kRichMessage_TakePhotoOrVideo @"Take Photo or Video"
//#define kRichMessage_SubmitLocation @"Submit Location"
//#define kRichMessage_SubmitVoiceMessage @"Submit Voice Message"
//#define kRichMessage_SendContact @"Send Contact"


typedef enum : NSUInteger {
    Action_Call,
    Action_RichMessage
} ChatAction;

@interface WUChatController (){
    BOOL isRecording;
    double accumulatedTime;
    NSTimer* timer;
    NSMutableAttributedString* boardTitle;
    AVAudioRecorder *audioRecorder;
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
            [actionSheet addButtonWithTitle:NSLocalizedString(@"Take Photo or Video", @"")];
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
    [self.submitButton setHidden:YES];
    [self.recordButton setHidden:NO];
    
}

-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"start chat will appear");

    self.navigationController.navigationBar.translucent = NO;
    NSMutableArray* friends = [ResponseHandler instance].friendList;
    
    for (int i = 0; i < friends.count; i++) {
        WUAccount* a = [friends objectAtIndex:i];
        if([a.c2CallID isEqualToString:self.targetUserid] && a.name != nil){
            boardTitle = [[NSMutableAttributedString alloc] initWithString:a.name];
        }
    }
    NSMutableArray* groups = [ResponseHandler instance].groupList;
    for (int i = 0; i < groups.count; i++) {
        WUAccount* a = [groups objectAtIndex:i];
        if([a.c2CallID isEqualToString:self.targetUserid] && a.name != nil){
            boardTitle = [[NSMutableAttributedString alloc] initWithString:a.name];
        }
    }
    
    UIFont* fontStdb = [CommonMethods getStdFontType:0];
    [boardTitle addAttribute:NSFontAttributeName value:fontStdb range:NSMakeRange(0, boardTitle.length)];
    
    
    UIBarButtonItem *newBackButton =[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"")
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    
    ((WUBoardController*)self.chatboard).chatTitle = [boardTitle string];
    [self.chatboard.tableView reloadData];
    [self.titleButton setAttributedTitle:boardTitle forState:UIControlStateNormal];
    
    self.chatInput.font = [CommonMethods getStdFontType:1];
    [self resizeToolbar:@"A"];

    [self.recordButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.attachButton.imageView setContentMode:UIViewContentModeScaleAspectFit];

    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:13.0]} forState:UIControlStateNormal];
    NSLog(@"end chat will appear");

}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.chatInputBorderWidth = 1.5;
        self.chatInputCornerRadius = 8.;
        self.chatInputBorderColor = [UIColor colorWithRed:228./256. green:228./256. blue:228./256. alpha:1.];
        self.dontShowCallEvents = YES;
        
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.chatInputBorderWidth = 1.5;
        self.chatInputCornerRadius = 8.;
        self.chatInputBorderColor = [UIColor colorWithRed:228./256. green:228./256. blue:228./256. alpha:1.];
        self.dontShowCallEvents = YES;
        
    }
    return self;
}

#pragma mark - UIViewController Delegate
- (void)viewDidLoad
{
    NSLog(@"start chat did load");
    
    [super viewDidLoad];
    
    self.chatInputBorderWidth = 1.;
    self.chatInputCornerRadius = 8.;
    self.chatInputBorderColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"chatboard" bundle: nil];
    WUBoardController* newVC = [storyboard instantiateViewControllerWithIdentifier:@"SCBoardController"];
    newVC.view.frame = self.broadContainer.bounds;
    [self.broadContainer addSubview:newVC.view];
    [self addChildViewController:newVC];
    [newVC didMoveToParentViewController:self];
    self.chatboard = newVC;
    self.chatboard.targetUserid = self.targetUserid;
    [self.chatboard initFetchedResultsController];
    
    self.tabBarController.tabBar.hidden = YES;
    [self.submitButton setImage:nil forState:UIControlStateHighlighted];
    

    MOC2CallUser *user = [[SCDataManager instance] userForUserid:self.targetUserid];
    if(user){
        boardTitle = [[NSMutableAttributedString alloc] initWithString:user.displayName];
        UIFont* fontStdb = [CommonMethods getStdFontType:0];
        [boardTitle addAttribute:NSFontAttributeName value:fontStdb range:NSMakeRange(0, boardTitle.length)];
        
        
        [self.titleButton setAttributedTitle:boardTitle forState:UIControlStateNormal];
    }
    UIImage *image = [[C2CallPhone currentPhone] userimageForUserid:self.targetUserid];

    [[self.imageBtn imageView] setContentMode:UIViewContentModeScaleAspectFill];
    if (image) {
        [self.imageBtn setImage:image forState:UIControlStateNormal];
    }
    else{
        if ([user.userType intValue] == 2) {
            [self.imageBtn setImage:[UIImage imageNamed:@"btn_ico_avatar_group.png"] forState:UIControlStateNormal];
        }
        else{
            [self.imageBtn setImage:[UIImage imageNamed:@"btn_ico_avatar.png"] forState:UIControlStateNormal];
        }
    }
    self.imageBtn.layer.cornerRadius = 5;
    self.imageBtn.clipsToBounds = YES;
    

    
    self.chatInput.font = [CommonMethods getStdFontType:1];
    
    
    [self.submitButton setHidden:YES];
    [self.recordButton setHidden:NO];
    [self.lblRecording setHidden:YES];
    isRecording = NO;
    

    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(hidekeybord)];
    [tap setDelegate:self];
    [self.view addGestureRecognizer:tap];
    
    
    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    NSString *soundFilePath = [docsDir
                               stringByAppendingPathComponent:@"sound.caf"];
    
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    NSDictionary *recordSettings = [NSDictionary
                                    dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:AVAudioQualityMin],
                                    AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:16],
                                    AVEncoderBitRateKey,
                                    [NSNumber numberWithInt: 2],
                                    AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:44100.0],
                                    AVSampleRateKey,
                                    nil];
    
    NSError *error = nil;
    
    
    audioRecorder = [[AVAudioRecorder alloc]
                      initWithURL:soundFileURL
                      settings:recordSettings
                      error:&error];
    
    if (error)
    {
    } else {
        [audioRecorder prepareToRecord];
    }
    NSLog(@"end chat did load");
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"start chat did appear");
    [super viewDidAppear:animated];
    NSLog(@"end chat did appear");
    
}

- (IBAction)btnImageTapped:(id)sender{
    [CommonMethods showSinglePhoto:[[C2CallPhone currentPhone] largeUserImageForUserid:self.targetUserid] title:[boardTitle string] onNavigationController:self.navigationController];
}



#pragma mark - ChatController Methods
-(IBAction)openProfile:(id)sender
{
    MOC2CallUser *user = [[SCDataManager instance] userForUserid:self.targetUserid];
    if ([user.userType intValue] == 2) {
        [self showGroupDetailForGroupid:self.targetUserid];
    } else {
        NSMutableArray* friendList = [[ResponseHandler instance] friendList];
        [WUFriendDetailController setC2CallID:self.targetUserid];
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

        NSMutableAttributedString* atitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"is typing", @"%@ \nis typing..."), [boardTitle string]]];

        UIFont* fontStdb = [CommonMethods getStdFontType:0];
        [atitle addAttribute:NSFontAttributeName value:fontStdb range:NSMakeRange(0, boardTitle.length)];
        
        
        UIFont* fontStd = [CommonMethods getStdFontType:3];
        [atitle addAttribute:NSFontAttributeName value:fontStd range:NSMakeRange(boardTitle.length, atitle.length - boardTitle.length)];
        [atitle addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(boardTitle.length, atitle.length - boardTitle.length)];
        
        // Show prompt
        [self.titleButton setAttributedTitle:atitle forState:UIControlStateNormal];
        
        double delayInSeconds = 2.5;
        
        // And remove if no further event has been receive in the past few seconds
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (CFAbsoluteTimeGetCurrent() - self.lastTypeEventReceived > 2.4) {
                [self.titleButton setAttributedTitle:boardTitle forState:UIControlStateNormal];;
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
        else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Take Photo or Video", @"")]) {
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
    NSString* mediaType = [info valueForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]){
        UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
        
        [[C2CallPhone currentPhone] submitImage:image withQuality:UIImagePickerControllerQualityTypeHigh andMessage:nil toTarget:self.targetUserid withCompletionHandler:^(BOOL success, NSString *richMediaKey, NSError *error) {
            //TODO MingKei, please take care of the error handling and successful
            
            if(success){
                NSLog(@"success");
            }
            else{
                NSLog(@"error");
            }
            [self dismissViewControllerAnimated:YES completion:NULL];
        }];
    }
    else if ([mediaType isEqualToString:@"public.movie"]){
        NSURL* u = [info valueForKey:UIImagePickerControllerMediaURL];
        [[C2CallPhone currentPhone] submitVideo:u withMessage:nil toTarget:self.targetUserid withCompletionHandler:^(BOOL success, NSString *richMediaKey, NSError *error) {
            //TODO MingKei, please take care of the error handling and successful
            if(success){
                NSLog(@"success");
            }
            else{
                NSLog(@"error");
            }
            [self dismissViewControllerAnimated:YES completion:NULL];
        }];
    }
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    NSLog(@"went here ...");
    
    
    if(![touch.view isKindOfClass:[UITextView class]]){
        if (touch.view != self.submitButton) {
            [self.view endEditing:YES];
        }
    }
    
    
    
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
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryRecord
                            error:nil];
        
        [audioRecorder record];
        [self.recordButton setImage:[UIImage imageNamed:@"Mic_press.png"] forState:UIControlStateHighlighted];
        isRecording = YES;
        [self.lblRecording setHidden:NO];
        accumulatedTime = 0;
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
        self.lblRecording.text = @"00:00";
    }
}

-(void)updateTime:(NSTimer *)timer
{
    accumulatedTime++;
    NSInteger tempMinute = accumulatedTime / 60;
    NSInteger tempSecond = accumulatedTime - (tempMinute * 60);
    
    NSString *minute = [[NSNumber numberWithInteger:tempMinute] stringValue];
    NSString *second = [[NSNumber numberWithInteger:tempSecond] stringValue];
    if (tempMinute < 10) {
        minute = [@"0" stringByAppendingString:minute];
    }
    if (tempSecond < 10) {
        second = [@"0" stringByAppendingString:second];
    }
    self.lblRecording.text = [NSString stringWithFormat:@"%@:%@", minute, second];
}

- (IBAction)recordBtnUnpress:(id)sender{
    if(isRecording){
        [audioRecorder stop];
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback
                            error:nil];
        
        //[self.audioView toogleRecording:self.audioView.btnRecord];
        isRecording = NO;
        [self.lblRecording setHidden:YES];
        [timer invalidate];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Send voice message", @"")
                                                        message:NSLocalizedString(@"Send the recorded voice message", @"")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"No", @"")
                                              otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
        [alert show];

    }
    
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [[C2CallPhone currentPhone] submitAudio:audioRecorder.url withMessage:nil toTarget:self.targetUserid withCompletionHandler:nil];
    }
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




-(void)hidekeybord
{
    
}



@end