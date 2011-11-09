//
//  InspectionsViewController.m
//  HomeWatchPro
//
//  Created by Stitz on 6/23/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import "InspectionsViewController.h"
#import "LoginViewController.h"
#import "AlertManager.h"
#import "UserDataManager.h"
#import "TableCellView.h"
#import "LoadDataManager.h"
#import "CoreDataManager.h"
#import "Inspections.h"
#import "MBProgressHUD.h"
#import "InspectionItemViewController.h"
#import "InspectionSubmitManager.h"
#import "FileManager.h"

@implementation InspectionsViewController


@synthesize fetchedResultsController=__fetchedResultsController;

@synthesize managedObjectContext=__managedObjectContext;

//@synthesize myScrollView;
@synthesize tblSimpleTable,tblCell,inspectionArray,currentStatus,hasInspection;
@synthesize segmentControl,refreshTimer,timerCount;
@synthesize inspectionSubmitManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    
    [__fetchedResultsController release];
    [__managedObjectContext release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle

bool _hasLogin = NO;
bool _hasLoadData = NO;
bool _initialLoadComplete = NO;
bool _isReloading = NO;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    //Check to see if user is logged in. If not, push the login view below...
    NSLog(@"--Need to check if the user is already logged in. If they are not, they need to see the login view displayed below.");
    NSLog(@"App Launched, Push Login View to front as a Modal...");
    
    [self ReloadView];
}

-(void)ReloadView
{
    if(_hasLogin == NO)
    {
        if(refreshTimer != nil)
        {
            [refreshTimer invalidate];
            self.refreshTimer = nil;
        }
        
        LoginViewController *launchView = [[LoginViewController alloc] initWithNibName: @"LoginViewController" bundle:nil];
        launchView.managedObjectContext = __managedObjectContext;
        [self.navigationController presentModalViewController: launchView animated:NO];
        [launchView release];
        _hasLogin = YES;
    }
    else if(_hasLoadData == NO)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        _isReloading = NO;
        [self Reload];
        _hasLoadData = YES;
    }
}



-(void)Reload
{
    if(refreshTimer != nil)
    {
        [refreshTimer invalidate];
        self.refreshTimer = nil;
    }
    
    NSDateFormatter *date_formater=[[NSDateFormatter alloc]init];
    [date_formater setDateFormat:@"MMMM dd, YYYY"];
    NSDate *now = [NSDate date];
    lblDate.text = [date_formater stringFromDate:now];
    #ifdef __BLOCKS__
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading Data";
    lblTimer.text = @"";
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{        
        BOOL isLoaded = NO;        
        LoadDataManager *loadDataManager = [LoadDataManager alloc];
        [loadDataManager Context:__managedObjectContext]; 
        
        @try {
        
        isLoaded = [loadDataManager LoadInspectionsAndItems];
        
            if(isLoaded == YES)
            {
                [loadDataManager LoadMediaObject];
                
                CoreDataManager *dataManager = [CoreDataManager alloc];
                [dataManager Context:__managedObjectContext]; 
                NSMutableArray *inspectionsQueued = [[NSMutableArray alloc] initWithArray:[dataManager GetAllInspectionByStatus:@"Queued"]];                
                
                if([inspectionsQueued count]>0)
                [self SubmitInspections];
                else if([[dataManager GetAllHoldInspection] count]==0)
                {
                    FileManager *fileManager = [FileManager alloc];
                    [fileManager RemoveAllFile];
                }
                
                sleep(1);
            }
        }
        @catch (NSException *exception) {
            AlertManager *alert = [AlertManager alloc];
            [alert showAlert:[NSString stringWithFormat:@"%@",exception] Title:@"Error"];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            CoreDataManager *dataManager = [CoreDataManager alloc];
            [dataManager Context:__managedObjectContext]; 
            
            if([currentStatus isEqualToString: @"All"]==TRUE)
                inspectionArray = [dataManager GetFourTypeInspection];
            else
                inspectionArray = [dataManager GetAllInspectionByStatus:currentStatus];
            
            _initialLoadComplete = YES;
            [tblSimpleTable reloadData];
            
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:60
                                                              target:self selector:@selector(timerFireMethod:)
                                                            userInfo:nil repeats:YES];
            self.refreshTimer = timer;
            
            if(isLoaded == NO && _isReloading == YES)
            {
                lblTimer.text =[NSString stringWithFormat:@"Last updated %d minutes ago. Click on the Refresh button to reload the list.",timerCount];
                //LoadDataManager *loadDataManager = [LoadDataManager alloc];
                //[loadDataManager Context:__managedObjectContext]; 
                
                BOOL isInternateAvailable = [loadDataManager IsInternateAvailable];
                
                AlertManager *alert = [AlertManager alloc];
                
                if(isInternateAvailable == NO)
                    [alert showAlert:@"Unable to connect. Please check your connection and try again." Title:@"Connection Error"];
                else
                    [alert showAlert:[NSString stringWithFormat:@"%@",[loadDataManager error]] Title:@"Connection Error"];
            }
            else
            {
                timerCount = 0;
                lblTimer.text = @"Last updated less than a minute ago. Click on the Refresh button to reload the list.";
            }
            
            _isReloading = NO;
        });
    }); 
    #endif
}

