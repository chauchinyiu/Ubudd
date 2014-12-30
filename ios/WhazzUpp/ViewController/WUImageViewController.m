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
    
    /*
    CGRect r = imageView.frame;
    r.origin.x = 0;
    r.origin.y = 0;
    r.size.width = viewImage.size.width / viewImage.scale;
    r.size.height = viewImage.size.height / viewImage.scale;
    [imageView setFrame:r];
     */
    imageFrame.minimumZoomScale = 0.5;
    imageFrame.maximumZoomScale = 6.0;
    imageFrame.contentSize = imageView.frame.size;
    [imageFrame scrollRectToVisible:imageView.frame animated:NO];
    
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(imageClicked)];
    doubleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:doubleTap];
    
}

-(void)viewWillAppear:(BOOL)animated{
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
