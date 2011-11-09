//
//  InspectionsViewController.h
//  HomeWatchPro
//
//  Created by Stitz on 6/23/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "TableCellView.h"
#import "InspectionSubmitManager.h"

@interface InspectionsViewController : UIViewController <NSFetchedResultsControllerDelegate> {
    // UIScrollView            *myScrollView;
    IBOutlet UITableView *tblSimpleTable;
    IBOutlet TableCellView *tblCell;
    IBOutlet UILabel *lblAssign;
    IBOutlet UILabel *lblDate;
    IBOutlet UIButton *btnRefresh;
    IBOutlet UIButton *btnLogout;
    IBOutlet UILabel *lblTimer;
    IBOutlet UISegmentedControl *segmentControl;
    NSTimer *refreshTimer;
    NSMutableArray *inspectionArray;
    NSString *currentStatus;
    BOOL hasInspection;
    NSInteger timerCount;
    InspectionSubmitManager *inspectionSubmitManager;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
//@property (nonatomic,retain) IBOutlet UIScrollView *myScrollView;
@property (nonatomic,retain) IBOutlet UITableView *tblSimpleTable;
@property (nonatomic,retain) IBOutlet TableCellView *tblCell;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentControl;
@property (nonatomic, retain) NSMutableArray *inspectionArray;
@property (nonatomic, retain) NSString *currentStatus;
@property (assign) NSTimer *refreshTimer;
@property BOOL hasInspection;
@property (assign) NSInteger timerCount;
@property (nonatomic, retain) InspectionSubmitManager *inspectionSubmitManager;

- (IBAction)segmentedControlValueChanged;
- (IBAction)RefreshClicked:(id)sender;
- (IBAction)LogoutClicked:(id)sender;
-(void)Reload;
-(void)ReloadView;
-(void)ReloadTableItem;
- (void)timerFireMethod:(NSTimer*)theTimer;
- (void)SubmitInspections;

@end
