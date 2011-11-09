//
//  InspectionsManager.m
//  HomeWatchPro
//
//  Created by USER on 6/29/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import "LoadDataManager.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "AlertManager.h"
#import "UserDataManager.h"
#import "CoreDataManager.h"
#import "JSON/JSON.h"
#import "Inspections.h"
#import "Reachability.h"

@implementation LoadDataManager

@synthesize coreDataManager,error;
@synthesize managedObjectContext=__managedObjectContext;

-(void)Context:(NSManagedObjectContext *) context
{
    self.managedObjectContext = context;
}

bool _isSuccessLoad = FALSE;
-(BOOL)LoadInspectionsAndItems
{
    _isSuccessLoad = NO;
    UserDataManager *dataManager = [UserDataManager alloc];
    NSString *serviceUrl = [NSString stringWithFormat:@"http://api.hwptest.info/services/getinspections/%@", [dataManager retrieveAccessKey]];
    NSURL *url = [NSURL URLWithString:serviceUrl];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setTimeOutSeconds:60];
    
    [request setCompletionBlock:^{
        NSLog(@"blocks Completion");
        @try{
        _isSuccessLoad = YES;
        NSString *responseString = [request responseString];
        NSDictionary *dictionary = [responseString JSONValue];
        
        NSArray *keys = [dictionary allKeys];
        id aKey = [keys objectAtIndex:0];
        id anObject = [dictionary objectForKey:aKey];
        NSMutableDictionary *allInspectionIds = [[NSMutableDictionary alloc] init];
        
        for (id item in anObject) {
            NSNumber *inspectionID = [item valueForKey:@"InspectionID"];
            [allInspectionIds setObject:[NSNumber numberWithBool:YES] forKey:inspectionID];
        }        
        
        coreDataManager = [CoreDataManager alloc];
        [coreDataManager Context: __managedObjectContext];
        [coreDataManager DeleteAllWithOutQueued:allInspectionIds];
                
        for (id item in anObject) {
            NSString *property = [item valueForKey:@"Property"];
            NSString *community = [item valueForKey:@"Community"];
            NSData *dueDate = [item valueForKey:@"DueDate"];
            NSData *inspectionDate = [item valueForKey:@"InspectionDate"];
            NSString *status = [item valueForKey:@"Status"];
            NSNumber *inspectionID = [item valueForKey:@"InspectionID"];
            NSString *notesToInspector = [item valueForKey:@"NotesToInspector"];
            NSString *specialInstructions = [item valueForKey:@"SpecialInstructions"];
            
            if([[coreDataManager GetInspectionByID:inspectionID] count]==0)
            {
                [coreDataManager AddInspection:property Community:community DueDate:dueDate InspectionDate:inspectionDate Status:status InspectionID:inspectionID Notes:notesToInspector SpecialInstructions:specialInstructions];
                
                id inspectItems = [item objectForKey:@"InspectionItems"];
            
                for (id inspectItem in inspectItems) {
                    NSNumber *inspectionItemID = [inspectItem valueForKey:@"InspectionItemID"];
                    NSString *name = [inspectItem valueForKey:@"Name"];
                    NSString *itemStatus = [inspectItem valueForKey:@"Status"];
                    NSString *notes = [inspectItem valueForKey:@"Notes"];
                    NSString *recurringNotes = [inspectItem valueForKey:@"RecurringNotes"];
                    NSString *notesToHomeowner = [inspectItem valueForKey:@"NotesToHomeowner"];
                    NSString *notesToProperyManager = [inspectItem valueForKey:@"NotesToPropertyManager"];
                    
                    [coreDataManager AddInspectionItem:inspectionItemID InspectionID:inspectionID Name:name Notes:notes Status:itemStatus 
                                    NoteToHomeowner:notesToHomeowner NotesToPropertyManager:notesToProperyManager RecurringNotes:recurringNotes];    
                }  
                //[self LoadMediaObjectForInspectionID:inspectionID];
            }
        }
        
        [coreDataManager release];
         NSLog(@"Response: %@", responseString);
        }
        @catch (NSException *exception) {
            AlertManager *alert = [AlertManager alloc];
            [alert showAlert:[NSString stringWithFormat:@"%@",exception] Title:@"Error"];
        }
        
    }];
    [request setFailedBlock:^{
        NSLog(@"blocks Error");
        error = [request error];
    }];
    [request startSynchronous];
    
    sleep(1);
    
    return _isSuccessLoad;
}

