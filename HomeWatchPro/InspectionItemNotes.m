//
//  InspectionItemNotes.m
//  HomeWatchPro
//
//  Created by USER on 7/7/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import "InspectionItemNotes.h"
#import "InspectionItemDetailsViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation InspectionItemNotes

@synthesize currentNotes,Editable,currentTitle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[tvNotes layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[tvNotes layer] setBorderWidth:1];
    [[tvNotes layer] setCornerRadius:10];
    [tvNotes setClipsToBounds: YES];
    
    
    if(currentTitle != NULL && [currentTitle isEqualToString:@""] != TRUE)
        lblTitle.text = currentTitle;
    else
        lblTitle.text = @"";
    
    if(currentNotes != NULL && [currentNotes isEqualToString:@"None"] !=TRUE)
        tvNotes.text = currentNotes;
    else
        tvNotes.text = @"";
    
    if(Editable == NO)
    {
        tvNotes.editable = FALSE;
        btnSave.hidden = TRUE;
    }
    else
    {
        tvNotes.editable = TRUE;
        btnSave.hidden = FALSE;
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)BackClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        InspectionItemDetailsViewController *parent = (InspectionItemDetailsViewController*)[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-2];
        [parent EditSave:tvNotes.text];
        
        [self.navigationController popViewControllerAnimated:YES];
        return NO;
    }
    
    return YES;
}

- (IBAction)SaveClicked:(id)sender
{
    InspectionItemDetailsViewController *parent = (InspectionItemDetailsViewController*)[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-2];
    [parent EditSave:tvNotes.text];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
