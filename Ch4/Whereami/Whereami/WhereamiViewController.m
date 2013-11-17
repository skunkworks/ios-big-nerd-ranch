//
//  WhereamiViewController.m
//  Whereami
//
//  Created by Richard Shin on 11/16/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "WhereamiViewController.h"

@interface WhereamiViewController () <CLLocationManagerDelegate>

@end

@implementation WhereamiViewController

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
}

- (void)setupLocationManager
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // Bronze challenge
    locationManager.distanceFilter = 50;
    
    // Silver challenge
    if ([CLLocationManager headingAvailable])
        [locationManager startUpdatingHeading];
    
    [locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateLocations:(NSArray *)locations
{
    NSLog(@"%@", locations);
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

// Book has the dealloc method set the delegate to nil.
// I think idiomatically, you'd want to start and stop updating location in
// the viewWillAppear/viewWillDisappear methods
- (void)dealloc
{
    locationManager.delegate = nil;
}
@end
