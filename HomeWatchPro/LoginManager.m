//
//  LoginManager.m
//  HomeWatchPro
//
//  Created by USER on 6/26/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import "LoginManager.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "UserDataManager.h"
#import "JSON/JSON.h"
#import "AlertManager.h"

@implementation LoginManager

@synthesize hasShownAlert;
bool _isSuccess = FALSE;

- (BOOL)Login:(NSString *)userName Password:(NSString *)password Key:(NSString *)key
{
    _isSuccess = NO;
    hasShownAlert = NO;
    NSString *userAPIKey = key;
    NSString *serviceUrl = [NSString stringWithFormat:@"http://api.hwptest.info/services/authentication/%@", userAPIKey];
    NSURL *url = [NSURL URLWithString:serviceUrl];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setPostValue:userName forKey:@"username"];
    [request setPostValue:password forKey:@"password"];
    
    UserDataManager *dataManager = [UserDataManager alloc];
       
    
    if ([[dataManager retrieveIsKeyActivated] isEqualToString: @"YES"] == TRUE) {
        [request setPostValue:@"false" forKey:@"firstTime"];
    } else {
        [request setPostValue:@"True" forKey:@"firstTime"];
    }
    
    [request setTimeOutSeconds:60];
    
    [request setCompletionBlock:^{
        NSString *responseString = [request responseString];
        NSDictionary *dictionary = [responseString JSONValue];
        NSArray *output = [dictionary allValues]; 
        NSString *p1 = [[output objectAtIndex:0] stringValue];
        
        if([p1 isEqualToString:@"1"] == TRUE)
        {
            _isSuccess = YES;
            //AlertManager *alertManager = [AlertManager alloc];
            //[alertManager showAlert:[NSString stringWithFormat:@"%d",_isSuccess] Title:@"hi"];
        }
    }];
    [request setFailedBlock:^{
        //NSError *error = [request error];
        
        if ([[dataManager retrieveIsKeyActivated] isEqualToString: @"YES"] == TRUE) {
            if([[dataManager retrieveUsername] isEqualToString: userName] == TRUE
               && [[dataManager retrievePassword] isEqualToString: password] == TRUE
               && [[dataManager retrieveAccessKey] isEqualToString: key] == TRUE
               )
                _isSuccess = YES;
        }
        else
        {
            hasShownAlert = TRUE;
            AlertManager *alertManager = [AlertManager alloc];
            [alertManager showAlert:@"You need to check your credentials and try again." Title:@"Connection Error"];
            [alertManager release];
        }
    }];
    [request startSynchronous];
    
    sleep(1);
    return _isSuccess;
}

@end
