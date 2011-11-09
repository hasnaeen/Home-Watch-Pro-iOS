//
//  InspectionItemPhotosController.h
//  HomeWatchPro
//
//  Created by USER on 7/10/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Inspections.h"
#import "FileManager.h"
#import "SDWebImageManagerDelegate.h"

@interface InspectionItemPhotosController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, SDWebImageManagerDelegate>
{
    IBOutlet UIButton *btnBack;
    IBOutlet UIButton *btnBackEmpty;
    IBOutlet UIButton *btnNext;
    IBOutlet UIButton *btnPrevious;
    IBOutlet UIButton *btnAddPhoto;
    IBOutlet UIButton *btnDeletePhoto;
    IBOutlet UIImageView *currentImage;
    IBOutlet UIImageView *topBarImage;
    IBOutlet UIImageView *buttomBarImage;
    IBOutlet UILabel *imageLabel;
    IBOutlet UILabel *noImageLabel1;
    IBOutlet UILabel *noImageLabel2;
    NSNumber *currentInspectionItemID;
    NSNumber *currentInspectionID;
    NSMutableArray *inspectionItemPhotosArray;
    NSMutableArray *tempAddInspectionItemPhotosArray;
    Inspections *currentInspection;
    FileManager *fileManager;
}

@property (nonatomic, retain) NSNumber *currentInspectionItemID;
@property (nonatomic, retain) NSNumber *currentInspectionID;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableArray *inspectionItemPhotosArray;
@property (nonatomic, retain) NSMutableArray *tempAddInspectionItemPhotosArray;
@property (nonatomic, retain) Inspections *currentInspection;
@property (nonatomic, retain) FileManager *fileManager;

- (IBAction)BackClicked:(id)sender;
- (IBAction)DeleteClick:(id)sender;
- (IBAction)ImageChangeClicked:(id)sender;
- (void)Context:(NSManagedObjectContext *) context;
- (void)ImageLoad;
- (IBAction)AddImageClicked:(id)sender;
- (UIImage *)scaleAndRotateImage:(UIImage *)image;
- (UIImage *) ImageDownloadFromWeb:(NSURL *)url;

@end
