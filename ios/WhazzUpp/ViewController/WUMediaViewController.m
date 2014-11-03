//
//  WUMediaViewController.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 3/11/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "WUMediaViewController.h"

@interface WUMediaViewController (){
    int fetchLimit, fetchSize;
    BOOL showPreviousMessageButton;
    CFAbsoluteTime lastContentChange, lastSearch;

}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSArray *filterList;
@property (nonatomic, strong) NSMutableDictionary *smallImageCache;

@end

@implementation WUMediaViewController
@synthesize targetUserid, managedObjectContext, filterList, previousMessagesButton,smallImageCache;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (!self.smallImageCache) {
        self.smallImageCache = [NSMutableDictionary dictionaryWithCapacity:50];
    }
    
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    
    [self resetLimits];
    if (!self.fetchedResultsController && [SCDataManager instance].isDataInitialized) {
        [self refreshTable];
    }
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handleNotificationEvent:) name:@"UserImageUpdate" object:nil];
    [nc addObserver:self selector:@selector(handleNotificationEvent:) name:@"C2Call:LogoutUser" object:nil];
    [nc addObserver:self selector:@selector(handleNotificationEvent:) name:@"TransferCompleted" object:nil];
    [nc addObserver:self selector:@selector(handleNotificationEvent:) name:@"UIApplicationDidEnterBackgroundNotification" object:nil];
    
    
    [self.previousMessagesButton setTitle:NSLocalizedString(@"Show previous messages", @"Button") forState:UIControlStateNormal];
    
    NSMutableDictionary *all = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"All", @"Filter"), @"name", @"allFilter", @"filter", nil];
    NSMutableDictionary *image = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Images", @"Filter"), @"name", @"imageFilter", @"filter", nil];
    NSMutableDictionary *video = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Videos", @"Filter"), @"name", @"videoFilter", @"filter", nil];
    NSMutableDictionary *location = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Locations", @"Filter"), @"name", @"locationFilter", @"filter", nil];
    NSMutableDictionary *audio = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Voice Mails", @"Filter"), @"name", @"audioFilter", @"filter", nil];
    NSMutableDictionary *calls = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Calls", @"Filter"), @"name", @"callFilter", @"filter", nil];
    NSMutableDictionary *missed = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Missed", @"Filter"), @"name", @"missedFilter", @"filter", nil];
    
    self.filterList = [NSArray arrayWithObjects:all, image, video, location, audio, calls, missed, nil];
    
    int active = 0;//[[[NSUserDefaults standardUserDefaults] objectForKey:@"activeStreamFilter"] intValue];
    if (active >= [self.filterList count])
        active = 0;
    
    [[self.filterList objectAtIndex:active] setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSFetchRequest *) fetchRequest
{
    if (![SCDataManager instance].isDataInitialized)
        return nil;
    
    self.sectionNameKeyPath = nil;
    self.useDidChangeContentOnly = YES;
    
    NSFetchRequest *fetchRequest = [[SCDataManager instance] fetchRequestForEventHistory:nil sort:YES];
    
    NSPredicate *predicate = nil;
    
    predicate = [NSPredicate predicateWithFormat:@"contact == %@ AND eventType contains[cd] %@", self.targetUserid, @"message"];
    
    [fetchRequest setPredicate:predicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    int offset = 0;
    if (fetchLimit > 0) {
        offset = [[SCDataManager instance] setFetchLimit:fetchLimit forFetchRequest:fetchRequest];
    }
    
    showPreviousMessageButton = offset > 0;

    return fetchRequest;
}


-(void) refetchResults
{
    NSFetchRequest *fetchRequest = [self.fetchedResultsController fetchRequest];
    [fetchRequest setFetchLimit:0];
    [fetchRequest setFetchOffset:0];
    
    NSError *error = nil;
    int numElements = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    int offset = MAX(0, numElements - fetchLimit);
    
    [fetchRequest setFetchLimit:fetchLimit];
    [fetchRequest setFetchOffset:offset];
    showPreviousMessageButton = offset > 0;
    
    error = nil;
    [self.fetchedResultsController performFetch:&error];
    
    [self refreshFilterInfo];
    [self refreshTable];
}

-(void) resetLimits
{
    fetchLimit = 25;
    fetchSize = 25;
}

-(void) refreshFilterInfo
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.selected = YES"];
    NSArray *selected = [self.filterList filteredArrayUsingPredicate:predicate];
    
    NSString *activeFilterName = nil;
    if ([selected count] > 0) {
        if (![[[selected objectAtIndex:0] objectForKey:@"filter"] isEqualToString:@"allFilter"]) {
            activeFilterName = [[selected objectAtIndex:0] objectForKey:@"name"];
        }
    }
    
    NSString *filterText = nil; //self.searchField.text;
    if ([filterText length] == 0)
        filterText = nil;
    
    
}

-(void) refreshTable
{
    lastContentChange = CFAbsoluteTimeGetCurrent();
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (CFAbsoluteTimeGetCurrent() - lastContentChange > 0.15) {
            [self.tableView reloadData];
            
        }
    });
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
