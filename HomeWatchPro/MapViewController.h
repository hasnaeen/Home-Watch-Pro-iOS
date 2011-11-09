//
//  MapViewController.h
//  HomeWatchPro
//
//  Created by USER on 7/17/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController {
    IBOutlet UIImageView *backImage;
    IBOutlet UIButton *btnBack;
    IBOutlet MKMapView *mapView;
    NSString *currentAddress;
}

@property (nonatomic, retain) NSString *currentAddress;

- (IBAction)BackClicked:(id)sender;
-(CLLocationCoordinate2D) addressLocation:(NSString *)address;
- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated;

@end
