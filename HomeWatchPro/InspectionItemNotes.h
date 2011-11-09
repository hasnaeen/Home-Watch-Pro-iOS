//
//  InspectionItemNotes.h
//  HomeWatchPro
//
//  Created by USER on 7/7/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface InspectionItemNotes : UIViewController {
    IBOutlet UIButton *btnBack;
    IBOutlet UITextView *tvNotes;
    IBOutlet UILabel *lblTitle;
    IBOutlet UIButton *btnSave;
    NSString *currentNotes;
    NSString *currentTitle;
    BOOL Editable;
}

@property (nonatomic, retain) NSString *currentNotes;
@property (nonatomic, retain) NSString *currentTitle;
@property BOOL Editable;

- (IBAction)BackClicked:(id)sender;
- (IBAction)SaveClicked:(id)sender;

@end
