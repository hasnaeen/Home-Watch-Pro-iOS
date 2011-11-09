//
//  InspectionItemDetailsViewController.m
//  HomeWatchPro
//
//  Created by USER on 7/7/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import "InspectionItemDetailsViewController.h"
#import "InspectionItem.h"
#import "CoreDataManager.h"
#import "InspectionItemNotes.h"
#import "AlertManager.h"
#import "InspectionItemPhotosController.h"
#import "InspectionItemVideos.h"
#import "InspectionItemViewController.h"

@implementation InspectionItemDetailsViewController

@synthesize currentInspectionItemID,currentInspectionItem,segmentControl,currentEdit,currentInspectionID;
@synthesize managedObjectContext=__managedObjectContext;
@synthesize notes,notesToHomeowner,notesToPropertyManager,status,currentInspection,currentInspectionItemImages,tempAddInspectionItemPhotosArray;

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
    
    [self.navigationController setNavigationBarHidden:YES];    
    CGRect boun = segmentControl.frame;
    boun.size.height = 40;
    segmentControl.frame = boun;
    segmentControl.backgroundColor = [UIColor clearColor];
    
    CoreDataManager *dataManager = [CoreDataManager alloc];
    [dataManager Context:__managedObjectContext]; 
    
    NSMutableArray *dataInspection = [dataManager GetInspectionByID:currentInspectionID];
    
    if([dataInspection count]>0)
        currentInspection = (Inspections*) [dataInspection objectAtIndex:0];
    else
        currentInspection = NULL;
    
    NSMutableArray *data = [dataManager GetInspectionItemByID:currentInspectionItemID InspectionID:currentInspectionID];
    
    if([data count]>0)
        currentInspectionItem = (InspectionItem*) [data objectAtIndex:0];
    else
        currentInspectionItem = NULL;
    
    if(currentInspectionItem!=NULL)
    {
        currentInspectionItemImages = [dataManager GetUnDeletedMediaObjectsByInspectionItemID:currentInspectionItemID AndType:@"Photo" AndInspectionID:currentInspectionID];        
        tempAddInspectionItemPhotosArray = [[NSMutableArray alloc] init];
        
        lblName.text = [currentInspectionItem Name];
        
        if([[currentInspectionItem Status] isEqualToString:@"Okay"]==TRUE)
            segmentControl.selectedSegmentIndex = 0;
        else if([[currentInspectionItem Status] isEqualToString:@"Not Okay"]==TRUE)
            segmentControl.selectedSegmentIndex = 1;
        else if([[currentInspectionItem Status] isEqualToString:@"Resolved"]==TRUE)
            segmentControl.selectedSegmentIndex = 2;
        
        notes = [currentInspectionItem Notes];
        notesToHomeowner = [currentInspectionItem NotesToHomeowner];
        notesToPropertyManager = [currentInspectionItem NotesToPropertyManager];
        status = [currentInspectionItem Status];
        
        if(notes != NULL && [notes isEqualToString:@""]!=TRUE && [notes isEqualToString:@"None"]!=TRUE)
            notesToNotes.hidden = FALSE;
        else
            notesToNotes.hidden = TRUE;
        
        if([currentInspectionItem RecurringNotes] != NULL && [[currentInspectionItem RecurringNotes] isEqualToString:@""]!=TRUE && [[currentInspectionItem RecurringNotes] isEqualToString:@"None"]!=TRUE)
            notesToRecurringNotes.hidden = FALSE;
        else
            notesToRecurringNotes.hidden = TRUE;
        
        if(notesToHomeowner != NULL && [notesToHomeowner isEqualToString:@""]!=TRUE && [notesToHomeowner isEqualToString:@"None"]!=TRUE)
            notesToHomeownerImage.hidden = FALSE;
        else
            notesToHomeownerImage.hidden = TRUE;
        
        if(notesToPropertyManager != NULL && [notesToPropertyManager isEqualToString:@""]!=TRUE && [notesToPropertyManager isEqualToString:@"None"]!=TRUE)
            notesToPropertyManagerImage.hidden = FALSE;
        else
            notesToPropertyManagerImage.hidden = TRUE;
    }

    currentEdit = @"";
    
    if([currentInspection.IsQueued isEqualToNumber: [NSNumber numberWithBool:YES]]==TRUE || [currentInspection.Status isEqualToString:@"Received"]==TRUE)
        btnSave.hidden = TRUE;
    else
        btnSave.hidden = FALSE;
    // Do any additional setup after loading the view from its nib.
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

