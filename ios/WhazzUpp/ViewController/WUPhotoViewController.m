//
//  WUPhotoViewController.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 19/12/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "WUPhotoViewController.h"
#import "WUImageViewController.h"
#import "ResponseHandler.h"
#import "CommonMethods.h"

@interface WUPhotoViewController (){
    NSMutableArray* pages;
    int initPageIndex;
    UIColor* oldColor;
    UILabel* custLabel;
    NSMutableAttributedString* atitle;
    
}
@end

@implementation WUPhotoViewController

@synthesize chatTitle;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    WUImageViewController *startingPage = [self GetViewControllerForPage:initPageIndex];
    if (startingPage != nil)
    {
        self.dataSource = self;
        self.delegate = self;
        
        
        [self setViewControllers:@[startingPage]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO
                      completion:nil];
        
        self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"XOfY",  @"%d of %d"), initPageIndex + 1, (int)pages.count];
        
    }
    
    if ([[pages objectAtIndex:0] objectForKey:@"SingleImage"]) {
    }
    else if ([[pages objectAtIndex:0] objectForKey:@"IsBroadcast"]) {
    }
    else{
        [self.navigationController setToolbarHidden:NO animated:NO];
        
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showMenu)]];
        
        [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
        
        custLabel = [[UILabel alloc] init];
        [custLabel setText:chatTitle];
        
        custLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0 , 0.0f, 200.0f, 44.0f)];
        [custLabel setBackgroundColor:[UIColor clearColor]];
        [custLabel setTextColor:[UIColor whiteColor]];
        [custLabel setTextAlignment:NSTextAlignmentCenter];
        custLabel.numberOfLines = 2;
        custLabel.adjustsFontSizeToFitWidth = YES;
        custLabel.minimumScaleFactor = 0.2;
        
        
        if (atitle) {
            [custLabel setAttributedText:atitle];
        }
        
        [items addObject:[[UIBarButtonItem alloc] initWithCustomView:custLabel]];
        
        [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
        
        [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deletePhoto)]];
        [self setToolbarItems:items animated:NO];
    }
}


-(void)viewWillAppear:(BOOL)animated{
    oldColor = self.navigationController.navigationBar.barTintColor;


    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"blackbar"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];

    
    self.navigationController.toolbar.translucent = YES;
    [self.navigationController.toolbar setBackgroundImage:[UIImage imageNamed:@"blackbar"] forToolbarPosition:UIBarPositionBottom barMetrics:UIBarMetricsDefault];
    self.navigationController.toolbar.tintColor = [UIColor whiteColor];
    
    
    if ([[pages objectAtIndex:0] objectForKey:@"SingleImage"]) {
    }
    else if ([[pages objectAtIndex:0] objectForKey:@"IsBroadcast"]) {
    }
    else if(!self.navigationController.navigationBarHidden) {
        [self.navigationController setToolbarHidden:NO animated:NO];
    }
    
    [self refreshLabel];
}


-(void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    
    self.navigationController.navigationBar.barTintColor = oldColor;
    self.navigationController.navigationBar.alpha = 1.0;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    
    [self.navigationController setToolbarHidden:YES animated:NO];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{
    if (completed) {
        [self refreshLabel];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void) showPhotos:(NSArray *) imageList currentPhoto:(NSString *) imageKey{
    pages =  [[NSMutableArray alloc] initWithArray:imageList];
    initPageIndex = 0;
    for (int i = 0; i < imageList.count; i++) {
         NSDictionary* info = [pages objectAtIndex:i];
        if ([imageKey isEqualToString:[info objectForKey:@"image"]]) {
            initPageIndex = i;
        }
    }
}

-(WUImageViewController*) GetViewControllerForPage:(int) pageIdx{
    if (pageIdx >= 0 && pageIdx < pages.count) {
        NSDictionary* info = [pages objectAtIndex:pageIdx];
        NSString * storyboardName = @"MainStoryboard";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        WUImageViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"WUImageViewController"];
        
        UIImage* image;
        if ([info objectForKey:@"SingleImage"]) {
            image = [info objectForKey:@"image"];
        }
        else if ([info objectForKey:@"IsBroadcast"]) {
            image = [info objectForKey:@"rawData"];
        }
        else{
            image = [info objectForKey:@"rawData"];
        }
        vc.viewImage = image;
        vc.pageID = pageIdx;
        vc.info = info;
        return vc;
    }
    else{
        return nil;
    }
}


-(void)deletePhoto{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete Photo", @"") message: NSLocalizedString(@"Do you wish to delete this photo", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"No", @"") otherButtonTitles: NSLocalizedString(@"Yes", @""), nil];
    [alert show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        WUImageViewController* vc = [self.viewControllers objectAtIndex:0];
        NSDictionary* info = vc.info;
        [[SCDataManager instance] removeDatabaseObject:[info objectForKey:@"eventObject"]];
        [pages removeObjectAtIndex:vc.pageID];
        WUImageViewController* newVC;
        if (pages.count > vc.pageID) {
            newVC = [self GetViewControllerForPage:vc.pageID];
        }
        else{
            newVC = [self GetViewControllerForPage:vc.pageID - 1];
        }
        NSArray* newPage = [[NSMutableArray alloc] initWithObjects:newVC, nil];
        [self setViewControllers:newPage direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:Nil];
        [self refreshLabel];
    }
}


-(void)showMenu{
    UIMenuController *menu = [UIMenuController sharedMenuController];
    NSMutableArray *menulist = [NSMutableArray arrayWithCapacity:5];
    UIMenuItem* item;
    
    item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Save", @"MenuItem") action:@selector(savePhoto:)];
    [menulist addObject:item];
    
    item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Email", @"MenuItem") action:@selector(emailPhoto:)];
    [menulist addObject:item];
    
    item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Forward", @"MenuItem") action:@selector(forwardPhoto:)];
    [menulist addObject:item];
    
    menu.menuItems = menulist;
    

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Photo Action", @"") delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Save", @"")];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Email", @"")];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Forward", @"")];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
    
    [actionSheet showFromToolbar:self.navigationController.toolbar];
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Save", @"")]) {
        [self savePhoto];
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Email", @"")]) {
        [self emailPhoto];
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Forward", @"")]) {
        [self forwardPhoto];
    }
}


