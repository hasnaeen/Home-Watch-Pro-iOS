//
//  InspectionItemVideos.h
//  HomeWatchPro
//
//  Created by USER on 7/11/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h> 

@interface InspectionItemVideos : UIViewController {
    IBOutlet UIButton *btnBack;
    IBOutlet UIButton *btnNext;
    IBOutlet UIButton *btnPrevious;
    IBOutlet UIButton *btnPlay;
    IBOutlet UILabel *videoLabel;
    NSNumber *currentInspectionItemID;
    NSNumber *currentInspectionID;
    NSMutableArray *inspectionItemVideosArray;
    NSNumber *currentVideoIndex;
    MPMoviePlayerController *moviePlayerController;
}

@property (nonatomic, retain) NSNumber *currentInspectionItemID;
@property (nonatomic, retain) NSNumber *currentInspectionID;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableArray *inspectionItemVideosArray;
@property (nonatomic, retain) NSNumber *currentVideoIndex;
@property (nonatomic, retain) MPMoviePlayerController *moviePlayerController;

- (IBAction)BackClicked:(id)sender;
- (IBAction)PlayClicked:(id)sender;
- (IBAction)VideoChangeClicked:(id)sender;
-(void)Context:(NSManagedObjectContext *) context;
-(void)VideoLoad;

@end
