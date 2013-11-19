//
//  TimeViewController.m
//  HypnoTime
//
//  Created by Richard Shin on 11/17/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "TimeViewController.h"

@implementation TimeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Set up UITabBarItem for this VC
        UITabBarItem *tabBarItem = [self tabBarItem];
        tabBarItem.title = @"Time";
        tabBarItem.image = [UIImage imageNamed:@"Time.png"];
        [self setTabBarItem:tabBarItem];
    }
    return self;
}

- (IBAction)showCurrentTime:(UIButton *)sender
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    formatter.timeStyle = NSDateFormatterMediumStyle;
    timeLabel.text = [formatter stringFromDate:[NSDate date]];
}

// Note: Starting with iOS 6, VCs are no longer unloaded during
// memory warnings, and the idiomatic method of dealing with low memory
// warnings is to use the didReceiveMemoryWarning method to deallocate
// any unused resources.
- (void)viewDidLoad
{
    NSLog(@"Time VC did load");
    
    // Very important point: any setup that directly accesses the view or any
    // other view in the view hierarchy should be done in viewDidLoad and not
    // by initWithNibName:bundle:. This is because the view can be unloaded.
    self.view.backgroundColor = [UIColor greenColor];
}

// A pedagogical point: a view controller and its view are separate objects.

// Called when this view is added to a view hierarchy. In our case, when the
// tab VC adds and removes this.
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"TimeViewController will appear");
    [self showCurrentTime:nil];
}

// Called when this view is removed from a view hierarchy
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"TimeViewController will disappear");
}

@end
