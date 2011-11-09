//
//  InspectionsManager.h
//  HomeWatchPro
//
//  Created by USER on 6/29/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataManager.h"

@interface LoadDataManager : NSObject {
    CoreDataManager *coreDataManager;
    NSError *error;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) CoreDataManager *coreDataManager;
@property (nonatomic, retain) NSError *error;

-(void)Context:(NSManagedObjectContext *) context;
-(BOOL)LoadInspectionsAndItems;
-(void)LoadMediaObject;
-(void)LoadMediaObjectForInspectionID:(NSNumber *)inspectionID;
-(BOOL)IsInternateAvailable;

@end
