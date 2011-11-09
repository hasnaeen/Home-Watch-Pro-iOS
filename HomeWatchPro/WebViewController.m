//
//  WebViewController.m
//  HomeWatchPro
//
//  Created by Stitz on 6/23/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import "WebViewController.h"


@implementation WebViewController
@synthesize webview, urlString, linkRequest;


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


- (void)viewDidLoad {
    [super viewDidLoad];
    //[[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self loadUrl];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupWebView];
}

- (void)setupWebView {
    webview.opaque = NO;
    webview.backgroundColor = [UIColor clearColor];
}


- (void)loadUrl {
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    [webview loadRequest:request];
    
    [url release];
    [request release];
}



- (void)done {
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - View lifecycle



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

@end
