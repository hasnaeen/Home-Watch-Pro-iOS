//
//  AlertManager.m
//  HomeWatchPro
//
//  Created by USER on 6/26/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import "AlertManager.h"


@implementation AlertManager

- (void)loginFailedAlert {
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle:@"Missing Information" 
                          message:@"You must enter your username, accessKey and password. Please try again."
                          delegate:self 
                          cancelButtonTitle:@"Close" 
                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)invalidLoginAlert {
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle:@"Invalid Credentials" 
                          message:@"Please check your credentials and try again."
                          delegate:self 
                          cancelButtonTitle:@"Close" 
                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)invalidUsernameAlert {
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle:@"Invalid Username" 
                          message:@"You username was invalid. Please try again."
                          delegate:self 
                          cancelButtonTitle:@"Close" 
                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)invalidPasswordAlert {
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle:@"Invalid Password" 
                          message:@"Your password was invalid. Please try again."
                          delegate:self 
                          cancelButtonTitle:@"Close" 
                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)showAlert:(NSString *)message Title:(NSString *)title
{
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle:title 
                          message:message
                          delegate:self 
                          cancelButtonTitle:@"Close" 
                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

@end