- (IBAction)EditClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if (button == btnNotes) {
        currentEdit = @"Notes";
        InspectionItemNotes *childController = [[InspectionItemNotes alloc] init];
        childController.hidesBottomBarWhenPushed = YES;
        childController.currentNotes = notes;
        childController.currentTitle = @"Notes";
        childController.Editable = NO;
        [self.navigationController pushViewController:childController animated:YES];
        [InspectionItemNotes release];
    } 
    if (button == btnRecurringNotes) {
        currentEdit = @"RecurringNotes";
        InspectionItemNotes *childController = [[InspectionItemNotes alloc] init];
        childController.hidesBottomBarWhenPushed = YES;
        childController.currentNotes = [currentInspectionItem RecurringNotes];
        childController.currentTitle = @"Recurring Notes";
        childController.Editable = NO;
        [self.navigationController pushViewController:childController animated:YES];
        [InspectionItemNotes release];
    } 
    else if (button == btnNotesToHomeowner) {
        currentEdit = @"NotesToHomeowner";
        InspectionItemNotes *childController = [[InspectionItemNotes alloc] init];
        childController.hidesBottomBarWhenPushed = YES;
        childController.currentNotes = notesToHomeowner;
        childController.currentTitle = @"Notes To Homeowner";
        if([currentInspection IsQueued] == [NSNumber numberWithBool:YES] || [currentInspection.Status isEqualToString:@"Received"]==TRUE)
            childController.Editable = NO;
        else
            childController.Editable = YES;
        [self.navigationController pushViewController:childController animated:YES];
        [InspectionItemNotes release];
    }
    else if(button == btnNotesToPropertyManager)
    {
        currentEdit = @"NotesToPropertyManager";
        InspectionItemNotes *childController = [[InspectionItemNotes alloc] init];
        childController.hidesBottomBarWhenPushed = YES;
        childController.currentNotes = notesToPropertyManager;
        childController.currentTitle = @"Notes To Property Manager";
        if([currentInspection IsQueued] == [NSNumber numberWithBool:YES] || [currentInspection.Status isEqualToString:@"Received"]==TRUE)
            childController.Editable = NO;
        else
            childController.Editable = YES;
        [self.navigationController pushViewController:childController animated:YES];
        [InspectionItemNotes release];
    }
    else if(button == btnPhotos)
    {
        currentEdit = @"Photos";
        InspectionItemPhotosController *childController = [[InspectionItemPhotosController alloc] init];
        childController.hidesBottomBarWhenPushed = YES;
        childController.currentInspectionItemID = [currentInspectionItem InspectionItemID];
        childController.currentInspectionID = currentInspectionID;
        childController.inspectionItemPhotosArray = currentInspectionItemImages;
        childController.tempAddInspectionItemPhotosArray = tempAddInspectionItemPhotosArray;
        [childController Context:__managedObjectContext];
        [self.navigationController pushViewController:childController animated:YES];
        [InspectionItemPhotosController release];
    }
    else if(button == btnVideos)
    {
        currentEdit = @"Videos";
        InspectionItemVideos *childController = [[InspectionItemVideos alloc] init];
        childController.hidesBottomBarWhenPushed = YES;
        childController.currentInspectionItemID = [currentInspectionItem InspectionItemID];
        childController.currentInspectionID = currentInspectionID;
        [childController Context:__managedObjectContext];
        [self.navigationController pushViewController:childController animated:YES];
        [InspectionItemVideos release];
    }
}

