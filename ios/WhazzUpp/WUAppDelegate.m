//
//  WUAppDelegate.m
//  WhazzUpp
//
//  Created by Michael Knecht on 02.06.13.
//  Copyright (c) 2013 C2Call GmbH. All rights reserved.
//

#import "WUAppDelegate.h" 
#import "CommonMethods.h"
#import <SocialCommunication/SCDataManager.h>

#import "WebserviceHandler.h"
#import "ServiceURL.h"
#import "ResponseBase.h"

#import "UpdateAPNSToken.h"
#import "UpdateAPNSTokenDTO.h"
#import "ResponseHandler.h"

#import "WUFavoritesViewController.h"
#import "WURegistrationController.h"
#import "WUPhotoViewController.h"
#import "WUChatHistoryController.h"
#import "WUMovieViewController.h"

@interface WUAppDelegate ()

@property (nonatomic, strong) NSString *coreDataFile;

@end

@implementation WUAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


#pragma mark - Other Methods
- (void)locateCoreData {
    if ([SCDataManager instance].isDataInitialized) {
        NSString *directory = [self applicationDocumentsDirectory];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *files = [fileManager contentsOfDirectoryAtPath:directory error:nil];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF endswith[c] %@", @".sqlite"];
        self.coreDataFile = [files filteredArrayUsingPredicate:predicate].firstObject;
        
    }
}

-(BOOL)useOnlineStatusPrompt
{
    return NO;
}

- (void)customizeUI {
    if ([CommonMethods osVersion] < 7.0) {
        [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:235.0/255.0 green:202.0/255.0 blue:20.0/255.0 alpha:1.0]];
        
        [[UITabBar appearance] setTintColor:[UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0]];
    }
    else {
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:235.0/255.0 green:202.0/255.0 blue:20.0/255.0 alpha:1.0]];
        
        [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0]];
    }
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]}];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Medium" size:13.0]}];
    
    [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"backarrow.png"]];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"backarrow.png"]];
    
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0], NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:8.0]} forState:UIControlStateNormal];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0], NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:8.0]} forState:UIControlStateSelected];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:13.0]} forState:UIControlStateNormal];
    
    

    


    [[UITextField appearance] setTintColor:[UIColor blackColor]];
}

- (void)registerPushNotifications {
    UIUserNotificationType types = UIUserNotificationTypeBadge |
    UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    UIUserNotificationSettings *mySettings =
    [UIUserNotificationSettings settingsForTypes:types categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    /*
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
     */
}

-(void) c2callLoginSuccess
{
    [super c2callLoginSuccess];
    
}

#pragma mark - UIApplication Delegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.useOnlineStatusPrompt = NO;
    self.affiliateid = @"143BF14733A8F380";
    self.secret = @"e883a183dc5ea85b7388319193781c42";
  
    
#ifdef __DEBUG
    self.useSandboxMode = YES;
#endif
    
    self.usePhotoEffects = SC_PHOTO_USERCHOICE;

    [[SCBubbleViewOut appearance] setBaseColor:[UIColor colorWithRed:44./255. green:138./255. blue:251./255. alpha:1.]];
    [[SCBubbleViewIn appearance] setBaseColor:[UIColor colorWithRed:231./255. green:230./255. blue:236./255. alpha:1.]];
    [[SCBubbleViewIn appearance] setBubbleTypeIn:SC_BUBBLE_OUT_IOS7];
    [[SCBubbleViewOut appearance] setBubbleTypeOut:SC_BUBBLE_OUT_IOS7];
    
    [self customizeUI];
        
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"showTestCall"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    

    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UIViewController *viewController;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:kUserDefault_isUserRegistered]) {
        if (![userDefaults boolForKey:kUserDefault_isWelcomeComplete]){
            viewController = [storyboard instantiateViewControllerWithIdentifier:@"VerificationViewController"];
        }
        else{
            viewController = [storyboard instantiateViewControllerWithIdentifier:@"InitController"];
            
        }
    }
    else{
        viewController = [storyboard instantiateViewControllerWithIdentifier:@"RegistrationViewController"];
    
    }

    [[ResponseHandler instance] readInterests];
    
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];    
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];

}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [super applicationWillResignActive:application];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [super applicationDidEnterBackground:application];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [super applicationWillEnterForeground:application];
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [super applicationDidBecomeActive:application];
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSDate* lastupdate = [[NSUserDefaults standardUserDefaults] objectForKey:@"interestRefreshTime"];
    int tVersion = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"RefreshVersion"] ;
    if (lastupdate == nil || [lastupdate compare:[NSDate dateWithTimeIntervalSinceNow:-86400]] == NSOrderedAscending || tVersion < kRefreshVersion) {
        [[ResponseHandler instance] readInterests];
        [[NSUserDefaults standardUserDefaults] setInteger:kRefreshVersion forKey:@"RefreshVersion"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"phoneNo"]) {
        [[ResponseHandler instance] checkPhoneNumberFromIndex:0];
        
    }
    [[ResponseHandler instance] readBroadcasts];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [super applicationWillTerminate:application];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    [[C2CallPhone currentPhone] registerAPS:deviceToken];
    
    NSString *msdin = [[NSUserDefaults standardUserDefaults] objectForKey:@"msidn"];
    UpdateAPNSTokenDTO *updateAPNSTokenDTO = [[UpdateAPNSTokenDTO alloc] init];
    updateAPNSTokenDTO.msisdn = msdin;
    updateAPNSTokenDTO.token = deviceToken;
    
    WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
    [serviceHandler execute:METHOD_UPDATE_APNS_TOKEN parameter:updateAPNSTokenDTO target:self action:@selector(updateAPNSTokenResponse:error:)];
}

