//
//  HypnosisViewController.m
//  HypnoTime
//
//  Created by Richard Shin on 11/17/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "HypnosisViewController.h"
#import "HypnosisView.h"

@interface HypnosisViewController ()

@end

@implementation HypnosisViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    // Passing nil for both arguments is equivalent to calling the plain init method.
    // This method will auto-magically find the equivalent XIB file.
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Set up UITabBarItem for this VC
        UITabBarItem *tabBarItem = [self tabBarItem];
        tabBarItem.title = @"Hypnosis";
        tabBarItem.image = [UIImage imageNamed:@"Hypno.png"];
        [self setTabBarItem:tabBarItem];
    }
    return self;
}

- (void)loadView
{
    // In loadView, we don't call super loadView -- if we did, it would kick
    // off a search for a XIB file to load, which we don't want.
    CGRect frame = [[UIScreen mainScreen] bounds];
    HypnosisView *view = [[HypnosisView alloc] initWithFrame:frame];
    
    self.view = view;
}

static NSArray *colors;

// Note: Starting with iOS 6, VCs are no longer unloaded during
// memory warnings, and the idiomatic method of dealing with low memory
// warnings is to use the didReceiveMemoryWarning method to deallocate
// any unused resources.
- (void)viewDidLoad
{
    NSLog(@"Hypnosis VC did load");
    
    // Ch. 7 Silver Challenge - add a segmented control to hypnosis tab
    // to control the circle color
    if (!colors) colors = @[@"Red", @"Green", @"Blue"];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:colors];
    segmentedControl.center = CGPointMake(self.view.center.x, 20+segmentedControl.bounds.size.height/2);
    [segmentedControl addTarget:self action:@selector(colorSelected:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedControl];
}

// Ch. 7 Silver Challenge
- (void)colorSelected:(UISegmentedControl *)sender
{
    HypnosisView *view = (HypnosisView *)self.view;
    switch (sender.selectedSegmentIndex) {
        case 0:
            [view setCircleColor:[UIColor redColor]];
            break;
        case 1:
            [view setCircleColor:[UIColor greenColor]];
            break;
        case 2:
            [view setCircleColor:[UIColor blueColor]];
            break;
    }
}


@end
