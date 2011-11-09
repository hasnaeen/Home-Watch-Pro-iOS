//
//  InspectionItemViewController.m
//  HomeWatchPro
//
//  Created by USER on 7/6/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import "InspectionItemViewController.h"
#import "Inspections.h"
#import "AlertManager.h"
#import "InspectionItem.h"
#import "CoreDataManager.h"
#import "ItemTableCell.h"
#import "InspectionItemDetailsViewController.h"
#import "InspectionsViewController.h"
#import "MBProgressHUD.h"
#import "InspectionViewController.h"
#import "MapViewController.h"
#import "InspectionItemNotes.h"

@implementation InspectionItemViewController

@synthesize currentInspectionID,hasInspectionItems;
@synthesize currentInspection,tblSimpleTable,tblItemCell,inspectionItemArray;
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
    
    if(currentInspection!=NULL)
    {
        NSArray *listItems = [[currentInspection Property] componentsSeparatedByString:@", "];
        
        if([listItems count]>0)
            lblAddress1.text = [listItems objectAtIndex:0];
        else
            lblAddress1.text = @"";
        
        if([listItems count] >1)
        {
            lblAddress2.text = [listItems objectAtIndex:1];
            
            for(int i=2;i<[listItems count];i++)
                lblAddress2.text = [NSString stringWithFormat:@"%@, %@",lblAddress2.text,[listItems objectAtIndex:i]];
        }
        
        lblCommunity.text = [currentInspection Community];
        NSDateFormatter *date_formater=[[NSDateFormatter alloc]init];
        [date_formater setDateFormat:@"MM/dd/YYYY"];
        lblDueDate.text = [NSString stringWithFormat:@"Due: %@",[date_formater stringFromDate:[currentInspection DueDate]]];
        
        if([[currentInspection IsQueued] isEqualToNumber: [NSNumber numberWithBool:YES]]==TRUE || [currentInspection.Status isEqualToString:@"Received"]==TRUE)
        {
            btnSubmitInspection.hidden = TRUE;
            lblQueuedText.hidden = FALSE;
        }
        else
        {
            btnSubmitInspection.hidden = FALSE;
            lblQueuedText.hidden = TRUE;
        }
        
        if(currentInspection.Notes != NULL && [currentInspection.Notes isEqualToString:@""]!=TRUE && [currentInspection.Notes isEqualToString:@"None"]!=TRUE)
            notesImage.hidden = NO;
        else 
            notesImage.hidden = YES;
        
       if(currentInspection.SpecialInstructions != NULL && [currentInspection.SpecialInstructions isEqualToString:@""]!=TRUE && [currentInspection.SpecialInstructions isEqualToString:@"None"]!=TRUE)
            specialInstractionImage.hidden = NO;
        else
            specialInstractionImage.hidden = YES;
    }
    
    inspectionItemArray = [dataManager AllInspectionItemsByInspectionID:currentInspectionID];    
    [dataManager release];    
    // Do any additional setup after loading the view from its nib.
}

-(void) Reload
{
    if([currentInspection IsQueued] == [NSNumber numberWithBool:YES] || [currentInspection.Status isEqualToString:@"Received"]==TRUE)
    {
        btnSubmitInspection.hidden = TRUE;
        lblQueuedText.hidden = FALSE;
    }
    else
    {
        btnSubmitInspection.hidden = FALSE;
        lblQueuedText.hidden = TRUE;
    }
    
    CoreDataManager *dataManager = [CoreDataManager alloc];
    [dataManager Context:__managedObjectContext]; 
    inspectionItemArray = [dataManager AllInspectionItemsByInspectionID:currentInspectionID];  
    [tblSimpleTable reloadData];
}

- (IBAction)ClickInspectionView:(id)sender
{
    UIActionSheet *actionSheet = NULL; 
    if([[currentInspection IsQueued] isEqualToNumber: [NSNumber numberWithBool:YES]]==TRUE || [currentInspection.Status isEqualToString:@"Received"]==TRUE)
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View On Map",nil];
    else
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View On Map",@"Mark All As Okay",@"Submit Inspection",nil];
	
    [actionSheet showInView:self.view];
	[actionSheet release];
    
    /*
    InspectionViewController *childController = [[InspectionViewController alloc] init];
    childController.hidesBottomBarWhenPushed = YES;
    childController.currentInspectionID = currentInspectionID;
    [childController Context: __managedObjectContext];
    [self.navigationController pushViewController:childController animated:YES];
    
    [InspectionViewController release];
     */
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex == 0)
    {
        MapViewController *childController = [[MapViewController alloc] init];
        childController.hidesBottomBarWhenPushed = YES;
        childController.currentAddress = [currentInspection Property];
        [self.navigationController pushViewController:childController animated:YES];
        [MapViewController release];
    }
	else if(([[currentInspection IsQueued] isEqualToNumber: [NSNumber numberWithBool:YES]]==TRUE || [currentInspection.Status isEqualToString:@"Received"]==TRUE)==FALSE)
    {
        if(buttonIndex == 1)
        {
            CoreDataManager *dataManager = [CoreDataManager alloc];
            [dataManager Context:__managedObjectContext];
            inspectionItemArray = [dataManager AllInspectionItemsByInspectionID:currentInspectionID];    
            
            for (int i=0;i<[inspectionItemArray count];i++) {
                InspectionItem *item = [[InspectionItem alloc] init];
                item = [inspectionItemArray objectAtIndex:i];
                
                if([item.Status isEqualToString:@"None"]==TRUE)
                    [item setStatus:@"Okay"];
            }
            
            [currentInspection setHasUpdated:[NSNumber numberWithBool:YES]];
            [dataManager SaveObjectContext];
            [dataManager release];
            [self Reload];
        }
        else if(buttonIndex == 2)
        {
            [self SubmitInspection:btnSubmitInspection];
        }
    }
}

