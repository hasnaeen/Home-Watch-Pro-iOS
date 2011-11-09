//
//  InspectionSubmitManager.h
//  HomeWatchPro
//
//  Created by USER on 7/14/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataManager.h"

@interface InspectionSubmitManager : NSObject {
    CoreDataManager *coreDataManager;
    BOOL hasSubmit;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) CoreDataManager *coreDataManager;
@property (assign) BOOL hasSubmit;

-(void)Context:(NSManagedObjectContext *) context;
-(void)SubmitInspection;
-(void)SubmitRequestInspectionID:(NSNumber *)inspectionID Data:(NSString *)data;
-(BOOL)SubmitMediaObjectInspectionID:(NSNumber *)inspectionID InspectionItemID:(NSNumber *)inspectionItemID Data:(NSString *) data;
-(BOOL)DeleteMediaObject:(NSNumber *)mediaObjectID;

@end
