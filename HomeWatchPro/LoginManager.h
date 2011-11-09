//
//  LoginManager.h
//  HomeWatchPro
//
//  Created by USER on 6/26/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LoginManager : NSObject {
    BOOL hasShownAlert;
}

@property (assign) BOOL hasShownAlert;
- (BOOL)Login:(NSString *)userName Password:(NSString *)password Key:(NSString *)key;

@end