-(void)LoadMediaObject
{
    @try {
    coreDataManager = [CoreDataManager alloc];
    [coreDataManager Context: __managedObjectContext];
    //[coreDataManager DeleteAllMediaObject];
    NSMutableArray *inspections =  [coreDataManager AllInspection];
    
    for (int i=0;i<[inspections count];i++) {
        Inspections *item = [[Inspections alloc] init];
        item = [inspections objectAtIndex:i];
        
        if(([item valueForKey:@"IsQueued"] == NULL || [item.IsQueued isEqualToNumber: [NSNumber numberWithBool:YES]]!=TRUE)&&
           ([item valueForKey:@"HasUpdated"] == NULL || [item.HasUpdated isEqualToNumber: [NSNumber numberWithBool:YES]]!=TRUE))
            [self LoadMediaObjectForInspectionID:[item InspectionID]];
        }
    }
    @catch (NSException *exception) {
        AlertManager *alert = [AlertManager alloc];
        [alert showAlert:[NSString stringWithFormat:@"%@",exception] Title:@"Error"];
    }
}

-(void)LoadMediaObjectForInspectionID:(NSNumber *)inspectionID
{
    UserDataManager *dataManager = [UserDataManager alloc];
    NSString *serviceUrl = [NSString stringWithFormat:@"http://api.hwptest.info/services/getmediaobjects/%@", [dataManager retrieveAccessKey]];
    NSURL *url = [NSURL URLWithString:serviceUrl];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setPostValue:inspectionID forKey:@"InspectionID"];
    [request setTimeOutSeconds:60];
    
    [request setCompletionBlock:^{
        NSLog(@"blocks Completion");
        
    @try {
        coreDataManager = [CoreDataManager alloc];
        [coreDataManager Context: __managedObjectContext];
        
        NSString *responseString = [request responseString];
        NSDictionary *dictionary = [responseString JSONValue];
        id inspectionItems = [dictionary valueForKey:@"InspectionItems"];
        
        for (id inspectionitem in inspectionItems) {
            id mediaObjects = [inspectionitem valueForKey:@"Medias"];
            if([mediaObjects count]>0)
            {
                NSString *name = [inspectionitem valueForKey:@"Name"];
                NSNumber* itemID = [coreDataManager GetInspectionItemIDByInspectionID:inspectionID AndName:name];
                
                for (id mediaObject in mediaObjects) {
                    NSString *mediaType = [mediaObject valueForKey:@"MediaType"];
                    id mediaFiles = [mediaObject valueForKey:@"Files"];
                    
                    for (id mediaFile in mediaFiles) {
                        NSString *fileName = [mediaFile valueForKey:@"FileName"];
                        NSString *fileUrl = [mediaFile valueForKey:@"Url"];
                        NSNumber *mediaObjectID = [mediaFile valueForKey:@"MediaObjectID"];
                        
                        [coreDataManager AddMediaObject: itemID Type:mediaType FileName:fileName URl:fileUrl InspectionID:inspectionID IsSubmitted:YES MediaObjectID:mediaObjectID IsDeleted:NO];
                    }
                }
            }
        }
    }
    @catch (NSException *exception) {
        AlertManager *alert = [AlertManager alloc];
        [alert showAlert:[NSString stringWithFormat:@"%@",exception] Title:@"Error"];
    }   
    
    }];
    
    [request setFailedBlock:^{
        NSLog(@"blocks Error");
        error = [request error];
        AlertManager *alert = [AlertManager alloc];
        [alert showAlert:[NSString stringWithFormat:@"%@",error] Title:@"Error in Medio loading."];
    }];
    
    [request startAsynchronous];
}

-(BOOL)IsInternateAvailable
{
    Reachability* internetReachable;
    internetReachable = [[Reachability reachabilityForInternetConnection] retain];
    [internetReachable startNotifier];
    
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    
    switch (internetStatus)
    {
        case NotReachable:
        {
            NSLog(@"The internet is down.");
            return NO;
        }
    }
            
    return YES;
}

@end
