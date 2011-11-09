//
//  ItemTableCell.m
//  HomeWatchPro
//
//  Created by USER on 7/6/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import "ItemTableCell.h"


@implementation ItemTableCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    /*
     if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
     // Initialization code
     }
     */
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}

- (void)ShowOkImage
{
    okImage.hidden = FALSE;
}

- (void)HideOkImage
{
    okImage.hidden = TRUE;
}

- (void)ShowNotesImage
{
    notesImage.hidden = FALSE;
}

- (void)setLabelText:(NSString *)_text
{
    CGRect aFrame = cellText.frame;
    aFrame.size.width = 182;
    cellText.frame = aFrame; 
    cellText.text = _text;
}

- (void)SetFullLabelTest:(NSString *)_text
{
    CGRect aFrame = cellText.frame;
    aFrame.size.width = 270;
    cellText.frame = aFrame; 
    cellText.text = _text;
}

- (void)setBackGroundImage:(NSString *)_text
{
    [self imageView].image = [UIImage imageNamed:_text]; 
    //[self imageView].image = [UIImage imageNamed:_text];
}

@end
