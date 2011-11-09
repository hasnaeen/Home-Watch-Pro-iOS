//
//  ItemTableCell.h
//  HomeWatchPro
//
//  Created by USER on 7/6/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ItemTableCell : UITableViewCell {
    IBOutlet UILabel *cellText;
    IBOutlet UIImageView *okImage;
    IBOutlet UIImageView *notesImage;
}

- (void)setLabelText:(NSString *)_text;
- (void)SetFullLabelTest:(NSString *)_text;
- (void)setBackGroundImage:(NSString *)_text;
- (void)ShowOkImage;
- (void)ShowNotesImage;
- (void)HideOkImage;

@end