-(void)ReloadTableItem
{
    CoreDataManager *dataManager = [CoreDataManager alloc];
    [dataManager Context:__managedObjectContext]; 
    
    if([currentStatus isEqualToString: @"All"]==TRUE)
        inspectionArray = [dataManager GetFourTypeInspection];
    else
        inspectionArray = [dataManager GetAllInspectionByStatus:currentStatus];
    
    _initialLoadComplete = YES;
    [tblSimpleTable reloadData];
}

- (void)timerFireMethod:(NSTimer*)theTimer
{
    timerCount = timerCount + 1;
    lblTimer.text =[NSString stringWithFormat:@"Last updated %d minutes ago. Click on the Refresh button to reload the list.",timerCount];
    
    [self SubmitInspections];
    if(inspectionSubmitManager.hasSubmit == YES)
    {
        [self ReloadTableItem];
        inspectionSubmitManager.hasSubmit = NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:YES];
    
    //[myScrollView setContentSize:CGSizeMake(320, 550)];
    
    //tblSimpleTable.backgroundColor = [UIColor clearColor];
    //[lblAssign setBackgroundColor:[UIColor clearColor]];
    //[lblDate setBackgroundColor:[UIColor clearColor]];
    
    //[tblSimpleTable setRowHeight: 43];
    inspectionSubmitManager = NULL;
    inspectionArray = [[NSMutableArray alloc] initWithObjects: nil];
    currentStatus = @"All";
    
    CGRect boun = segmentControl.frame;
    boun.size.height = 41;
    segmentControl.frame = boun;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)LogoutClicked:(id)sender
{
    _hasLogin = NO;
    _hasLoadData = NO;
    _initialLoadComplete = NO;
    currentStatus = @"All";
    [segmentControl setImage:[UIImage imageNamed:@"assigned.png"] forSegmentAtIndex:0];
    [segmentControl setImage:[UIImage imageNamed:@"queued.png"] forSegmentAtIndex:1];
    [segmentControl setImage:[UIImage imageNamed:@"received.png"] forSegmentAtIndex:2];
    [segmentControl setImage:[UIImage imageNamed:@"rejected.png"] forSegmentAtIndex:3];  
    inspectionArray = [[NSMutableArray alloc] initWithObjects: nil];
    [tblSimpleTable reloadData];
    [self ReloadView];
}

- (IBAction)RefreshClicked:(id)sender
{
    _isReloading = YES;
    [self Reload];
}

