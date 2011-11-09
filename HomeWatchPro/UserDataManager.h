//
//  UserDataManager.h
//  HomeWatchPro
//
//  Created by USER on 6/26/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UserDataManager : NSObject {
    
}

- (void)saveToUserDefaults:(NSString*)myString forKey:(NSString *)key;

-(void)SaveUsername:(NSString*)myString;
-(void)SavePassword:(NSString*)myString;
-(void)SaveAccessKey:(NSString*)myString;
-(void)SaveUserActivate;
-(void)SaveUserDeactive;

-(NSString*)retrieveUsername;
-(NSString*)retrievePassword;
-(NSString*)retrieveAccessKey;
-(NSString*)retrieveIsKeyActivated;

@end