- (void)EditSave:(NSString *)note
{
    if([currentEdit isEqualToString:@"Notes"]==TRUE)
        notes = [[NSString alloc] initWithFormat:@"%@",note];
    else if([currentEdit isEqualToString:@"NotesToHomeowner"]==TRUE)
    {
        notesToHomeowner = [[NSString alloc] initWithFormat:@"%@",note];
        
        currentInspectionItem.NotesToHomeowner = notesToHomeowner;
        [currentInspection setHasUpdated:[NSNumber numberWithBool:YES]];
        CoreDataManager *dataManager = [CoreDataManager alloc];
        [dataManager Context:__managedObjectContext];
        [dataManager SaveObjectContext];
        
        if(notesToHomeowner != NULL && [notesToHomeowner isEqualToString:@""]!=TRUE && [notesToHomeowner isEqualToString:@"None"]!=TRUE)
            notesToHomeownerImage.hidden = FALSE;
        else
            notesToHomeownerImage.hidden = TRUE;
    }
    else if([currentEdit isEqualToString:@"NotesToPropertyManager"]==TRUE)
    {
        notesToPropertyManager = [[NSString alloc] initWithFormat:@"%@",note];
        
        currentInspectionItem.NotesToPropertyManager = notesToPropertyManager;
        [currentInspection setHasUpdated:[NSNumber numberWithBool:YES]];
        CoreDataManager *dataManager = [CoreDataManager alloc];
        [dataManager Context:__managedObjectContext];
        [dataManager SaveObjectContext];
        
        if(notesToPropertyManager != NULL && [notesToPropertyManager isEqualToString:@""]!=TRUE && [notesToPropertyManager isEqualToString:@"None"]!=TRUE)
            notesToPropertyManagerImage.hidden = FALSE;
        else
            notesToPropertyManagerImage.hidden = TRUE;
    }
    else if([currentEdit isEqualToString:@"Photos"]==TRUE)
    {
        [currentInspection setHasUpdated:[NSNumber numberWithBool:YES]];
        CoreDataManager *dataManager = [CoreDataManager alloc];
        [dataManager Context:__managedObjectContext];
        [dataManager SaveObjectContext];
        
        if([tempAddInspectionItemPhotosArray count]>0)
        {
            for (int i=0; i< [tempAddInspectionItemPhotosArray count]; i++) {
                [dataManager AddMediaObject:currentInspectionItemID Type:@"Photo" FileName:@"" URl:(NSString *)[tempAddInspectionItemPhotosArray objectAtIndex:i] InspectionID:currentInspectionID IsSubmitted:NO MediaObjectID:[NSNumber numberWithInt:-1] IsDeleted:NO];
            }
        }
        
        currentInspectionItemImages = [dataManager GetUnDeletedMediaObjectsByInspectionItemID:currentInspectionItemID AndType:@"Photo" AndInspectionID:currentInspectionID];        
        tempAddInspectionItemPhotosArray = [[NSMutableArray alloc] init];
    }
}

-(void)segmentedControlSelected
{
    int index =  segmentControl.selectedSegmentIndex;
    
    segmentControl.selectedSegmentIndex = -1;
    
    if([currentInspection.IsQueued isEqualToNumber: [NSNumber numberWithBool:YES]]==TRUE || [currentInspection.Status isEqualToString:@"Received"]==TRUE)
    {
        if([[currentInspectionItem Status] isEqualToString:@"Okay"]==TRUE)
            index = 0;
        else if([[currentInspectionItem Status] isEqualToString:@"Not Okay"]==TRUE)
            index = 1;
        else if([[currentInspectionItem Status] isEqualToString:@"Resolved"]==TRUE)
            index = 2;
    }
    
    [segmentControl setImage:[UIImage imageNamed:@"btn_okay.png"] forSegmentAtIndex:0];
    [segmentControl setImage:[UIImage imageNamed:@"btn_not_okay.png"] forSegmentAtIndex:1];
    [segmentControl setImage:[UIImage imageNamed:@"btn_resolved.png"] forSegmentAtIndex:2];
    
    switch (index) {
        case 0:
            [segmentControl setImage:[UIImage imageNamed:@"btn_okay_mo.png"] forSegmentAtIndex:0];
            status = @"Okay";
            break;
        case 1:
            [segmentControl setImage:[UIImage imageNamed:@"btn_not_okay_mo.png"] forSegmentAtIndex:1];
            status = @"Not Okay";            
            break;
        case 2:
            [segmentControl setImage:[UIImage imageNamed:@"btn_resolved_mo.png"] forSegmentAtIndex:2];
            status = @"Resolved";
            break;
        default:
            break;
    }
}

- (IBAction)segmentedControlValueChanged
{
    [self segmentedControlSelected];    
    //segmentControl.selectedSegmentIndex = -1;    
}

- (IBAction)SaveDetails:(id)sender
{
    currentInspectionItem.Notes = notes;
    currentInspectionItem.NotesToHomeowner = notesToHomeowner;
    currentInspectionItem.NotesToPropertyManager = notesToPropertyManager;
    currentInspectionItem.Status = status;
    [currentInspection setHasUpdated:[NSNumber numberWithBool:YES]];
    
    CoreDataManager *dataManager = [CoreDataManager alloc];
    [dataManager Context:__managedObjectContext];
    [dataManager SaveObjectContext];
    
    if([tempAddInspectionItemPhotosArray count]>0)
    {
        for (int i=0; i< [tempAddInspectionItemPhotosArray count]; i++) {
            [dataManager AddMediaObject:currentInspectionItemID Type:@"Photo" FileName:@"" URl:(NSString *)[tempAddInspectionItemPhotosArray objectAtIndex:i] InspectionID:currentInspectionID IsSubmitted:NO MediaObjectID:[NSNumber numberWithInt:-1] IsDeleted:NO];
        }
    }
    
    InspectionItemViewController *parent = (InspectionItemViewController*)[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-2];
    [parent Reload];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
