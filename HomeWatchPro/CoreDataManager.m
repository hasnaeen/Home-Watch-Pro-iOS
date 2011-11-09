//
//  CoreDataManager.m
//  HomeWatchPro
//
//  Created by USER on 6/29/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import "CoreDataManager.h"
#import "Inspections.h"
#import "AlertManager.h"
#import "InspectionItem.h"
#import "MediaObject.h"
#import "FileManager.h"

@implementation CoreDataManager

@synthesize managedObjectContext, dataArray;

-(void)Context:(NSManagedObjectContext *) context
{
    managedObjectContext = context;
}

-(void)DeleteAllInspections
{
    NSMutableArray *list = [self AllInspection];
    
    for (id item in list) {
        [managedObjectContext deleteObject:item];
    }
    
    NSError *error;
	if (![managedObjectContext save:&error]) {
		// This is a serious error saying the record could not be saved.
		// Advise the user to restart the application
	}
}

-(void)DeleteAllWithOutQueued:(NSMutableDictionary *)inspectionIds
{
    NSMutableArray *allObjects = [self AllInspection];
    NSMutableArray *listIDs = [[NSMutableArray alloc] init];
    NSMutableArray *listIDs1 = [[NSMutableArray alloc] init];
    NSMutableArray *listIDs2 = [[NSMutableArray alloc] init];
    
    for (id item in allObjects) {
        NSNumber *inspectionID = [item valueForKey:@"InspectionID"];
        id isExists = [inspectionIds valueForKey:[NSString stringWithFormat:@"%@",inspectionID]];
        
        if((([item valueForKey:@"IsQueued"] == NULL || [[item valueForKey:@"IsQueued"] isEqualToNumber: [NSNumber numberWithBool:YES]]!=TRUE)
            && ([item valueForKey:@"HasUpdated"] == NULL || [[item valueForKey:@"HasUpdated"] isEqualToNumber: [NSNumber numberWithBool:YES]]!=TRUE))
           || isExists == NULL || [isExists isEqualToNumber:[NSNumber numberWithBool:YES]]!=TRUE)
        {
            [listIDs addObject:inspectionID];
            [managedObjectContext deleteObject:item];
        }
    }
    
    for (int i=0;i<[listIDs count];i++) {
        NSNumber *inspectionID = [listIDs objectAtIndex:i];
        allObjects = [self AllInspectionItemsByInspectionID:inspectionID];
    
        for (id inspectionItem in allObjects) {
            NSNumber *inspectionItemID = [inspectionItem valueForKey:@"InspectionItemID"];
            [listIDs1 addObject:inspectionItemID];
            [listIDs2 addObject:inspectionID];
            [managedObjectContext deleteObject:inspectionItem];
            }
    }
    
    FileManager *fileManager = [FileManager alloc];
    
    for (int i=0; i<[listIDs1 count]; i++) {
        NSNumber *inspectionItemID = [listIDs1 objectAtIndex:i];
        NSNumber *inspectionID = [listIDs2 objectAtIndex:i];
        allObjects = [self GetMediaObjectsByInspectionItemID:inspectionItemID AndInspectionID:inspectionID];        
        
        for (id mediaItem in allObjects) {
            NSString *url = [mediaItem valueForKey:@"URL"];
            
            if(url != NULL && [url length]>5)
            {
                NSString *startUrl = [url substringWithRange:NSMakeRange(0, 5)];
                if([startUrl isEqualToString:@"Local"]==TRUE)
                {
                    [fileManager removeImage:[NSString stringWithFormat:@"%@.png", url]];
                }
            }
            
            [managedObjectContext deleteObject:mediaItem];
        }
    }
    
    NSError *error;
	if (![managedObjectContext save:&error]) {
		// This is a serious error saying the record could not be saved.
		// Advise the user to restart the application
	}
}

