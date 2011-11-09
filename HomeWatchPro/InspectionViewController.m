//
//  InspectionViewController.m
//  HomeWatchPro
//
//  Created by USER on 7/17/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import "InspectionViewController.h"
#import "CoreDataManager.h"
#import "InspectionsViewController.h"
#import "MBProgressHUD.h"
#import "AlertManager.h"
#import "InspectionItem.h"
#import "InspectionItemViewController.h"
#import "MapViewController.h"

@implementation InspectionViewController

@synthesize currentInspectionID,currentInspection;
@synthesize managedObjectContext=__managedObjectContext;

-(void)Context:(NSManagedObjectContext *) context
{
    self.managedObjectContext = context;
}

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
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CoreDataManager *dataManager = [CoreDataManager alloc];
    [dataManager Context:__managedObjectContext]; 
    
    NSMutableArray *data = [dataManager GetInspectionByID:currentInspectionID];
    
    if([data count]>0)
        currentInspection = (Inspections*) [data objectAtIndex:0];
    else
        currentInspection = NULL;
    
    [self Reload];
    // Do any additional setup after loading the view from its nib.
}

- (void)Reload
{
    if([[currentInspection IsQueued] isEqualToNumber: [NSNumber numberWithBool:YES]]==TRUE || [currentInspection.Status isEqualToString:@"Received"]==TRUE)
    {
        btnMakeAllOk.hidden = TRUE;
        btnSubmitInspection.hidden = TRUE;
        CGRect frame = btnCancel.frame;
        frame.origin.y = 199;
        btnCancel.frame = frame;
    }
    else
    {
        btnMakeAllOk.hidden = FALSE;
        btnSubmitInspection.hidden = FALSE;
        CGRect frame = btnCancel.frame;
        frame.origin.y = 285;
        btnCancel.frame = frame;
    }
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

- (IBAction)ButtonClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if(button == btnCancel)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(button == btnSubmitInspection)
    {
        [self PrepareForSubmitInspection];
    }
    else if(button == btnMakeAllOk)
    {   
        CoreDataManager *dataManager = [CoreDataManager alloc];
        [dataManager Context:__managedObjectContext];
        NSMutableArray *inspectionItemArray = [dataManager AllInspectionItemsByInspectionID:currentInspectionID];    
        
        for (int i=0;i<[inspectionItemArray count];i++) {
            InspectionItem *item = [[InspectionItem alloc] init];
            item = [inspectionItemArray objectAtIndex:i];
            
            if([item.Status isEqualToString:@"None"]==TRUE)
                [item setStatus:@"Okay"];
        }
        
        [dataManager SaveObjectContext];
        [dataManager release]; 
        
        InspectionItemViewController *parent = (InspectionItemViewController*)[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-2];
        [parent Reload];
    }
    else if(button == btnMap)
    {
        MapViewController *childController = [[MapViewController alloc] init];
        childController.hidesBottomBarWhenPushed = YES;
        childController.currentAddress = [currentInspection Property];
        [self.navigationController pushViewController:childController animated:YES];
        [MapViewController release];  
    }

}

- (void)PrepareForSubmitInspection
{
    BOOL isCompleted = YES;
    
    CoreDataManager *dataManager = [CoreDataManager alloc];
    [dataManager Context:__managedObjectContext]; 
    NSMutableArray *inspectionItemArray = [dataManager AllInspectionItemsByInspectionID:currentInspectionID];  
    
    for (int i=0;i<[inspectionItemArray count];i++) {
        InspectionItem *item = [[InspectionItem alloc] init];
        item = [inspectionItemArray objectAtIndex:i];
        
        if([item.Status isEqualToString:@"None"]==TRUE)
        {
            isCompleted = NO;
            break;
        }
    }
    
    if(isCompleted == YES)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Confirmation Message!"
                                                        message:@"Are you sure you would like to submit this inspection?"
                                                       delegate:self    
                                              cancelButtonTitle:@"Cancel" 
                                              otherButtonTitles:@"OK", nil   ];
        [alert show];
        [alert release];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Warning!"
                                                        message:@"The inspection has not been completed. Make sure all of the tasks have been resolved before trying again."
                                                       delegate:self    
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil, nil   ];
        [alert show];
        [alert release];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0)
    {
        
    }
    else
    {
        [self InspectionSubmited];     
    }
}

- (void)InspectionSubmited
{
    [currentInspection setIsQueued:[NSNumber numberWithBool:YES]];
    
    CoreDataManager *dataManager = [CoreDataManager alloc];
    [dataManager Context:__managedObjectContext];
    [dataManager SaveObjectContext];
    
    InspectionsViewController *parent = (InspectionsViewController*)[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-3];
    
#ifdef __BLOCKS__
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Data Uploading";
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{        
        @try {
            [parent SubmitInspections];
        }
        @catch (NSException *exception) {
            AlertManager *alert = [AlertManager alloc];
            [alert showAlert:[NSString stringWithFormat:@"%@",exception] Title:@"Error"];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            [self Reload];
            
            InspectionItemViewController *parent2 = (InspectionItemViewController*)[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-2];
            [parent2 Reload];
            
            //[parent ReloadTableItem];
            //[self.navigationController popViewControllerAnimated:YES];            
        });
    }); 
#endif    
    
}

@end