- (void)updateAPNSTokenResponse:(ResponseBase *)response error:(NSError *)error {
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}


-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    NSLog(@"received notification");
    //handle the notification here
    NSDictionary* message = [userInfo objectForKey:@"aps"];
    NSDictionary* custval = [userInfo objectForKey:@"ubuddcustom"];
    
    if (custval == NULL) {
        [super application:application didReceiveRemoteNotification:userInfo];
    }
    else{
        NSString* noteType = [custval objectForKey:@"type"];
        if([noteType isEqualToString:@"join request"]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Join Request", @"") message:[message objectForKey:@"alert"] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
            [alert show];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Announcement", @"") message:[message objectForKey:@"alert"] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
            [alert show];
        }
        
        UIViewController* mainController = self.window.rootViewController;
        if ([mainController isKindOfClass:[WUChatHistoryController class]]) {
            WUChatHistoryController* chatController = (WUChatHistoryController*)mainController;
            [chatController reloadPage];
        }
        
        
    }
    
    int missedEvents = [[SCDataManager instance] totalMissedCalls] + [[SCDataManager instance] totalMissedMessages];
    
    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
    UITabBarItem *item = [[tabController.viewControllers objectAtIndex:2] tabBarItem];
    
    if (missedEvents == 0)
        item.badgeValue = nil;
    else
        item.badgeValue = [NSString stringWithFormat:@"%d", missedEvents];
    
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    NSUInteger orientations = UIInterfaceOrientationMaskPortrait;
    
    
    
    if(self.window.rootViewController){
        UIViewController *vc = [self findBestViewController: self.window.rootViewController];
        if([vc isKindOfClass:[WUPhotoViewController class]]){
            orientations = UIInterfaceOrientationMaskAllButUpsideDown;
        }
        if([vc isKindOfClass:[WUMovieViewController class]]){
            orientations = UIInterfaceOrientationMaskAllButUpsideDown;
        }
    }
    
    return orientations;
}

-(UIViewController*) findBestViewController:(UIViewController*)vc {
    
    if (vc.presentedViewController) {
        
        // Return presented view controller
        return [self findBestViewController:vc.presentedViewController];
        
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        
        // Return right hand side
        UISplitViewController* svc = (UISplitViewController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.viewControllers.lastObject];
        else
            return vc;
        
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        
        // Return top view
        UINavigationController* svc = (UINavigationController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.topViewController];
        else
            return vc;
        
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        
        // Return visible view
        UITabBarController* svc = (UITabBarController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.selectedViewController];
        else
            return vc;
        
    } else {
        
        // Unknown view controller type, return last child view controller
        return vc;
        
    }
    
}

#pragma mark -
- (void)showHint:(NSString *) message withNotificationType:(SCNotificationType) notificationType
{
    if (notificationType == SC_NOTIFICATIONTYPE_REWARD) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Reward", @"") message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"") message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

#pragma mark - Core Data stack
- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"C2CallDataModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    if (!self.coreDataFile)
        [self locateCoreData];
    
    NSURL *storeURL = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent:self.coreDataFile]];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory
- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

-(void) waitIndicatorConnectingToService
{
    NSLog(@"stupid c2call architecture design");
}
@end