-(void)AddInspection: (NSString *)property Community:(NSString *) community DueDate:(NSData *) dueDate
       InspectionDate:(NSData *) inspectionDate Status:(NSString *) status InspectionID:(NSNumber *) inspectionID
                Notes:(NSString *) note SpecialInstructions:(NSString *) instruction
{
    Inspections *item = (Inspections *)[NSEntityDescription insertNewObjectForEntityForName:@"Inspections" inManagedObjectContext:managedObjectContext];
    
    [item setProperty:property];
    [item setCommunity:community];
    
    
    if(dueDate != NULL)
    {
        NSDateFormatter *dt = [[NSDateFormatter alloc] init];
        [dt setDateStyle:NSDateFormatterShortStyle];
        [item setDueDate:[dt dateFromString: [NSString stringWithFormat:@"%@",dueDate]]];
    }
    
    if(inspectionDate!=NULL)
    {
        NSDateFormatter *dt = [[NSDateFormatter alloc] init];
        [dt setDateStyle:NSDateFormatterShortStyle];
        [item setInspectionDate:[dt dateFromString: [NSString stringWithFormat:@"%@",inspectionDate]]];
    }
    
    [item setStatus:status];
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterNoStyle];
    [item setInspectionID:[f numberFromString: [NSString stringWithFormat:@"%@",inspectionID]]];
    
    [item setNotes:note];
    [item setSpecialInstructions:instruction];
    //[event setTimeStamp: [NSDate date]];
	
    [item setIsQueued:[NSNumber numberWithBool:NO]];
    [item setHasUpdated:[NSNumber numberWithBool:NO]];
    
	NSError *error;
	if (![managedObjectContext save:&error]) {
		// This is a serious error saying the record could not be saved.
		// Advise the user to restart the application
	}
}

-(NSMutableArray*)AllInspection
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Inspections" inManagedObjectContext:managedObjectContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"InspectionID" ascending:NO];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
	
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptor release];
	
	NSError *error;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	if (!mutableFetchResults) {
		
	}
	
	[self setDataArray: mutableFetchResults];
	
	[mutableFetchResults release];
	[request release];
    
    return dataArray;
}

-(NSMutableArray*)GetFourTypeInspection
{
    // Define our table/entity to use
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Inspections" inManagedObjectContext:managedObjectContext];
	// Setup the fetch request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(Status == 'Assigned') OR (Status == 'Received') OR (Status == 'Rejected')"];
    [request setPredicate:predicate];
    
	// Define how we will sort the records
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"InspectionID" ascending:NO];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
	
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptor release];
	
	// Fetch the records and handle an error
	NSError *error;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	if (!mutableFetchResults) {
		// Handle the error.
		// This is a serious error and should advise the user to restart the application
	}
	
	// Save our fetched data to an array
	[self setDataArray: mutableFetchResults];
	
	[mutableFetchResults release];
	[request release];
    
    return dataArray;
}

-(NSMutableArray*)GetAllHoldInspection
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Inspections" inManagedObjectContext:managedObjectContext];
	// Setup the fetch request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(HasUpdated == True)"];
    [request setPredicate:predicate];
    
	// Define how we will sort the records
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"InspectionID" ascending:NO];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
	
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptor release];
	
	// Fetch the records and handle an error
	NSError *error;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	if (!mutableFetchResults) {
		// Handle the error.
		// This is a serious error and should advise the user to restart the application
	}
	
	// Save our fetched data to an array
	[self setDataArray: mutableFetchResults];
	
	[mutableFetchResults release];
	[request release];
    
    return dataArray;
}

-(NSMutableArray*)GetAllInspectionByStatus:(NSString *)status
{
    // Define our table/entity to use
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Inspections" inManagedObjectContext:managedObjectContext];
	// Setup the fetch request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	
    if([status isEqualToString:@"Queued"]!=TRUE)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(Status == %@) AND (IsQueued == False)", status];
        [request setPredicate:predicate];
    }
    else
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(IsQueued == True)", status];
        [request setPredicate:predicate];
    }
    
	// Define how we will sort the records
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"InspectionID" ascending:NO];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
	
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptor release];
	
	// Fetch the records and handle an error
	NSError *error;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	if (!mutableFetchResults) {
		// Handle the error.
		// This is a serious error and should advise the user to restart the application
	}
	
	// Save our fetched data to an array
	[self setDataArray: mutableFetchResults];
	
	[mutableFetchResults release];
	[request release];
    
    return dataArray;
}

-(NSMutableArray*)GetInspectionByID:(NSNumber *)currentID
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Inspections" inManagedObjectContext:managedObjectContext];
	// Setup the fetch request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(InspectionID == %@)", currentID];
    [request setPredicate:predicate];
    
    // Fetch the records and handle an error
	NSError *error;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	if (!mutableFetchResults) {
		// Handle the error.
		// This is a serious error and should advise the user to restart the application
	}
	
	// Save our fetched data to an array
	[self setDataArray: mutableFetchResults];
	
	[mutableFetchResults release];
	[request release];
    
    return dataArray;
}

-(void)DeleteAllInspectionItem
{
    NSMutableArray *list = [self AllInspectionItems];
    
    for (id item in list) {
        [managedObjectContext deleteObject:item];
    }
    
    NSError *error;
	if (![managedObjectContext save:&error]) {
		// This is a serious error saying the record could not be saved.
		// Advise the user to restart the application
	}
}

