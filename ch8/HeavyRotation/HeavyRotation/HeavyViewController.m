//
//  HeavyViewController.m
//  HeavyRotation
//
//  Created by Richard Shin on 11/17/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "HeavyViewController.h"

@interface HeavyViewController ()

@end

@implementation HeavyViewController

// Ch. 8 Bronze Challenge - get proximity notifications
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIDevice *device = [UIDevice currentDevice];
    device.proximityMonitoringEnabled = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(proximityChanged:)
                                                 name:UIDeviceProximityStateDidChangeNotification
                                               object:device];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)proximityChanged:(NSNotification *)sender
{
    UIDevice *device = sender.object;
    if (device.proximityState) {
        NSLog(@"Close to user!");
    } else {
        NSLog(@"Far from user...");
    }
}

// shouldAutorotate... was deprecated in iOS 6; instead, use this:
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
