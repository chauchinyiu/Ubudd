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
}
@end

@implementation WUImageViewController
@synthesize viewImage, pageID, imageView, imageFrame, info;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(imageClicked)];
    singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTap];
    
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(imageDblClicked)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Do any additional setup after loading the view.
    [imageView setImage:viewImage];
 
    [self setupImageFrame];
}
- (void)setupImageFrame
{
    standardScale = 1.00 * MIN(self.view.bounds.size.width / self.imageView.image.size.width, self.view.bounds.size.height / self.imageView.image.size.height);
    
    if (standardScale > 1) {
        CGFloat top = 0, left = 0;

        if(self.view.bounds.size.width < self.view.bounds.size.height){
            standardScale = 1.01;
            left = (self.view.bounds.size.width - imageFrame.bounds.size.width) * 0.5f;
            top = (self.view.bounds.size.height - imageFrame.bounds.size.height) * 0.5f;
        }
        else{
            if((self.imageView.image.size.height / self.imageView.image.size.width) > (self.view.bounds.size.width / self.view.bounds.size.height)){
                standardScale = 1.01 * self.view.bounds.size.height / self.view.bounds.size.width;
                left = (self.view.bounds.size.width - (self.view.bounds.size.height * standardScale)) * 0.5f;
                
            }
            else if((self.imageView.image.size.width / self.imageView.image.size.height) > (self.view.bounds.size.width / self.view.bounds.size.height)){
                standardScale = 1.01 * self.view.bounds.size.width / self.view.bounds.size.height;
                top = ((self.view.bounds.size.width * standardScale) - self.view.bounds.size.height) * -0.5f;
                
            }
            else{
                standardScale = 1.01 * self.imageView.image.size.width / self.imageView.image.size.height;
                top = ((self.view.bounds.size.width * standardScale) - self.view.bounds.size.height) * -0.5f;
                left = (self.view.bounds.size.width - (self.view.bounds.size.height * standardScale)) * 0.5f;
            }
        }
        imageFrame.contentInset = UIEdgeInsetsMake(top, left, top, left);
        imageFrame.minimumZoomScale = standardScale;
        imageFrame.maximumZoomScale = MAX(6, standardScale * 2);
        [imageFrame setZoomScale:standardScale animated:NO];
        
    }
    else{
        CGFloat top = 0, left = 0;
        left = (self.view.bounds.size.width - self.imageView.image.size.width * standardScale) * 0.5f;
        top = (self.view.bounds.size.height - self.imageView.image.size.height * standardScale) * 0.5f;
        imageFrame.contentInset = UIEdgeInsetsMake(top, left, top, left);
        
        imageFrame.minimumZoomScale = standardScale;
        imageFrame.maximumZoomScale = MAX(6, standardScale * 2);
        [imageFrame setZoomScale:standardScale animated:NO];
    
    }

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

        if([info objectForKey:@"SingleImage"] == nil
           && [info objectForKey:@"IsBroadcast"] == nil)
        {
            [self.navigationController setToolbarHidden:YES animated:YES];
        }
        

    }
    else if (self.navigationController.navigationBar.hidden == YES)
    {
        // if Navigation Bar is already hidden
        // Show the Navigation Bar
        [self.navigationController setNavigationBarHidden:NO animated:YES];

        if([info objectForKey:@"SingleImage"] == nil
           && [info objectForKey:@"IsBroadcast"] == nil)
        {
            [self.navigationController setToolbarHidden:NO animated:YES];
        }        
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

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    // Code here will execute before the rotation begins.
    // Equivalent to placing it in the deprecated method -[willRotateToInterfaceOrientation:duration:]
    
   __weak typeof(self) weakSelf = self;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        // Place code here to perform animations during the rotation.
        // You can pass nil or leave this block empty if not necessary.
     [weakSelf setupImageFrame];
    } completion:NULL];
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
