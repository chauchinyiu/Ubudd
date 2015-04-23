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
    NSArray* pages;
    int initPageIndex;
    UIColor* oldColor;
    UILabel* custLabel;
    NSMutableAttributedString* atitle;
    NSDictionary* info;
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
        
        self.navigationItem.title = [NSString stringWithFormat:@"%d of %d", initPageIndex + 1, (int)pages.count];
        
    }
    
    if ([info objectForKey:@"SingleImage"]) {
    }
    else if ([info objectForKey:@"IsBroadcast"]) {
    }
    else{
        [self.navigationController setToolbarHidden:NO animated:NO];
        
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:nil action:nil]];
        
        [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
        
        custLabel = [[UILabel alloc] init];
        [custLabel setText:chatTitle];
        
        custLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0 , 0.0f, 100.0f, 44.0f)];
        [custLabel setBackgroundColor:[UIColor clearColor]];
        [custLabel setTextColor:[UIColor whiteColor]];
        [custLabel setTextAlignment:NSTextAlignmentCenter];
        custLabel.numberOfLines = 2;
        
        
        if (atitle) {
            [custLabel setAttributedText:atitle];
        }
        
        [items addObject:[[UIBarButtonItem alloc] initWithCustomView:custLabel]];
        
        [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
        
        [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:nil action:nil]];
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
        WUImageViewController* vc = [self.viewControllers objectAtIndex:0];
        self.navigationItem.title = [NSString stringWithFormat:@"%d of %d", vc.pageID + 1, (int)pages.count];
        
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
    pages = imageList;
    initPageIndex = 0;
    for (int i = 0; i < imageList.count; i++) {
        info = [pages objectAtIndex:i];
        if ([imageKey isEqualToString:[info objectForKey:@"image"]]) {
            initPageIndex = i;

        }
    }
    
    

}

-(WUImageViewController*) GetViewControllerForPage:(int) pageIdx{
    if (pageIdx >= 0 && pageIdx < pages.count) {
        info = [pages objectAtIndex:pageIdx];
        NSString * storyboardName = @"MainStoryboard";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        WUImageViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"WUImageViewController"];
        
        UIImage* image;
        if ([info objectForKey:@"SingleImage"]) {
            image = [info objectForKey:@"image"];
        }
        else if ([info objectForKey:@"IsBroadcast"]) {
            image = [UIImage imageWithData:((WUBroadcast*)[[ResponseHandler instance].broadcastList objectAtIndex:((NSNumber*)[info objectForKey:@"image"]).intValue]).imgData];
        }
        else{
            image = [[C2CallPhone currentPhone] imageForKey:[info objectForKey:@"image"]];
            
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
        vc.viewImage = image;
        vc.pageID = pageIdx;
        vc.info = info;
        return vc;
    }
    else{
        return nil;
    }
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
