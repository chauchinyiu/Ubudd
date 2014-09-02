//
//  ResponseHandler.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 2/9/14.
//  Copyright (c) 2014年 3Embed Technologies. All rights reserved.
//

#import "ResponseHandler.h"
#import "WebserviceHandler.h"
#import "ServiceURL.h"
#import "ResponseBase.h"

#import "VerifyC2CallID.h"
#import "VerifyC2CallIDDTO.h"

@implementation ResponseHandler

-(void)verifyC2CallID:(NSString*)c2CallID{
    VerifyC2CallIDDTO *vDTO = [[VerifyC2CallIDDTO alloc] init];
    vDTO.c2CallID = c2CallID;
    
    WebserviceHandler *serviceHandler = [[WebserviceHandler alloc] init];
    [serviceHandler execute:METHOD_VERIFY_C2CALLID parameter:vDTO target:self action:@selector(verifyC2CallResponse:error:)];
}

- (void)verifyC2CallResponse:(ResponseBase *)response error:(NSError *)error {
    VerifyC2CallID *vOBj = (VerifyC2CallID *)response;
    
    if (error){
    }
    else{
        NSString* keyName = [NSString stringWithFormat:@"verified_%@", [vOBj c2CallID]];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:keyName];
        keyName = [NSString stringWithFormat:@"verifyResult_%@", [vOBj c2CallID]];
        [[NSUserDefaults standardUserDefaults] setInteger:vOBj.resultCode forKey:keyName];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(BOOL)c2CallIDVerified:(NSString*)c2CallID{
    NSString* keyName = [NSString stringWithFormat:@"verified_%@", c2CallID];
    return [[NSUserDefaults standardUserDefaults] boolForKey:keyName];
}

-(BOOL)c2CallIDPassed:(NSString*)c2CallID{
    NSString* keyName = [NSString stringWithFormat:@"verified_%@", c2CallID];
    if([[NSUserDefaults standardUserDefaults] boolForKey:keyName]){
        keyName = [NSString stringWithFormat:@"verifyResult_%@", c2CallID];
        return ([[NSUserDefaults standardUserDefaults] integerForKey:keyName] == 1);
    }
    return NO;
}

@end