-(NSMutableArray*)AllInspectionItems
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InspectionItem" inManagedObjectContext:managedObjectContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"InspectionItemID" ascending:NO];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
	
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptor release];
	
	NSError *error;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	if (!mutableFetchResults) {
		
	}
	
	[self setDataArray: mutableFetchResults];
	
	[mutableFetchResults release];
	[request release];
    
    return dataArray;
}

-(NSMutableArray*)AllInspectionItemsByInspectionID:(NSNumber *)inspectionID
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InspectionItem" inManagedObjectContext:managedObjectContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(InspectionID == %@)", inspectionID];
    [request setPredicate:predicate];
    
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"InspectionItemID" ascending:NO];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
	
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptor release];
	
	NSError *error;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	if (!mutableFetchResults) {
		
	}
	
	[self setDataArray: mutableFetchResults];
	
	[mutableFetchResults release];
	[request release];
    
    return dataArray;
}

-(void)AddInspectionItem: (NSNumber *) inspectionItemID InspectionID: (NSNumber *) inspectionID
                    Name: (NSString *)name Notes:(NSString *) note Status:(NSString *) status
         NoteToHomeowner: (NSString *) notesTOHomeowner NotesToPropertyManager:(NSString *) notesToPropertyManager RecurringNotes:(NSString *) recurringNotes
{
    InspectionItem *item = (InspectionItem *)[NSEntityDescription insertNewObjectForEntityForName:@"InspectionItem" inManagedObjectContext:managedObjectContext];
    
    [item setName:name];
    [item setNotes:note];
    
    if(status!=NULL && ![status isKindOfClass:[NSNull class]])
    [item setStatus:status];
    
    [item setNotesToHomeowner:notesTOHomeowner];
    [item setNotesToPropertyManager:notesToPropertyManager];
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterNoStyle];
    [item setInspectionID:[f numberFromString: [NSString stringWithFormat:@"%@",inspectionID]]];
    [item setInspectionItemID:[f numberFromString: [NSString stringWithFormat:@"%@",inspectionItemID]]];    
    
    [item setRecurringNotes:recurringNotes];
    
	NSError *error;
	if (![managedObjectContext save:&error]) {
		// This is a serious error saying the record could not be saved.
		// Advise the user to restart the application
	}
}

-(NSMutableArray*)GetInspectionItemByID:(NSNumber *)inspectionItemID  InspectionID:(NSNumber *) inspectionID
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InspectionItem" inManagedObjectContext:managedObjectContext];
	// Setup the fetch request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(InspectionItemID == %@) AND (InspectionID == %@)", inspectionItemID, inspectionID];
    [request setPredicate:predicate];
    
    // Fetch the records and handle an error
	NSError *error;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	if (!mutableFetchResults) {
		// Handle the error.
		// This is a serious error and should advise the user to restart the application
	}
	
	// Save our fetched data to an array
	[self setDataArray: mutableFetchResults];
	
	[mutableFetchResults release];
	[request release];
    
    return dataArray;
}

-(NSNumber*)GetInspectionItemIDByInspectionID:(NSNumber *)inspectionId AndName:(NSString *)name
{
    NSNumber *currentId = [NSNumber alloc];
    currentId = (NSNumber *)-1;
    
    for (id inspection in [self AllInspectionItemsByInspectionID:inspectionId]) {
        InspectionItem *item = [[InspectionItem alloc] init];
        item = (InspectionItem *)inspection ;
        
        if([[item Name] isEqualToString:name]==TRUE)
        {
            currentId = [item InspectionItemID];
        }
    }
    
    return currentId;
}


-(void)DeleteAllMediaObject
{
    NSMutableArray *list = [self AllMediaObjects];
    
    for (id item in list) {
        [managedObjectContext deleteObject:item];
    }
    
    NSError *error;
	if (![managedObjectContext save:&error]) {
		// This is a serious error saying the record could not be saved.
		// Advise the user to restart the application
	}
}

-(NSMutableArray*)AllMediaObjects
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MediaObject" inManagedObjectContext:managedObjectContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"InspectionItemID" ascending:NO];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
	
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptor release];
	
	NSError *error;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	if (!mutableFetchResults) {
		
	}
	
	[self setDataArray: mutableFetchResults];
	
	[mutableFetchResults release];
	[request release];
    
    return dataArray;
}

