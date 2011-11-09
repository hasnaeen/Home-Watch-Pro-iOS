//
//  MediaObject.h
//  HomeWatchPro
//
//  Created by USER on 8/9/11.
//  Copyright (c) 2011 CSN Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MediaObject : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * InspectionItemID;
@property (nonatomic, retain) NSString * URL;
@property (nonatomic, retain) NSString * Type;
@property (nonatomic, retain) NSNumber * InspectionID;
@property (nonatomic, retain) NSString * Title;
@property (nonatomic, retain) NSNumber * IsSubmitted;
@property (nonatomic, retain) NSNumber * MediaObjectID;
@property (nonatomic, retain) NSNumber * IsDeleted;

@end
