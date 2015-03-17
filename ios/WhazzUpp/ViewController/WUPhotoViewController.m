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

@interface WUPhotoViewController (){
    NSArray* pages;
    int initPageIndex;
    UIBarButtonItem* titleLabel;
    
}
@end

@implementation WUPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //[self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    //self.navigationController.navigationBar.shadowImage = [UIImage new];
    //self.navigationController.navigationBar.alpha = 0.5;
    
    titleLabel = [[UIBarButtonItem alloc] init];
    titleLabel.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = titleLabel;
    
    WUImageViewController *startingPage = [self GetViewControllerForPage:initPageIndex];
    if (startingPage != nil)
    {
        self.dataSource = self;
        self.delegate = self;
        
        [self setViewControllers:@[startingPage]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO
                      completion:nil];
        
        titleLabel.title = [NSString stringWithFormat:@"%d / %d", initPageIndex + 1, (int)pages.count];

    }
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.translucent = NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{
    if (completed) {
        WUImageViewController* vc = [self.viewControllers objectAtIndex:0];
        titleLabel.title = [NSString stringWithFormat:@"%d / %d", vc.pageID + 1, (int)pages.count];
        
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
        if ([info objectForKey:@"IsBroadcast"]) {
            image = [UIImage imageWithData:((WUBroadcast*)[[ResponseHandler instance].broadcastList objectAtIndex:((NSNumber*)[info objectForKey:@"image"]).intValue]).imgData];
        }
        else{
            image = [[C2CallPhone currentPhone] imageForKey:[info objectForKey:@"image"]];
        }
        vc.viewImage = image;
        vc.pageID = pageIdx;
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
