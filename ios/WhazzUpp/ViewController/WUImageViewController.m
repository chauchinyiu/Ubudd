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
    // Do any additional setup after loading the view.
    [imageView setImage:viewImage];
    
    standardScale = 1.01 * MAX(self.view.bounds.size.width / self.imageView.image.size.width, self.view.bounds.size.height / self.imageView.image.size.height);

    if (standardScale > 1.01) {
        standardScale = 1.01;
    }
    
    imageFrame.minimumZoomScale = MIN(0.5, standardScale / 2);
    imageFrame.maximumZoomScale = MAX(6, standardScale * 2);
    imageFrame.zoomScale = standardScale;
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(imageClicked)];
    singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTap];
    

    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(imageDblClicked)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
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
        
        if ([info objectForKey:@"SingleImage"]) {
        }
        else if ([info objectForKey:@"IsBroadcast"]) {
        }
        else{
            [self.navigationController setToolbarHidden:YES animated:YES];
        }
        

    }
    else if (self.navigationController.navigationBar.hidden == YES)
    {
        // if Navigation Bar is already hidden
        // Show the Navigation Bar
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        
        if ([info objectForKey:@"SingleImage"]) {
        }
        else if ([info objectForKey:@"IsBroadcast"]) {
        }
        else{
            [self.navigationController setToolbarHidden:NO animated:YES];
        }        
    }
    
    imageFrame.contentOffset = CGPointMake(0, 0);
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
