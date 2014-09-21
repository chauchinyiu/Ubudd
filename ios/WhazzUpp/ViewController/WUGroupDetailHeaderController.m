//
//  WUGroupDetailController.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 21/9/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "WUGroupDetailHeaderController.h"
#import "DataRequest.h"
#import "DataResponse.h"
#import "WebserviceHandler.h"
#import "ResponseHandler.h"

@interface WUGroupDetailHeaderController(){
    int interestID;
    NSString* subInterest;
    NSString* topicDesc;
    NSString* location;
}
@end

@implementation WUGroupDetailHeaderController
@synthesize lblTopicDesc, lblLocation, lblInterest, lblSubinterest;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //read from server
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:self.group.groupid forKey:@"c2CallID"];
    
    DataRequest *dataRequest = [[DataRequest alloc] init];
    dataRequest.requestName = @"readGroupInfo";
    dataRequest.values = dictionary;
    
    WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
    [serviceHandler execute:METHOD_DATA_REQUEST parameter:dataRequest target:self action:@selector(readGroupInfo:error:)];
}

- (void)readGroupInfo:(ResponseBase *)response error:(NSError *)error {
    DataResponse *res = (DataResponse *)response;
    
    if (error){
        
    }
    else {
        interestID = [[res.data objectForKey:@"interestID"] integerValue];
        subInterest = [res.data objectForKey:@"interestDescription"];
        topicDesc = [res.data objectForKey:@"topicDescription"];
        location = [res.data objectForKey:@"locationName"];
        [lblTopicDesc setText:topicDesc];
        [lblLocation setText:location];
        [lblInterest setText:[[ResponseHandler instance] getInterestNameForID:interestID]];
        [lblSubinterest setText:subInterest];
            
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
