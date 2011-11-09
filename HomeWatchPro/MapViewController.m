//
//  MapViewController.m
//  HomeWatchPro
//
//  Created by USER on 7/17/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import "MapViewController.h"
#import "AlertManager.h"
#import "WebViewController.h"

#define MERCATOR_OFFSET 268435456
#define MERCATOR_RADIUS 85445659.44705395

@implementation MapViewController

@synthesize currentAddress;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
        
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
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
    
    CLLocationCoordinate2D location=[self addressLocation:currentAddress];
    
    [self setCenterCoordinate:location zoomLevel:10 animated:YES];
    
    MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
    [pin setCoordinate:location];
    pin.title = currentAddress;
    
    [mapView addAnnotation:pin];
    
    //AlertManager *alert = [AlertManager alloc];
    //[alert showAlert:[NSString stringWithFormat:@"%@ %@",location.latitude,location.longitude] Title:@"1"];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    UIActionSheet *actionSheet = NULL; 
    actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Driving Directions",nil];
    [actionSheet showInView:self.view];
	[actionSheet release];
}

-(void)ShowStoreDetail{
}

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString* annotationIdentifier = @"annotationIdentifier";
    
    MKPinAnnotationView* pinView = (MKPinAnnotationView *)
    [mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    MKPinAnnotationView* customPinView = [[[MKPinAnnotationView alloc]
                                           initWithAnnotation:annotation reuseIdentifier:nil] autorelease];
    if (!pinView)
    {
        customPinView.selected = TRUE;
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton addTarget:self
                        action:@selector(ShowStoreDetail)
                forControlEvents:UIControlEventTouchUpInside];
            customPinView.rightCalloutAccessoryView = rightButton;
        
        customPinView.animatesDrop = YES;
        customPinView.canShowCallout = YES;
        
        return customPinView;
    }
    else
    {
        pinView.annotation = annotation;
        
        customPinView.selected = TRUE;
        NSLog(@"customPinView.pinColor = MKPinAnnotationColorPurple;");
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton addTarget:self
                        action:@selector(ShowStoreDetail:)
                forControlEvents:UIControlEventTouchUpInside];
        customPinView.rightCalloutAccessoryView = rightButton;
        
    }
    return pinView;
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Google Maps"
                                                        message:@"You are about to close the app, would you like to continue?"
                                                       delegate:self    
                                              cancelButtonTitle:@"Cancel" 
                                              otherButtonTitles:@"OK", nil   ];
        [alert show];
        [alert release];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0)
    {
        
    }
    else
    {
        NSString *address = [currentAddress stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        UIApplication *app = [UIApplication sharedApplication];
        [app openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://maps.google.com/maps?q=%@",address]]];
        /*
        CLLocationCoordinate2D location=[self addressLocation:currentAddress];
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        WebViewController *webController = [[WebViewController alloc] init];
        webController.urlString = [NSString stringWithFormat:@"http://maps.google.com/?saddr=%1.6f,%1.6f",location.latitude,location.longitude];
        [self presentModalViewController:webController animated:YES];
        [webController release];
        */
    }
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

-(CLLocationCoordinate2D) addressLocation:(NSString *)address {
    NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%@&output=csv", 
						   [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *locationString = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString]];
    NSArray *listItems = [locationString componentsSeparatedByString:@","];
    
    double _latitude = 0.0;
    double _longitude = 0.0;
    
    if([listItems count] >= 4 && [[listItems objectAtIndex:0] isEqualToString:@"200"]) {
        _latitude = [[listItems objectAtIndex:2] doubleValue];
        _longitude = [[listItems objectAtIndex:3] doubleValue];
    }
    else {
		//Show error
    }
    CLLocationCoordinate2D _location;
    _location.latitude = _latitude;
    _location.longitude = _longitude;
    
	//NSLog(@"%f - %f", latitude, longitude);
    
    return _location;
}

- (double)longitudeToPixelSpaceX:(double)longitude
{
    return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / 180.0);
}

- (double)latitudeToPixelSpaceY:(double)latitude
{
    return round(MERCATOR_OFFSET - MERCATOR_RADIUS * logf((1 + sinf(latitude * M_PI / 180.0)) / (1 - sinf(latitude * M_PI / 180.0))) / 2.0);
}

- (double)pixelSpaceXToLongitude:(double)pixelX
{
    return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / M_PI;
}

- (double)pixelSpaceYToLatitude:(double)pixelY
{
    return (M_PI / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / M_PI;
}

- (MKCoordinateSpan)coordinateSpanWithMapView:(MKMapView *)mapView1
                             centerCoordinate:(CLLocationCoordinate2D)centerCoordinate
                                 andZoomLevel:(NSUInteger)zoomLevel
{
    // convert center coordiate to pixel space
    double centerPixelX = [self longitudeToPixelSpaceX:centerCoordinate.longitude];
    double centerPixelY = [self latitudeToPixelSpaceY:centerCoordinate.latitude];
    
    // determine the scale value from the zoom level
    NSInteger zoomExponent = 20 - zoomLevel;
    double zoomScale = pow(2, zoomExponent);
    
    // scale the map’s size in pixel space
    CGSize mapSizeInPixels = mapView1.bounds.size;
    double scaledMapWidth = mapSizeInPixels.width * zoomScale;
    double scaledMapHeight = mapSizeInPixels.height * zoomScale;
    
    // figure out the position of the top-left pixel
    double topLeftPixelX = centerPixelX - (scaledMapWidth / 2);
    double topLeftPixelY = centerPixelY - (scaledMapHeight / 2);
    
    // find delta between left and right longitudes
    CLLocationDegrees minLng = [self pixelSpaceXToLongitude:topLeftPixelX];
    CLLocationDegrees maxLng = [self pixelSpaceXToLongitude:topLeftPixelX + scaledMapWidth];
    CLLocationDegrees longitudeDelta = maxLng - minLng;
    
    // find delta between top and bottom latitudes
    CLLocationDegrees minLat = [self pixelSpaceYToLatitude:topLeftPixelY];
    CLLocationDegrees maxLat = [self pixelSpaceYToLatitude:topLeftPixelY + scaledMapHeight];
    CLLocationDegrees latitudeDelta = -1 * (maxLat - minLat);
    
    // create and return the lat/lng span
    MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
    return span;
}

#pragma mark -
#pragma mark Public methods

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated
{
    // clamp large numbers to 28
    zoomLevel = MIN(zoomLevel, 28);
    
    // use the zoom level to compute the region
    MKCoordinateSpan span = [self coordinateSpanWithMapView:mapView centerCoordinate:centerCoordinate andZoomLevel:zoomLevel];
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, span);
    
    // set the region like normal
    [mapView setRegion:region animated:animated];
}

@end