- (IBAction)SubmitInspection:(id)sender
{
    BOOL isCompleted = YES;
    
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
    [currentInspection setStatus:@"Received"];
    CoreDataManager *dataManager = [CoreDataManager alloc];
    [dataManager Context:__managedObjectContext];
    [dataManager SaveObjectContext];
    
    InspectionsViewController *parent = (InspectionsViewController*)[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-2];
    
#ifdef __BLOCKS__
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Data Uploading";
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{        
        @try {
            [parent SubmitInspections];
            [parent ReloadTableItem];
        }
        @catch (NSException *exception) {
            AlertManager *alert = [AlertManager alloc];
            [alert showAlert:[NSString stringWithFormat:@"%@",exception] Title:@"Error"];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            [self Reload];
            //[parent ReloadTableItem];
            //[self.navigationController popViewControllerAnimated:YES];            
        });
    }); 
#endif    
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

- (IBAction)BackClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)NoteClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if(button == btnNotes)
    {
        InspectionItemNotes *childController = [[InspectionItemNotes alloc] init];
        childController.hidesBottomBarWhenPushed = YES;
        childController.currentNotes = [currentInspection Notes];
        childController.currentTitle = @"Notes to Inspect";
        childController.Editable = NO;
        [self.navigationController pushViewController:childController animated:YES];
        [InspectionItemNotes release];
    }
    else if(button == btnSpecialInstraction)
    {
        InspectionItemNotes *childController = [[InspectionItemNotes alloc] init];
        childController.hidesBottomBarWhenPushed = YES;
        childController.currentNotes = [currentInspection SpecialInstructions];
        childController.currentTitle = @"Special Instructions";
        childController.Editable = NO;
        [self.navigationController pushViewController:childController animated:YES];
        [InspectionItemNotes release];
    }
}
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([inspectionItemArray count]>0)
    {
        hasInspectionItems = YES;
        return [inspectionItemArray count];
    }
    else
    {
        hasInspectionItems = NO;
        return 1;
    }
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *MyIdentifier = @"MyIdentifier";
	MyIdentifier = @"tblItemCellView";
    
    InspectionItem *item = [[Inspections alloc] init];
    if(hasInspectionItems == YES)
        item = [inspectionItemArray objectAtIndex:indexPath.row];
    
	ItemTableCell *cell = (ItemTableCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if(cell == nil) {
        //cell = [[[ItemTableCell alloc]   reuseIdentifier:MyIdentifier] autorelease];
        [[NSBundle mainBundle] loadNibNamed:@"ItemTableCell" owner:self options:nil];
		cell = tblItemCell;
	}
	
    
    if(indexPath.row == 0 && (hasInspectionItems == NO || [inspectionItemArray count] == 1))
    {
        if(hasInspectionItems == NO)
            [cell setBackGroundImage:@"bar_without_arrow.png"];
        else
            [cell setBackGroundImage:@"bar.png"];
    }
    else if(indexPath.row == 0)
    {
        [cell setBackGroundImage:@"top_curve.png"];
    }
    else if(indexPath.row == [inspectionItemArray count] - 1)
    {
        [cell setBackGroundImage:@"bottom_curve.png"];
    }
    else
    {
        [cell setBackGroundImage:@"middle_bar.png"];
	}
    
    if(hasInspectionItems == YES)
    {
        [cell setLabelText:[item Name]];
            
        if(item.Notes != NULL && [item.Notes isEqualToString:@""]!=TRUE && [item.Notes isEqualToString:@"None"]!=TRUE)
            [cell ShowNotesImage];
            
        if(item.Status != NULL && [item.Status isEqualToString:@"Okay"]==TRUE)
            [cell ShowOkImage];
        else
            [cell HideOkImage];
    }
    else
    {
        NSString *labelShow = @"No Inspection Item Found.";
        [cell SetFullLabelTest:labelShow];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tabelView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat result = 43;
	return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    if(hasInspectionItems == YES)
    {
        InspectionItem *item = [[InspectionItem alloc] init];
        item = [inspectionItemArray objectAtIndex:indexPath.row];
        
        InspectionItemDetailsViewController *childController = [[InspectionItemDetailsViewController alloc] init];
        childController.hidesBottomBarWhenPushed = YES;
        childController.currentInspectionItemID = [item InspectionItemID];
        childController.currentInspectionID = currentInspectionID;
        [childController Context: __managedObjectContext];
        [self.navigationController pushViewController:childController animated:YES];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [InspectionItemDetailsViewController release];  
    }
}

@end
