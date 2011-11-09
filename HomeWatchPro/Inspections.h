//
//  Inspections.h
//  HomeWatchPro
//
//  Created by USER on 7/31/11.
//  Copyright (c) 2011 CSN Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Inspections : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * IsQueued;
@property (nonatomic, retain) NSString * SpecialInstructions;
@property (nonatomic, retain) NSString * Status;
@property (nonatomic, retain) NSNumber * InspectionID;
@property (nonatomic, retain) NSDate * DueDate;
@property (nonatomic, retain) NSString * Property;
@property (nonatomic, retain) NSDate * InspectionDate;
@property (nonatomic, retain) NSString * Notes;
@property (nonatomic, retain) NSString * Community;
@property (nonatomic, retain) NSNumber * HasUpdated;

@end
