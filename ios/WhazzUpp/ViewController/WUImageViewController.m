//
//  WUImageViewController.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 19/12/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "WUImageViewController.h"

@interface WUImageViewController ()
@end

@implementation WUImageViewController
@synthesize viewImage, pageID, imageView, imageFrame;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [imageView setImage:viewImage];
    
    imageFrame.minimumZoomScale = 0.5;
    imageFrame.maximumZoomScale = 6.0;
    imageFrame.contentSize = imageView.frame.size;
    [imageFrame scrollRectToVisible:imageView.frame animated:NO];

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(imageClicked)];
    singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTap];
    

    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(imageDblClicked)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.translucent = NO;
}

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
    
    if (imageFrame.zoomScale != 1.0f) {
        CGSize scrollViewSize = imageFrame.bounds.size;
        
        CGFloat w = scrollViewSize.width;
        CGFloat h = scrollViewSize.height;
        CGFloat x = (w / 2.0f);
        CGFloat y = (h / 2.0f);
        
        CGRect rectToZoomTo = CGRectMake(x, y, w, h);
        [imageFrame zoomToRect:rectToZoomTo animated:YES];
        
    }
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

    CGSize scrollViewSize = imageFrame.bounds.size;
    CGFloat w;
    CGFloat h;
    CGFloat x;
    CGFloat y;
    if (imageFrame.zoomScale > 1.0f) {
        w = scrollViewSize.width;
        h = scrollViewSize.height;
        x = (w / 2.0f);
        y = (h / 2.0f);
    }
    else{
        
        w = scrollViewSize.width / 2.0f;
        h = scrollViewSize.height / 2.0f;
        x = scrollViewSize.width / 4.0f;
        y = scrollViewSize.height / 4.0f;
    }
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    [imageFrame zoomToRect:rectToZoomTo animated:YES];
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
