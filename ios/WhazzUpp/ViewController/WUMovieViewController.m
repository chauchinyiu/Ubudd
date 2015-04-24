//
//  WUMovieViewController.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 24/4/2015.
//  Copyright (c) 2015年 3Embed Technologies. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "WUMovieViewController.h"
#import <SocialCommunication/SocialCommunication.h>

@interface WUMovieViewController (){
    NSString* movieText;
    MPMoviePlayerController *moviePlayerController;
    UIColor* oldColor;
}

@end

@implementation WUMovieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{

    oldColor = self.navigationController.navigationBar.barTintColor;
    
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"blackbar"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

-(void)viewDidAppear:(BOOL)animated{
    if(!moviePlayerController){
        NSURL* fileURL = [[C2CallPhone currentPhone] mediaUrlForKey:movieText];
        moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:fileURL];
        [moviePlayerController prepareToPlay];
        [moviePlayerController.view setFrame:self.view.bounds];
        [self.view addSubview:moviePlayerController.view];
        [moviePlayerController play];
    }
}


- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    // Code here will execute before the rotation begins.
    // Equivalent to placing it in the deprecated method -[willRotateToInterfaceOrientation:duration:]
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        // Place code here to perform animations during the rotation.
        // You can pass nil or leave this block empty if not necessary.
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        // Code here will execute after the rotation has finished.
        // Equivalent to placing it in the deprecated method -[didRotateFromInterfaceOrientation:]
        [moviePlayerController.view setFrame:self.view.bounds];
        
    }];
}

-(void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    
    self.navigationController.navigationBar.barTintColor = oldColor;
    self.navigationController.navigationBar.alpha = 1.0;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)showMovie:(NSString*)movie{
    movieText = movie;
}


@end
