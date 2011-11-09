//
//  InspectionViewController.h
//  HomeWatchPro
//
//  Created by USER on 7/17/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Inspections.h"

@interface InspectionViewController : UIViewController {
    IBOutlet UIButton *btnMap;
    IBOutlet UIButton *btnMakeAllOk;
    IBOutlet UIButton *btnSubmitInspection;
    IBOutlet UIButton *btnCancel;
    NSNumber *currentInspectionID;   
    Inspections *currentInspection;
}

@property (nonatomic, retain) NSNumber *currentInspectionID;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Inspections *currentInspection;

- (IBAction)ButtonClicked:(id)sender;
-(void)Context:(NSManagedObjectContext *) context;
- (void)Reload;
- (void)PrepareForSubmitInspection;
- (void)InspectionSubmited;

@end