-(void)savePhoto{
    [[C2CallAppDelegate appDelegate] waitIndicatorWithTitle:NSLocalizedString(@"Saving Image to Photo Album", @"Title") andWaitMessage:nil];
    
    WUImageViewController* vc = [self.viewControllers objectAtIndex:0];
    NSDictionary* info = vc.info;

    [[C2CallPhone currentPhone] saveToAlbum:[info
                                              objectForKey:@"image"] withCompletionHandler:^(NSURL *assetURL, NSError *error) {
        [[C2CallAppDelegate appDelegate] waitIndicatorStop];
    }];
}

-(void)emailPhoto{
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *emailController = [[MFMailComposeViewController alloc] init];
        WUImageViewController* vc = [self.viewControllers objectAtIndex:0];
        NSDictionary* info = vc.info;

        UIImage *myImage = [[C2CallPhone currentPhone] imageForKey:[info
                                                                    objectForKey:@"image"]];
        NSData *imageData = UIImageJPEGRepresentation(myImage, 0.95);
        
        [emailController addAttachmentData:imageData mimeType:@"image/jpeg" fileName:@"image"];
        emailController.mailComposeDelegate = self;
        [self presentViewController:emailController animated:YES completion:nil];
    }
}

-(void)forwardPhoto{
    NSString * storyboardName = @"MainStoryboard";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    WUNewChatViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"WUNewChatViewController"];

    [vc switchToSelectionMode:self];
    [self.navigationController pushViewController:vc animated:YES];
    
}


-(void)selectTarget:(NSString*)c2callID{
    WUImageViewController* vc = [self.viewControllers objectAtIndex:0];
    NSDictionary* info = vc.info;
    UIImage *myImage = [[C2CallPhone currentPhone] imageForKey:[info
                                                                objectForKey:@"image"]];
    [[C2CallPhone currentPhone] submitImage:myImage withQuality:UIImagePickerControllerQualityTypeHigh andMessage:nil toTarget:c2callID withCompletionHandler:nil];
}


-(void)refreshLabel{
    WUImageViewController* vc = [self.viewControllers objectAtIndex:0];
    self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"XOfY", @"%d of %d"), vc.pageID + 1, (int)pages.count];
    
    NSDictionary* info = vc.info;
    if ([info objectForKey:@"SingleImage"]) {
    }
    else if ([info objectForKey:@"IsBroadcast"]) {
    }
    else{
        NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"MMMM d HH:mm" options:0
                                                                  locale:[NSLocale currentLocale]];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:formatString];
        NSString* photoTime = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:[info objectForKey:@"timeStamp"]]];
        
        
        atitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", chatTitle, photoTime]];
        
        UIFont* fontStd = [CommonMethods getStdFontType:3];
        [atitle addAttribute:NSFontAttributeName value:fontStd range:NSMakeRange(chatTitle.length, atitle.length - chatTitle.length)];
        
        if (custLabel) {
            [custLabel setAttributedText:atitle];
        }
    }
    
}



- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - UIPageViewControllerDelegate



- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerBeforeViewController:(WUImageViewController *)vc
{
    NSUInteger index = vc.pageID;
    return [self GetViewControllerForPage:((int)index - 1)];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerAfterViewController:(WUImageViewController *)vc
{
    NSUInteger index = vc.pageID;
    return [self GetViewControllerForPage:((int)index + 1)];
}

@end
