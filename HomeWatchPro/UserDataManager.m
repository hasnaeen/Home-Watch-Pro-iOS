//
//  UserDataManager.m
//  HomeWatchPro
//
//  Created by USER on 6/26/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import "UserDataManager.h"


@implementation UserDataManager

//Method to save a value to the NSUserDefaults
-(void)saveToUserDefaults:(NSString*)myString forKey:(NSString *)key {
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	if (standardUserDefaults) {
		[standardUserDefaults setObject:myString forKey:key];
		[standardUserDefaults synchronize];
	}
}

//Method to retreive the "Inspector's" user name from the NSUserDefaults
//This method could be easily modified to pass in the key to retreive the value for
-(void)SaveUsername:(NSString*)myString
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	if (standardUserDefaults) {
		[standardUserDefaults setObject:myString forKey:@"inspectorUserName"];
		[standardUserDefaults synchronize];
	}
}

-(void)SavePassword:(NSString*)myString
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	if (standardUserDefaults) {
		[standardUserDefaults setObject:myString forKey:@"password"];
		[standardUserDefaults synchronize];
	}
}

-(void)SaveAccessKey:(NSString*)myString
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	if (standardUserDefaults) {
		[standardUserDefaults setObject:myString forKey:@"accessKey"];
		[standardUserDefaults synchronize];
	}
}

-(void)SaveUserActivate
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	if (standardUserDefaults) {
		[standardUserDefaults setObject:@"YES" forKey:@"userKeyActivated"];
		[standardUserDefaults synchronize];
	}
}

-(void)SaveUserDeactive
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	if (standardUserDefaults) {
		[standardUserDefaults setObject:@"NO" forKey:@"userKeyActivated"];
		[standardUserDefaults synchronize];
	}
}

-(NSString*)retrieveUsername {
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	NSString *val = nil;
	
	if (standardUserDefaults) 
		val = [standardUserDefaults objectForKey:@"inspectorUserName"];
	
	return val;
}

-(NSString*)retrievePassword {
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	NSString *val = nil;
	
	if (standardUserDefaults) 
		val = [standardUserDefaults objectForKey:@"password"];
	
	return val;
}

-(NSString*)retrieveAccessKey {
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	NSString *val = nil;
	
	if (standardUserDefaults) 
		val = [standardUserDefaults objectForKey:@"accessKey"];
	
	return val;
}

-(NSString*)retrieveIsKeyActivated {
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	NSString *val = nil;
	
	if (standardUserDefaults) 
		val = [standardUserDefaults objectForKey:@"userKeyActivated"];
	
	return val;
}

@end
