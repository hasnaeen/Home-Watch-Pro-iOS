//
//  InspectionSubmitManager.m
//  HomeWatchPro
//
//  Created by USER on 7/14/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import "InspectionSubmitManager.h"
#import "Inspections.h"
#import "AlertManager.h"
#import "InspectionItem.h"
#import "UserDataManager.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JSON/JSON.h"
#import "MediaObject.h"
#import "FileManager.h"

@implementation InspectionSubmitManager

@synthesize coreDataManager,hasSubmit;
@synthesize managedObjectContext=__managedObjectContext;

-(void)Context:(NSManagedObjectContext *) context
{
    self.managedObjectContext = context;
}

-(void)SubmitInspection
{
    coreDataManager = [CoreDataManager alloc];
    [coreDataManager Context: __managedObjectContext];
    NSMutableArray *inspectionsQueued = [[NSMutableArray alloc] initWithArray:[coreDataManager GetAllInspectionByStatus:@"Queued"]];
    //AlertManager *alert = [AlertManager alloc];
    
    for (int i=0;i<[inspectionsQueued count];i++) {
        NSNumber *inspectionID = [[inspectionsQueued objectAtIndex:i] valueForKey:@"InspectionID"];
        NSString *inspectionStatus = [[inspectionsQueued objectAtIndex:i] valueForKey:@"Status"];
        
        NSMutableArray *inspectionItems = [coreDataManager AllInspectionItemsByInspectionID:inspectionID];
        NSString *data = [[NSString alloc] init];
        data = [NSString stringWithFormat:@"{\"InspectionID\":\"%@\",\"Status\":\"%@\",\"InspectionItems\":[",inspectionID,inspectionStatus];
        
        for(int j=0;j<[inspectionItems count];j++)
        {
            NSNumber *inspectionItemID = [[inspectionItems objectAtIndex:j] valueForKey:@"InspectionItemID"];
            NSString *notesToPropertyManager = [[inspectionItems objectAtIndex:j] valueForKey:@"NotesToPropertyManager"];
            NSString *notesToHomeowner = [[inspectionItems objectAtIndex:j] valueForKey:@"NotesToHomeowner"];
            NSString *status = [[inspectionItems objectAtIndex:j] valueForKey:@"Status"];
            
            if(j>0)
                data = [NSString stringWithFormat:@"%@,",data];
                
            data = [NSString stringWithFormat:@"%@{\"InspectionItemID\":\"%@\",\"NotesToPropertyManager\":\"%@\",\"NotesToHomeowner\":\"%@\",\"Status\":\"%@\"}"
                    ,data,inspectionItemID,notesToPropertyManager,notesToHomeowner,status];
        }
        
        data = [NSString stringWithFormat:@"%@]}",data];
        
        [self SubmitRequestInspectionID:inspectionID Data:data];
    }
}

