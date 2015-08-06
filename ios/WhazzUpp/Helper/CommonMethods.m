//
//  CommonMethods.m
//  WhazzUpp
//
//  Created by Sahil.Khanna on 20/05/14.
//  Copyright (c) 2014 C2Call GmbH. All rights reserved.
//

#import "CommonMethods.h"
#import "WUPhotoViewController.h"
#import "WUMovieViewController.h"
#import <SocialCommunication/C2WaitMessage.h>

@implementation WUListEntry
@synthesize source, data, sourcePath, mapToPath;
@end

@implementation CommonMethods

+ (float)osVersion {
    NSString *version = [[UIDevice currentDevice] systemVersion];
    return [version floatValue];
}

#pragma mark - Text formatting
+ (NSString *)trimText:(NSString *)text {
    return [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

#pragma mark -
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:title
                              message:message
                              delegate:delegate
                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                              otherButtonTitles:nil];
    [alertView show];
}

+ (void)showLoading:(BOOL)value title:(NSString *)title message:(NSString *)message {
    if (value)
        [C2WaitMessage waitMessageWithTitle:title ? title : @"" andMessage:message ? message : @""];
    else
        [C2WaitMessage hideWaitMessage];
}

+ (UIFont*) getStdFontType:(int)type{
    
    
    int i = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline].pointSize;
    UIFont* f;
    if (type == 0) {
        f = [UIFont fontWithName:@"HelveticaNeue-Medium" size:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline].pointSize * 13 / 17];
    }
    else if (type == 1) {
        f = [UIFont fontWithName:@"HelveticaNeue" size:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline].pointSize * 13 / 17];
    }
    else if (type == 2) {
        f = [UIFont fontWithName:@"HelveticaNeue" size:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline].pointSize * 11 / 17];
    }
    else if (type == 3) {
        f = [UIFont fontWithName:@"HelveticaNeue" size:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline].pointSize * 9 / 17];
    }
    else if (type == 4) {
        f = [UIFont fontWithName:@"HelveticaNeue" size:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline].pointSize * 12 / 17];
    }
    else{
        
    }
    /*
    if (type == 0) {
        f = [UIFont fontWithName:@"HelveticaNeue-Bold" size:MAX([UIFont preferredFontForTextStyle:UIFontTextStyleBody].pointSize, 9)];
    }
    else if (type == 1) {
        f = [UIFont fontWithName:@"HelveticaNeue" size:MAX([UIFont preferredFontForTextStyle:UIFontTextStyleBody].pointSize, 9)];
    }
    else if (type == 2) {
        f = [UIFont fontWithName:@"HelveticaNeue" size:MAX(([UIFont preferredFontForTextStyle:UIFontTextStyleCaption1].pointSize), 8)];
    }
    else if (type == 3) {
        f = [UIFont fontWithName:@"HelveticaNeue" size:MAX(([UIFont preferredFontForTextStyle:UIFontTextStyleCaption2].pointSize), 7)];
    }
    else{
        
    }
     */
    return f;
}

+(void)showSinglePhoto:(UIImage*)image title:(NSString*) title onNavigationController:(UINavigationController*) nc{
    if (image) {
        //[self showUserImageForUserid:self.targetUserid];
        NSMutableArray *imageList = [NSMutableArray array];
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:3];
        [info setObject:@"YES" forKey:@"SingleImage"];
        [info setObject:image forKey:@"image"];
        [imageList addObject:info];
        
        NSString * storyboardName = @"MainStoryboard";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        
        WUPhotoViewController* vc = [storyboard instantiateViewControllerWithIdentifier:@"WUPhotoViewController"];
        vc.hidesBottomBarWhenPushed = YES;
        
        vc.chatTitle = title;
        [vc showPhotos:imageList currentPhoto:@"0"];
        [nc pushViewController:vc animated:YES];
    }


}

+(void)showMovie:(NSString*)movie onNavigationController:(UINavigationController*) nc{
    NSString * storyboardName = @"MainStoryboard";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    
    WUMovieViewController* vc = [storyboard instantiateViewControllerWithIdentifier:@"WUMovieViewController"];
    vc.hidesBottomBarWhenPushed = YES;
    
    [vc showMovie:movie];
    [nc pushViewController:vc animated:YES];
}

@end