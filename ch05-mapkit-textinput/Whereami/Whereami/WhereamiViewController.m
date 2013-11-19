//
//  WhereamiViewController.m
//  Whereami
//
//  Created by Richard Shin on 11/16/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "WhereamiViewController.h"
#import "BNRMapPoint.h"

@interface WhereamiViewController () <CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate>

@end

@implementation WhereamiViewController

# pragma mark - Setup and teardown

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self setupLocationManager];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupLocationManager];
    [self setupMapView];
    [self setupTextField];
}

// Book has the dealloc method set the delegate to nil.
// I think idiomatically, you'd want to start and stop updating location in
// the viewWillAppear/viewWillDisappear methods
- (void)dealloc
{
    locationManager.delegate = nil;
    worldView.delegate = nil;
}

- (void)setupLocationManager
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
}

- (void)setupMapView
{
    worldView.showsUserLocation = true;
    worldView.delegate = self;
    // Ch. 5 Bronze Challenge
    worldView.mapType = MKMapTypeSatellite;
}

- (void)setupTextField
{
    locationTitleField.delegate = self;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    if ([locations count]) {
        // Check that location update is fresher than 3 minutes
        CLLocation *lastUpdate = [locations lastObject];
        int secondsSinceLastUpdate = abs([[lastUpdate timestamp] timeIntervalSinceNow]);
        if (secondsSinceLastUpdate < 180)
            [self foundLocation:lastUpdate];
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading
{
    NSLog(@"Heading: %@", newHeading);
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"Could not receive location: %@", error);
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    // Zoom into user location
    [self zoomToLocationCoordinate:userLocation.coordinate];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self findLocation];
    [textField resignFirstResponder];
    return NO;
}

- (void)zoomToLocationCoordinate:(CLLocationCoordinate2D)coord
{
    MKCoordinateRegion userRegion = MKCoordinateRegionMakeWithDistance(coord, 250, 250);
    [worldView setRegion:userRegion animated:YES];
}

#pragma mark - WhereamiViewController methods

// Called when user enters location to find.
// Uses CLLocationManager to try to get current user location.
- (void)findLocation
{
    // Freeze UI while we search...
    [activityIndicator startAnimating];
    locationTitleField.enabled = NO;
    [locationManager startUpdatingLocation];
}

// Called when current user location has been pinpointed.
// Adds map annotation with title text.
- (void)foundLocation:(CLLocation *)location
{
    [locationManager stopUpdatingLocation];
    
    CLLocationCoordinate2D coord = location.coordinate;
    
    // Add map annotation to map view
    BNRMapPoint *mapPoint = [[BNRMapPoint alloc] initWithCoordinate:coord
                                                          withTitle:locationTitleField.text];
    [worldView addAnnotation:mapPoint];
    [self zoomToLocationCoordinate:coord];
    
    // Re-enable UI
    [activityIndicator stopAnimating];
    locationTitleField.enabled = YES;
}

// Ch. 5 Silver Challenge - add segmented control to toggle map type
- (IBAction)mapTypeChanged:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex) {
        case 0:
            worldView.mapType = MKMapTypeStandard;
            break;
        case 1:
            worldView.mapType = MKMapTypeSatellite;
            break;
        case 2:
            worldView.mapType = MKMapTypeHybrid;
            break;
    }
}

@end
