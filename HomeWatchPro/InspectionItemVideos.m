//
//  InspectionItemVideos.m
//  HomeWatchPro
//
//  Created by USER on 7/11/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import "InspectionItemVideos.h"
#import "CoreDataManager.h"
#import "AlertManager.h"
#import "MediaObject.h"
#import "MBProgressHUD.h"
#import "InspectionItem.h"

@implementation InspectionItemVideos

@synthesize currentInspectionItemID,inspectionItemVideosArray,currentVideoIndex,moviePlayerController,currentInspectionID;
@synthesize managedObjectContext=__managedObjectContext;

-(void)Context:(NSManagedObjectContext *) context
{
    self.managedObjectContext = context;
}

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
    
    currentVideoIndex = 0;
    CoreDataManager *dataManager = [CoreDataManager alloc];
    [dataManager Context:__managedObjectContext]; 
    
    NSMutableArray *data = [dataManager GetInspectionItemByID:currentInspectionItemID InspectionID:currentInspectionID];
    
    if([data count]>0)
    {
        InspectionItem *currentInspectionItem = (InspectionItem*) [data objectAtIndex:0];
        [btnBack setTitle:[NSString stringWithFormat:@" %@",[currentInspectionItem Name]] forState:UIControlStateNormal];
        [btnBack setTitle:[NSString stringWithFormat:@" %@",[currentInspectionItem Name]] forState:UIControlStateHighlighted];
        [btnBack setTitle:[NSString stringWithFormat:@" %@",[currentInspectionItem Name]] forState:UIControlStateDisabled];
        [btnBack setTitle:[NSString stringWithFormat:@" %@",[currentInspectionItem Name]] forState:UIControlStateSelected];
        
        NSString *temp = [NSString stringWithFormat:@" %@",[currentInspectionItem Name]];
        
        if([temp length]>8)
        {
            btnBack.frame = CGRectMake(17, 8, ([temp length] - 8) * 6 + 75, 30);
        }
    }
    
    inspectionItemVideosArray = [dataManager GetMediaObjectsByInspectionItemID:currentInspectionItemID AndType:@"Video" AndInspectionID:currentInspectionID];
    moviePlayerController = NULL;
    [self VideoLoad];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [inspectionItemVideosArray release];
    [moviePlayerController release];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)VideoLoad
{
    if((NSUInteger)currentVideoIndex < [inspectionItemVideosArray count])
    {
        videoLabel.text =[NSString stringWithFormat:@"%d of %d",((NSInteger)currentVideoIndex + 1),[inspectionItemVideosArray count]];
        
        MediaObject *item = [MediaObject alloc];
        item = (MediaObject *)[inspectionItemVideosArray objectAtIndex:(NSUInteger)currentVideoIndex];
        NSString *url =[item URL];
        NSURL * videoURL = [NSURL URLWithString:url];
        
        if(moviePlayerController !=NULL)
            [moviePlayerController.view removeFromSuperview];
        
        moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
        /*
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlaybackComplete:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:moviePlayerController];
        */
        [moviePlayerController.view setFrame:CGRectMake(btnPlay.frame.origin.x, 
                                                        btnPlay.frame.origin.y, 
                                                        btnPlay.frame.size.width, 
                                                        btnPlay.frame.size.height)];
        
        [self.view addSubview:moviePlayerController.view];
        [moviePlayerController prepareToPlay];
        [self.view bringSubviewToFront:btnPlay];
        //moviePlayerController.fullscreen = YES;
        
        //moviePlayerController.scalingMode = MPMovieScalingModeFill;
        
        //[moviePlayerController play];
    }
    else
    {
        videoLabel.text = @"0 of 0";
    }
}

- (void)moviePlaybackComplete:(NSNotification *)notification
{
    [self.view bringSubviewToFront:btnPlay];
    
    /*
    [[NSNotificationCenter defaultCenter] removeObserver:self
													name:MPMoviePlayerPlaybackDidFinishNotification
												  object:moviePlayerController];
	
    [moviePlayerController.view removeFromSuperview];
    [moviePlayerController release];
    moviePlayerController = NULL;
     */
}

- (IBAction)BackClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)PlayClicked:(id)sender
{
    if((NSUInteger)currentVideoIndex < [inspectionItemVideosArray count])
    {
        [moviePlayerController play];
        [self.view bringSubviewToFront:moviePlayerController.view];
    }
}

- (IBAction)VideoChangeClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if([inspectionItemVideosArray count]>0)
    {
        NSInteger tempIndex = (NSInteger)currentVideoIndex;
        
        if(button == btnNext)
        {
            tempIndex = (tempIndex + 1)%[inspectionItemVideosArray count];
            currentVideoIndex = (NSNumber*)tempIndex;
        }
        else if(button == btnPrevious)
        {
            tempIndex = tempIndex - 1;
            
            if(tempIndex<0)
                tempIndex = [inspectionItemVideosArray count] - 1;
            currentVideoIndex = (NSNumber *)tempIndex;
        }
    }
    
    [self VideoLoad];
}

@end
