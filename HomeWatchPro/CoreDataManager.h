//
//  CoreDataManager.h
//  HomeWatchPro
//
//  Created by USER on 6/29/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Inspections.h"

@interface CoreDataManager : NSObject {
    
    NSManagedObjectContext *managedObjectContext;
	NSMutableArray *dataArray;   
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableArray *dataArray;


-(void)Context:(NSManagedObjectContext *) context;

-(void)DeleteAllInspections;
-(void)DeleteAllWithOutQueued:(NSMutableDictionary *)inspectionIds;
-(void)AddInspection: (NSString *)property Community:(NSString *) inspector DueDate:(NSData *) dueDate
       InspectionDate:(NSData *) inspectionDate Status:(NSString *) status InspectionID:(NSNumber *) inspectionID
                Notes:(NSString *) note SpecialInstructions:(NSString *) instruction;
-(NSMutableArray*)AllInspection;
-(NSMutableArray*)GetFourTypeInspection;
-(NSMutableArray*)GetAllInspectionByStatus:(NSString *)status;
-(NSMutableArray*)GetAllHoldInspection;
-(NSMutableArray*)GetInspectionByID:(NSNumber *)currentID;

-(void)DeleteAllInspectionItem;
-(NSMutableArray*)AllInspectionItems;
-(NSMutableArray*)AllInspectionItemsByInspectionID:(NSNumber *)inspectionID;
-(void)AddInspectionItem: (NSNumber *) inspectionItemID InspectionID: (NSNumber *) inspectionID
                    Name: (NSString *)name Notes:(NSString *) note Status:(NSString *) status
         NoteToHomeowner: (NSString *) notesTOHomeowner NotesToPropertyManager:(NSString *) notesToPropertyManager RecurringNotes:(NSString *) recurringNotes;
-(NSMutableArray*)GetInspectionItemByID:(NSNumber *)inspectionItemID InspectionID:(NSNumber *) inspectionID;
-(NSNumber*)GetInspectionItemIDByInspectionID:(NSNumber *)inspectionId AndName:(NSString *)name;


-(void)DeleteAllMediaObject;
-(NSMutableArray*)AllMediaObjects;
-(void)AddMediaObject: (NSNumber *) inspectionItemID Type:(NSString *) type FileName:(NSString *) fileName URl:(NSString *)url InspectionID:(NSNumber *)inspectionID IsSubmitted:(BOOL) isSubmitted MediaObjectID:(NSNumber *)mediaObjectID IsDeleted:(BOOL) isDeleted;
-(NSMutableArray*)GetMediaObjectsByInspectionItemID:(NSNumber *)inspectionItemID AndType:(NSString *)type AndInspectionID:(NSNumber *) inspectionID;
-(NSMutableArray*)GetUnDeletedMediaObjectsByInspectionItemID:(NSNumber *)inspectionItemID AndType:(NSString *)type AndInspectionID:(NSNumber *) inspectionID;
-(NSMutableArray*)GetMediaObjectsByInspectionItemID:(NSNumber *)inspectionItemID AndInspectionID:(NSNumber *) inspectionID;
-(NSMutableArray*)GetUnSubmitMediaObjectsByInspectionItemID:(NSNumber *)inspectionItemID AndType:(NSString *)type AndInspectionID:(NSNumber *) inspectionID;
-(NSMutableArray*)GetDeletedMediaObjectsByInspectionItemID:(NSNumber *)inspectionItemID AndType:(NSString *)type AndInspectionID:(NSNumber *) inspectionID;
-(void)SaveObjectContext;

@end