- (IBAction)segmentedControlValueChanged
{
   int index =  segmentControl.selectedSegmentIndex;
    
    
    [segmentControl setImage:[UIImage imageNamed:@"assigned.png"] forSegmentAtIndex:0];
    [segmentControl setImage:[UIImage imageNamed:@"queued.png"] forSegmentAtIndex:1];
    [segmentControl setImage:[UIImage imageNamed:@"received.png"] forSegmentAtIndex:2];
    [segmentControl setImage:[UIImage imageNamed:@"rejected.png"] forSegmentAtIndex:3];    
    
    CoreDataManager *dataManager = [CoreDataManager alloc];
    [dataManager Context:__managedObjectContext]; 
    segmentControl.selectedSegmentIndex = -1;
    
    switch (index) {
        case 0:
            inspectionArray = [dataManager GetAllInspectionByStatus:@"Assigned"];
            [segmentControl setImage:[UIImage imageNamed:@"assigned_mo.png"] forSegmentAtIndex:0];
            currentStatus = @"Assigned";
            break;
        case 1:
            inspectionArray = [dataManager GetAllInspectionByStatus:@"Queued"];
            [segmentControl setImage:[UIImage imageNamed:@"queued_mo.png"] forSegmentAtIndex:1];
            currentStatus = @"Queued";            
            break;
        case 2:
            inspectionArray = [dataManager GetAllInspectionByStatus:@"Received"];
            [segmentControl setImage:[UIImage imageNamed:@"received_mo.png"] forSegmentAtIndex:2];
            currentStatus = @"Received";
            break;
        case 3:
            inspectionArray = [dataManager GetAllInspectionByStatus:@"Rejected"];
            [segmentControl setImage:[UIImage imageNamed:@"rejected_mo.png"] forSegmentAtIndex:3];   
            currentStatus = @"Rejected";
            break;
            
        default:
            break;
    }
    
    [tblSimpleTable reloadData];
    
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([inspectionArray count]>0)
    {
        hasInspection = YES;
        return [inspectionArray count];
    }
    else
    {
        if(_initialLoadComplete == NO)
            return 0;
        hasInspection = NO;
        return 1;
    }
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString *MyIdentifier = @"MyIdentifier";
	MyIdentifier = @"tblCellView";
    
    Inspections *item = [[Inspections alloc] init];
    if(hasInspection == YES)
    item = [inspectionArray objectAtIndex:indexPath.row];
    
	TableCellView *cell = (TableCellView *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if(cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"TableCellView" owner:self options:nil];
		cell = tblCell;
	}
	
    
    if(indexPath.row == 0 && (indexPath.row == [inspectionArray count] - 1 || hasInspection == NO))
    {
        if(hasInspection == NO)
            [cell setBackGroundImage:@"bar_without_arrow.png"];
        else
            [cell setBackGroundImage:@"bar.png"];
    }
    else if(indexPath.row == 0)
    {
        [cell setBackGroundImage:@"top_curve.png"];
    }
    else if(indexPath.row == [inspectionArray count] - 1)
    {
        [cell setBackGroundImage:@"bottom_curve.png"];
    }
    else
    {
        [cell setBackGroundImage:@"middle_bar.png"];
	}
    
    if(hasInspection == YES)
    {
        [cell setLabelText:[item Property]];
        
        if([item.IsQueued isEqualToNumber: [NSNumber numberWithBool:YES]]==TRUE)
            [cell setStatus:@"Queued"];
        else
            [cell setStatus:[item Status]];
    }
    else
    {
        NSString *labelShow = [NSString stringWithFormat:@"No %@ Inspections Found.",currentStatus];
        
        if([currentStatus isEqualToString: @"All"]==TRUE)
            labelShow = @"No Inspections Found.";
        
        [cell setLabelText:labelShow];
        [cell setStatus:@"Not Found"];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tabelView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat result = 43;
	return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    if(hasInspection == YES)
    {
        Inspections *item = [[Inspections alloc] init];
        item = [inspectionArray objectAtIndex:indexPath.row];
        
        InspectionItemViewController *childController = [[InspectionItemViewController alloc] init];
        childController.hidesBottomBarWhenPushed = YES;
        childController.currentInspectionID = [item InspectionID];
        [childController Context: __managedObjectContext];
        [self.navigationController pushViewController:childController animated:YES];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [InspectionItemViewController release];        
    }
}

- (void)SubmitInspections
{
    if(inspectionSubmitManager == NULL)
    {
        inspectionSubmitManager = [InspectionSubmitManager alloc];
        inspectionSubmitManager.hasSubmit = NO;
    }
    
    [inspectionSubmitManager Context: __managedObjectContext];
    [inspectionSubmitManager SubmitInspection];
}

@end