-(void)SubmitRequestInspectionID:(NSNumber *)inspectionID Data:(NSString *)data
{
    UserDataManager *dataManager = [UserDataManager alloc];
    NSString *serviceUrl = [NSString stringWithFormat:@"http://api.hwptest.info/services/saveinspection/%@", [dataManager retrieveAccessKey]];
    NSURL *url = [NSURL URLWithString:serviceUrl];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setPostValue:inspectionID forKey:@"InspectionID"];
    [request setPostValue:data forKey:@"Data"];
    
    [request setCompletionBlock:^{
        NSLog(@"blocks Completion");
        NSString *responseString = [request responseString];
        NSDictionary *dictionary = [responseString JSONValue];
        NSArray *output = [dictionary allValues]; 
        NSString *p1 = [[output objectAtIndex:0] stringValue];
        if([p1 isEqualToString:@"1"] == TRUE)
        {
            BOOL mediaSubmitSuccess = YES;
            
            NSMutableArray *inspectionItems = [[NSMutableArray alloc] initWithArray: [coreDataManager AllInspectionItemsByInspectionID:inspectionID]];
            FileManager *fileManager = [FileManager alloc];
            
            for(int j=0;j<[inspectionItems count];j++)
            {
                NSNumber *inspectionItemID = [[inspectionItems objectAtIndex:j] valueForKey:@"InspectionItemID"];
                
                NSMutableArray *mediaObjects = [[NSMutableArray alloc] initWithArray: [coreDataManager GetUnSubmitMediaObjectsByInspectionItemID:inspectionItemID AndType:@"Photo" AndInspectionID:inspectionID]];
                
                for (int k=0; k<[mediaObjects count]; k++) {
                    MediaObject *mediaObj = (MediaObject *)[mediaObjects objectAtIndex:k];
                    
                    UIImage *imageData = [UIImage alloc];
                    imageData = [fileManager loadImage:[mediaObj URL]];
                    
                    NSData *DataOfImage = UIImageJPEGRepresentation(imageData, 1.0);
                    NSString *encodedString = [DataOfImage base64Encoding];
                    
                    BOOL temp = [self SubmitMediaObjectInspectionID:inspectionID InspectionItemID:inspectionItemID Data:encodedString];
                        
                    if(temp == NO)
                        mediaSubmitSuccess = NO;
                    else
                    {
                        [mediaObj setIsSubmitted:[NSNumber numberWithBool:YES]];
                        [coreDataManager SaveObjectContext];
                    }
                }
                
                mediaObjects = [[NSMutableArray alloc] initWithArray:[coreDataManager GetDeletedMediaObjectsByInspectionItemID:inspectionItemID AndType:@"Photo" AndInspectionID:inspectionID]];
                
                for (int k=0; k<[mediaObjects count]; k++) {
                    NSNumber *mediaObjectID = [[mediaObjects objectAtIndex:k] valueForKey:@"MediaObjectID"];
                    
                    BOOL temp = [self DeleteMediaObject:mediaObjectID];
                    
                    if(temp == NO)
                        mediaSubmitSuccess = NO;
                    else
                    {
                        MediaObject *mediaObj = (MediaObject *)[mediaObjects objectAtIndex:k];
                        [__managedObjectContext deleteObject:mediaObj];
                        [coreDataManager SaveObjectContext];
                    }
                }
                
                [mediaObjects release];
            }
            
            if(mediaSubmitSuccess == YES)
            {
                NSMutableArray *dataInspection = [coreDataManager GetInspectionByID:inspectionID];
            
                if([dataInspection count]>0)
                {
                    Inspections *currentInspection = (Inspections*) [dataInspection objectAtIndex:0];
                    [currentInspection setIsQueued:[NSNumber numberWithBool:NO]];
                    [currentInspection setHasUpdated:[NSNumber numberWithBool:NO]];
                    [coreDataManager SaveObjectContext]; 
                    hasSubmit = YES;
                }
            }
        }
    }];
    
    [request setFailedBlock:^{
        NSLog(@"blocks Error");
    }];
    
    [request startSynchronous];
}

BOOL isSuccess = NO;

-(BOOL)DeleteMediaObject:(NSNumber *)mediaObjectID
{
    isSuccess = NO;
    
    UserDataManager *dataManager = [UserDataManager alloc];
    NSString *serviceUrl = [NSString stringWithFormat:@"http://api.hwptest.info/services/deletemediaobject/%@", [dataManager retrieveAccessKey]];
    NSURL *url = [NSURL URLWithString:serviceUrl];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setPostValue:mediaObjectID forKey:@"MediaObjectID"];
    
    [request setCompletionBlock:^{
        NSLog(@"blocks Completion");
        NSString *responseString = [request responseString];
        NSDictionary *dictionary = [responseString JSONValue];
        NSArray *output = [dictionary allValues]; 
        NSString *p1 = [[output objectAtIndex:0] stringValue];
        
        if([p1 isEqualToString:@"1"] == TRUE)
        {        
            isSuccess = YES;
        }
    }];
    
    [request setFailedBlock:^{
        NSLog(@"blocks Error");
    }];
    
    [request startSynchronous];    
    return isSuccess;
}

-(BOOL)SubmitMediaObjectInspectionID:(NSNumber *)inspectionID InspectionItemID:(NSNumber *)inspectionItemID Data:(NSString *) data
{
    isSuccess = NO;
    
    UserDataManager *dataManager = [UserDataManager alloc];
    NSString *serviceUrl = [NSString stringWithFormat:@"http://api.hwptest.info/services/addmediaobject/%@", [dataManager retrieveAccessKey]];
    NSURL *url = [NSURL URLWithString:serviceUrl];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setPostValue:inspectionID forKey:@"InspectionID"];
    [request setPostValue:inspectionItemID forKey:@"InspectionItemID"];
    [request setPostValue:data forKey:@"File"];
    
    [request setCompletionBlock:^{
        NSLog(@"blocks Completion");
        NSString *responseString = [request responseString];
        
        //AlertManager *alert = [AlertManager alloc];
        //[alert showAlert:responseString Title:@"error"];
        
        NSDictionary *dictionary = [responseString JSONValue];
        NSArray *output = [dictionary allValues]; 
        NSString *p1 = [[output objectAtIndex:0] stringValue];
        
        if([p1 isEqualToString:@"1"] == TRUE)
        {        
            isSuccess = YES;
        }
    }];
    
    [request setFailedBlock:^{
        NSLog(@"blocks Error");
    }];
    
    [request startSynchronous];
    
    return isSuccess;
}

@end