-(void)AddMediaObject: (NSNumber *) inspectionItemID Type:(NSString *) type FileName:(NSString *) fileName URl:(NSString *)url  InspectionID:(NSNumber *)inspectionID IsSubmitted:(BOOL) isSubmitted MediaObjectID:(NSNumber *)mediaObjectID IsDeleted:(BOOL) isDeleted
{
    MediaObject *item = (MediaObject *)[NSEntityDescription insertNewObjectForEntityForName:@"MediaObject" inManagedObjectContext:managedObjectContext];
    
    [item setType:type];
    [item setTitle:fileName];
    [item setURL:url];
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterNoStyle];
    [item setInspectionItemID:[f numberFromString: [NSString stringWithFormat:@"%@",inspectionItemID]]];
    [item setInspectionID:[f numberFromString:[NSString stringWithFormat:@"%@",inspectionID]]];
    [item setMediaObjectID:[f numberFromString:[NSString stringWithFormat:@"%@",mediaObjectID]]];
    [item setIsSubmitted:[NSNumber numberWithBool:isSubmitted]];
    [item setIsDeleted:[NSNumber numberWithBool:isDeleted]];
    
    NSError *error;
	if (![managedObjectContext save:&error]) {
		// This is a serious error saying the record could not be saved.
		// Advise the user to restart the application
	}
    
    //AlertManager *alert = [AlertManager alloc];
    //[alert showAlert:fileName Title:@"hi"];
}

-(NSMutableArray*)GetMediaObjectsByInspectionItemID:(NSNumber *)inspectionItemID AndInspectionID:(NSNumber *) inspectionID
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MediaObject" inManagedObjectContext:managedObjectContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(InspectionItemID == %@) AND (InspectionID == %@)", inspectionItemID,inspectionID];
    [request setPredicate:predicate];
    
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"Title" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
	
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptor release];
	
	NSError *error;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	if (!mutableFetchResults) {
		
	}
	
	[self setDataArray: mutableFetchResults];
	
	[mutableFetchResults release];
	[request release];
    
    return dataArray;
}

-(NSMutableArray*)GetMediaObjectsByInspectionItemID:(NSNumber *)inspectionItemID AndType:(NSString *)type AndInspectionID:(NSNumber *) inspectionID
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MediaObject" inManagedObjectContext:managedObjectContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(InspectionItemID == %@) AND (Type == %@) AND (InspectionID == %@)", inspectionItemID,type,inspectionID];
    [request setPredicate:predicate];
    
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"Title" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
	
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptor release];
	
	NSError *error;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	if (!mutableFetchResults) {
		
	}
	
	[self setDataArray: mutableFetchResults];
	
	[mutableFetchResults release];
	[request release];
    
    return dataArray;
}

-(NSMutableArray*)GetUnDeletedMediaObjectsByInspectionItemID:(NSNumber *)inspectionItemID AndType:(NSString *)type AndInspectionID:(NSNumber *) inspectionID
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MediaObject" inManagedObjectContext:managedObjectContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(InspectionItemID == %@) AND (Type == %@) AND (InspectionID == %@) AND (IsDeleted == False)", inspectionItemID,type,inspectionID];
    [request setPredicate:predicate];
    
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"Title" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
	
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptor release];
	
	NSError *error;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	if (!mutableFetchResults) {
		
	}
	
	[self setDataArray: mutableFetchResults];
	
	[mutableFetchResults release];
	[request release];
    
    return dataArray;
}

-(NSMutableArray*)GetUnSubmitMediaObjectsByInspectionItemID:(NSNumber *)inspectionItemID AndType:(NSString *)type AndInspectionID:(NSNumber *) inspectionID
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MediaObject" inManagedObjectContext:managedObjectContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(InspectionItemID == %@) AND (Type == %@) AND (InspectionID == %@) AND (IsSubmitted == False)", inspectionItemID,type,inspectionID];
    [request setPredicate:predicate];
    
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"Title" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
	
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptor release];
	
	NSError *error;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	if (!mutableFetchResults) {
		
	}
	
	[self setDataArray: mutableFetchResults];
	
	[mutableFetchResults release];
	[request release];
    
    return dataArray;
}

-(NSMutableArray*)GetDeletedMediaObjectsByInspectionItemID:(NSNumber *)inspectionItemID AndType:(NSString *)type AndInspectionID:(NSNumber *) inspectionID
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MediaObject" inManagedObjectContext:managedObjectContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(InspectionItemID == %@) AND (Type == %@) AND (InspectionID == %@) AND (IsDeleted == True)", inspectionItemID,type,inspectionID];
    [request setPredicate:predicate];
    
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"Title" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
	
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptor release];
	
	NSError *error;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	if (!mutableFetchResults) {
		
	}
	
	[self setDataArray: mutableFetchResults];
	
	[mutableFetchResults release];
	[request release];
    
    return dataArray;
}

-(void)SaveObjectContext
{
    NSError *error;
	if (![managedObjectContext save:&error]) {
		// This is a serious error saying the record could not be saved.
		// Advise the user to restart the application
	}
}

@end
