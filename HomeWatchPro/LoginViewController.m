//
//  LoginViewController.m
//  HomeWatchPro
//
//  Created by Stitz on 6/23/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import "LoginViewController.h"
#import "WebViewController.h"
#import "AlertManager.h"
#import "LoginManager.h"
#import "UserDataManager.h"
#import "MBProgressHUD.h"
#import "CoreDataManager.h"

#define kWhatIsHomeWatchPro @"http://www.hwptest.info"
#define kForgotPasswordLink @"http://www.hwptest.info"


@implementation LoginViewController

@synthesize txtEmailAddress, txtPassword, btnLogin, btnCancel, btnForgotPassword, btnWhatIsHomeWatchPro;
@synthesize lblAccesskey,btnClearKey,accessKeyIsSaved;
@synthesize myScrollView, txtAccessKey,alertManager,loginManager,lblAccesskey1;
@synthesize managedObjectContext=__managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    [super dealloc];

    [txtEmailAddress release];
    [txtPassword release];
    [txtAccessKey release];
    [btnLogin release];
    [btnCancel release];
    [btnForgotPassword release];
    [btnWhatIsHomeWatchPro release];
    [alertManager release];
    [loginManager release];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)handleError:(NSError *)error {	
	NSString *statusString = @"Sorry, we were unable to process your request. Please try again later.";
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Error" message:statusString delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
	
	[alertView show];
    [alertView release];
    
}

- (void)resetScrollView {
    [myScrollView scrollRectToVisible:CGRectMake(0, 0, 320, 480) animated:YES];
}

- (void)resignFirstRepsonders {
    [txtPassword resignFirstResponder];
    [txtEmailAddress resignFirstResponder];
    [txtAccessKey resignFirstResponder];
    [self resetScrollView];
}


//Populates the NSUserDefault of inspectorEmailAddress
- (void)populateUsernameField {
    UserDataManager *dataManager = [UserDataManager alloc];    
    
    if ([[dataManager retrieveIsKeyActivated] isEqualToString: @"YES"] == TRUE) {
        txtAccessKey.text = [dataManager retrieveAccessKey];
        txtAccessKey.hidden = TRUE;
        //lblAccesskey.text = [dataManager retrieveAccessKey];
        lblAccesskey.hidden = FALSE;
        lblAccesskey1.hidden = FALSE;
        
        btnClearKey.hidden = FALSE;
        
        txtPassword.returnKeyType = UIReturnKeyGo;
        txtEmailAddress.text = [dataManager retrieveUsername];
        accessKeyIsSaved = YES;
        
        //txtPassword.text = [dataManager retrievePassword]; 
    }
    else
    {
        lblAccesskey.hidden = TRUE;
        lblAccesskey1.hidden = TRUE;
        txtAccessKey.text = @"";
        txtPassword.returnKeyType = UIReturnKeyNext;
        btnClearKey.hidden = TRUE;
        txtAccessKey.hidden = FALSE;
        accessKeyIsSaved = NO;
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField becomeFirstResponder];
    [myScrollView scrollRectToVisible:CGRectMake(0, 200, 320, 480) animated:YES];
    
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
	NSInteger nextTag = textField.tag + 1;
	
	// Try to find next responder
	UIResponder *nextResponder = [textField.superview viewWithTag:nextTag];
	if (nextResponder && !(accessKeyIsSaved == YES && textField.tag == 1)) {
		[nextResponder becomeFirstResponder];
	} else {
        [self login];
	}
	return NO; 
}

- (IBAction) Clear
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Warning!"
                                                    message:@"Are you sure you would like to clear the Activation Key? All of the application's information you have stored locally will be removed."
                                                   delegate:self    
                                          cancelButtonTitle:@"Cancel" 
                                          otherButtonTitles:@"OK", nil   ];
    [alert show];
    [alert release];    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0)
    {
        
    }
    else
    {
        CoreDataManager *coreDataManager = [CoreDataManager alloc];
        [coreDataManager Context:__managedObjectContext];
        [coreDataManager DeleteAllInspections];
        [coreDataManager DeleteAllInspectionItem];
        [coreDataManager DeleteAllMediaObject];
        
        UserDataManager *dataManager = [UserDataManager alloc];
        [dataManager SaveUserDeactive];
        [self populateUsernameField];     
    }
}

- (IBAction)linkClicked:(id)sender {
    UIButton *button = (UIButton *)sender;
    WebViewController *webController = [[WebViewController alloc] init];
    if (button == btnForgotPassword) {
        webController.urlString = kForgotPasswordLink;
    } else if (button == btnWhatIsHomeWatchPro) {
        webController.urlString = kWhatIsHomeWatchPro;
    } 
    [self presentModalViewController:webController animated:YES];
    [webController release];
}

