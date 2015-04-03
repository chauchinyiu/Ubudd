//
//  WUImageViewController.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 19/12/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "WUImageViewController.h"

@interface WUImageViewController (){
    float standardScale;
    UIColor* oldColor;
}
@end

@implementation WUImageViewController
@synthesize viewImage, pageID, imageView, imageFrame;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [imageView setImage:viewImage];
    
    standardScale = MIN(self.view.bounds.size.width / self.imageView.image.size.width, self.view.bounds.size.height / self.imageView.image.size.height);

    
    imageFrame.minimumZoomScale = 0.5;
    imageFrame.maximumZoomScale = 6.0;
    imageFrame.zoomScale = standardScale;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(imageClicked)];
    singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTap];
    

    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(imageDblClicked)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
}
/*
-(void)viewWillAppear:(BOOL)animated{
    oldColor = self.navigationController.navigationBar.barTintColor;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    [self.navigationController.navigationBar setTranslucent:YES];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    [[UINavigationBar appearance] setTranslucent:YES];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
    
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
 }

-(void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = oldColor;
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];

}
 */

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView
                       withView:(UIView *)view
                        atScale:(CGFloat)scale{
    
}

-(void)imageClicked{
    /*
    if (imageFrame.zoomScale != 1.0f) {
        CGSize scrollViewSize = imageFrame.bounds.size;
        
        CGFloat w = scrollViewSize.width;
        CGFloat h = scrollViewSize.height;
        CGFloat x = (w / 2.0f);
        CGFloat y = (h / 2.0f);
        
        CGRect rectToZoomTo = CGRectMake(x, y, w, h);
        [imageFrame zoomToRect:rectToZoomTo animated:YES];
        
    }
     */
    
    //toggle navigation bar
    if (self.navigationController.navigationBar.hidden == NO)
    {
        // hide the Navigation Bar
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    // if Navigation Bar is already hidden
    else if (self.navigationController.navigationBar.hidden == YES)
    {
        // Show the Navigation Bar
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    
    
}

-(void)imageDblClicked{
    if (imageFrame.zoomScale > standardScale) {
        [imageFrame setZoomScale:standardScale animated:YES];
    }
    else{
        [imageFrame setZoomScale:standardScale * 2 animated:YES];
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

@end
