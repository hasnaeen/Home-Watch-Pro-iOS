//
//  InspectionItemDetailsViewController.h
//  HomeWatchPro
//
//  Created by USER on 7/7/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InspectionItem.h"
#import "Inspections.h"

@interface InspectionItemDetailsViewController : UIViewController {
    IBOutlet UIButton *btnBack;
    IBOutlet UIButton *btnNotes;
    IBOutlet UIButton *btnRecurringNotes;
    IBOutlet UIButton *btnNotesToHomeowner;
    IBOutlet UIButton *btnNotesToPropertyManager;
    IBOutlet UIButton *btnPhotos;
    IBOutlet UIButton *btnVideos;
    IBOutlet UIButton *btnSave;
    IBOutlet UILabel *lblName;    
    IBOutlet UISegmentedControl *segmentControl;   
    IBOutlet UIImageView *notesToHomeownerImage;
    IBOutlet UIImageView *notesToPropertyManagerImage;
    IBOutlet UIImageView *notesToNotes;
    IBOutlet UIImageView *notesToRecurringNotes;
    NSNumber *currentInspectionID;
    NSNumber *currentInspectionItemID;
    InspectionItem *currentInspectionItem;
    Inspections *currentInspection;
    NSString *currentEdit;
    NSString *notes;
    NSString *notesToHomeowner;
    NSString *notesToPropertyManager;
    NSString *status;
    NSMutableArray *currentInspectionItemImages;
    NSMutableArray *tempAddInspectionItemPhotosArray;
}

@property (nonatomic, retain) NSNumber *currentInspectionItemID;
@property (nonatomic, retain) NSNumber *currentInspectionID;
@property (nonatomic, retain) InspectionItem *currentInspectionItem;
@property (nonatomic, retain) Inspections *currentInspection;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentControl;
@property (nonatomic, retain) NSString *currentEdit;
@property (nonatomic, retain) NSString *notes;
@property (nonatomic, retain) NSString *notesToHomeowner;
@property (nonatomic, retain) NSString *notesToPropertyManager;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSMutableArray *currentInspectionItemImages;
@property (nonatomic, retain) NSMutableArray *tempAddInspectionItemPhotosArray;

-(void)Context:(NSManagedObjectContext *) context;
- (IBAction)BackClicked:(id)sender;
- (IBAction)segmentedControlValueChanged;
-(void)segmentedControlSelected;
- (IBAction)EditClicked:(id)sender;
- (void)EditSave:(NSString*)note;
- (IBAction)SaveDetails:(id)sender;

@end
