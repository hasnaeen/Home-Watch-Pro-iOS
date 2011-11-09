//
//  LoginViewController.h
//  HomeWatchPro
//
//  Created by Stitz on 6/23/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlertManager.h"
#import "LoginManager.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate> {
    
    UIButton                *btnLogin;
    UIButton                *btnCancel;
    UIButton                *btnForgotPassword;
    UIButton                *btnWhatIsHomeWatchPro;
    UIButton                *btnClearKey;
    
    UIScrollView            *myScrollView;
    
    UITextField             *txtEmailAddress;
	UITextField             *txtPassword;
    UITextField             *txtAccessKey;
    
    UILabel                 *lblAccessKey;
    UILabel                 *lblAccessKey1;
 
    
    BOOL accesskeyIsSaved;
    AlertManager *alertManager;
    LoginManager *loginManager;
}

@property (nonatomic, retain) IBOutlet UITextField	*txtEmailAddress;
@property (nonatomic, retain) IBOutlet UITextField	*txtPassword;
@property (nonatomic, retain) IBOutlet UITextField	*txtAccessKey;
@property (nonatomic, retain) IBOutlet UILabel *lblAccesskey;
@property (nonatomic, retain) IBOutlet UILabel *lblAccesskey1;

@property (nonatomic,retain) IBOutlet UIButton *btnLogin;
@property (nonatomic,retain) IBOutlet UIButton *btnCancel;
@property (nonatomic,retain) IBOutlet UIButton *btnForgotPassword;
@property (nonatomic,retain) IBOutlet UIButton *btnWhatIsHomeWatchPro;
@property (nonatomic, retain) IBOutlet UIButton *btnClearKey;
@property (nonatomic,retain) IBOutlet UIScrollView *myScrollView;
@property (nonatomic,retain) IBOutlet AlertManager *alertManager; 
@property (nonatomic,retain) IBOutlet LoginManager *loginManager;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property BOOL accessKeyIsSaved;

- (IBAction)login;
- (IBAction)Clear;
- (IBAction)linkClicked:(id)sender;

- (void)handleError:(NSError *)error;
- (void)resignFirstRepsonders;
- (BOOL)LoginTask;

@end
