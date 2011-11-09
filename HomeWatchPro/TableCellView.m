//
//  TableCellView.m
//  SimpleTable
//
//  Created by Adeem on 30/05/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TableCellView.h"


@implementation TableCellView

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

- (void)setLabelText:(NSString *)_text{
    cellText.text = _text;
}

- (void)setStatus:(NSString *)_text{
    productImg.hidden = NO;
    CGRect aFrame = cellText.frame;
    aFrame.size.width = 182;
    cellText.frame = aFrame;    
    
    if([_text isEqualToString:@"Assigned"]==TRUE )
        productImg.image = [UIImage imageNamed:@"ball_blue.png"];
    else if([_text isEqualToString:@"Queued"]==TRUE)
        productImg.image = [UIImage imageNamed:@"ball_yellow.png"];  
    else if([_text isEqualToString:@"Received"]==TRUE)
        productImg.image = [UIImage imageNamed:@"ball_orange.png"];
    else if([_text isEqualToString:@"Rejected"]==TRUE)
        productImg.image = [UIImage imageNamed:@"ball_green.png"];
    else
    {
        productImg.hidden = YES;
        aFrame = cellText.frame;
        aFrame.size.width = 270;
        cellText.frame = aFrame;
    }
}

- (void)setBackGroundImage:(NSString *)_text
{
    [self imageView].image = [UIImage imageNamed:_text]; 
    //[self imageView].image = [UIImage imageNamed:_text];
}

@end
