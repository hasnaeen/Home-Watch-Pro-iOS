//
//  AlertManager.h
//  HomeWatchPro
//
//  Created by USER on 6/26/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AlertManager : NSObject {
        
}

- (void)loginFailedAlert;
- (void)invalidUsernameAlert;
- (void)invalidPasswordAlert;
- (void)showAlert:(NSString *)message Title:(NSString *)title;
- (void)invalidLoginAlert;

@end
