//
//  InspectionItem.h
//  HomeWatchPro
//
//  Created by USER on 7/19/11.
//  Copyright (c) 2011 CSN Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface InspectionItem : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * Status;
@property (nonatomic, retain) NSNumber * InspectionID;
@property (nonatomic, retain) NSString * NotesToPropertyManager;
@property (nonatomic, retain) NSString * Notes;
@property (nonatomic, retain) NSString * Name;
@property (nonatomic, retain) NSNumber * InspectionItemID;
@property (nonatomic, retain) NSString * NotesToHomeowner;
@property (nonatomic, retain) NSString * RecurringNotes;

@end