bool hasShownAlert = NO;
- (IBAction)login {
    [self resignFirstRepsonders];
    
    NSString *emailAddress = txtEmailAddress.text;
    NSString *password = txtPassword.text;
    NSString *accessKey = txtAccessKey.text;    
    
    if([emailAddress length]  == 0 || [password length] == 0 || [accessKey length]==0)
    {
        self.alertManager = [AlertManager alloc];
        [alertManager loginFailedAlert];
        [alertManager release];
    }
    else
    {
    #ifdef __BLOCKS__
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	hud.labelText = @"Loading";
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		BOOL yes = [self LoginTask];
		
        dispatch_async(dispatch_get_main_queue(), ^{
			[MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if(yes == YES)
            {
                UserDataManager *dataManager = [UserDataManager alloc];
                [dataManager SaveUserActivate];
                [dataManager SaveUsername:emailAddress];
                [dataManager SavePassword:password];
                [dataManager SaveAccessKey:accessKey];
                [dataManager release];
                self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                [self dismissModalViewControllerAnimated:YES];
            }
            else if(hasShownAlert == NO)
            {
                self.alertManager = [AlertManager alloc];
                [alertManager invalidLoginAlert];
                [alertManager release];
            }
		});
	}); 
        #endif
    }
    
    //check the length of email, password, and access key to make sure they are valid
    //if access key is in the NSUserDefaults, you know to pass a false for firstTime, else pass in true.
    //Use ASIHttpRequest to call webservice and JSON to parse response USE "Blocks" for ASI so you do not need the delegate methods.
    //Once successfully authenticated, save all 3 items of data to NSUserDefaults and dismiss the modal view controller
    //The saved username and password will allow for a "offline" login to be done of the user does not have connectivity.
    //The offiline login will trap the user if the ASIHttpRequest fails and then check the credentials against the local NSUserDefaults. If there is a match,
    //  let the user in.
    //If the credentials fail both online (and offline of tried) a uiAlertView will display letting them know they need to check their credentials and try again.
    //Once authenticated, set the ModalTransitionStyle and dismiss the modal as seen below
    
    //It is ok to have the LoginViewController called each the InspectionsViewController is called (viewWillAppear) that way the user will have to authenticate each time they close the app for security reasons.
    
    
    //Once authenticated, you will present the user with the primary list of inspections. 
    
    //This view will need to do an initial download of all inspections from the web service and will push them into the core data object model. During that synch it will need to check if the record exists, comparing the dates of the local records to the web service records and update or create as needed, updating the LastModified date as needed.
        
    //All editing of the inspections will happen offline and will work directly with the local CoreData objects and local files. Once a inspection is submitted, it will need to be queued to be uploaded via the web service. This will need to die gracefully so that a user can try and submit but try it again later if it fails.
}


-(BOOL)LoginTask
{
    NSString *emailAddress = txtEmailAddress.text;
    NSString *password = txtPassword.text;
    NSString *accessKey = txtAccessKey.text;
   
    self.loginManager = [LoginManager alloc];
    BOOL isSuccessLogin = [loginManager Login:emailAddress Password:password Key:accessKey];
    hasShownAlert = [loginManager hasShownAlert];
    return isSuccessLogin;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    txtAccessKey.borderStyle = UITextBorderStyleNone;
    txtEmailAddress.borderStyle = UITextBorderStyleNone;
    txtPassword.borderStyle = UITextBorderStyleNone;
    
    UIView *paddingViewAK = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    UIView *paddingViewEA = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    UIView *paddingViewP = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    
    
    txtAccessKey.leftView = paddingViewAK;
    txtAccessKey.leftViewMode = UITextFieldViewModeAlways;
    
    txtEmailAddress.leftView = paddingViewEA;
    txtEmailAddress.leftViewMode = UITextFieldViewModeAlways;
    
    txtPassword.leftView = paddingViewP;
    txtPassword.leftViewMode = UITextFieldViewModeAlways;   
    
    [paddingViewAK release];
    [paddingViewEA release];
    [paddingViewP release];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self populateUsernameField];
    [myScrollView setContentSize:CGSizeMake(320, 550)];
    myScrollView.showsHorizontalScrollIndicator = FALSE;
    myScrollView.showsVerticalScrollIndicator = FALSE;
    myScrollView.scrollEnabled = FALSE;
    myScrollView.bounces = FALSE;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.txtEmailAddress = nil;
    self.txtPassword = nil;
    self.txtAccessKey = nil;
    self.btnLogin = nil;
    self.btnForgotPassword = nil;
    self.btnWhatIsHomeWatchPro = nil;
    self.myScrollView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
