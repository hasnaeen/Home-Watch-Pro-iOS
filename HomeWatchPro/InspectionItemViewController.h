//
//  InspectionItemViewController.h
//  HomeWatchPro
//
//  Created by USER on 7/6/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Inspections.h"
#import "ItemTableCell.h"

@interface InspectionItemViewController : UIViewController {
    IBOutlet UIButton *btnBack;
    IBOutlet UIButton *btnSubmitInspection;
    IBOutlet UIButton *btnInspectionView;
    IBOutlet UIButton *btnNotes;
    IBOutlet UIButton *btnSpecialInstraction;
    IBOutlet UIImageView *notesImage;
    IBOutlet UIImageView *specialInstractionImage;
    IBOutlet UILabel *lblAddress1;
    IBOutlet UILabel *lblAddress2;
    IBOutlet UILabel *lblCommunity;
    IBOutlet UILabel *lblDueDate;
    IBOutlet UILabel *lblQueuedText;
    IBOutlet UITableView *tblSimpleTable;
    IBOutlet ItemTableCell *tblItemCell;    
    NSNumber *currentInspectionID;
    Inspections *currentInspection;
    NSMutableArray *inspectionItemArray;
    BOOL hasInspectionItems;
}

@property (nonatomic, retain) NSNumber *currentInspectionID;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Inspections *currentInspection;
@property (nonatomic,retain) IBOutlet UITableView *tblSimpleTable;
@property (nonatomic,retain) IBOutlet ItemTableCell *tblItemCell;
@property (nonatomic, retain) NSMutableArray *inspectionItemArray;
@property BOOL hasInspectionItems;

- (IBAction)BackClicked:(id)sender;
-(void)Context:(NSManagedObjectContext *) context;
-(void) Reload;
- (IBAction)SubmitInspection:(id)sender;
- (IBAction)NoteClick:(id)sender;
- (IBAction)ClickInspectionView:(id)sender;
- (void)InspectionSubmited;

@end
