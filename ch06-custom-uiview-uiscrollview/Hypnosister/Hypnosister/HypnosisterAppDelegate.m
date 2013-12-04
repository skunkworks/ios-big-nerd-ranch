//
//  HypnosisterAppDelegate.m
//  Hypnosister
//
//  Created by Richard Shin on 11/17/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "HypnosisterAppDelegate.h"
#import "BNRLogoView.h"

@implementation HypnosisterAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    CGRect windowBounds = [[self window] bounds];
    
    // To get this to work in iOS 7, you have to add this line to the info.plist (case sensitive):
    // View controller-based status bar appearance
    // Type: Boolean
    // Value: NO
    // [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:windowBounds];
    [[self window] addSubview:scrollView];
    
    CGRect hypnosisViewRect = CGRectMake(0, 0, windowBounds.size.width, windowBounds.size.height);
    _hypnosisView = [[HypnosisView alloc] initWithFrame:hypnosisViewRect];
    [_hypnosisView becomeFirstResponder];
    
    // Ch. 5 Gold Challenge - Draw a clipped circle logo image
    CGRect logoViewRect = CGRectMake(100, 100, 100, 100);
    BNRLogoView *logoView = [[BNRLogoView alloc] initWithFrame:logoViewRect];
    [_hypnosisView addSubview:logoView];
    
    [scrollView addSubview:_hypnosisView];
    // Can't forget to set the scroll view content size!
    [scrollView setContentSize:windowBounds.size];
    // Scroll view zoom settings
    scrollView.minimumZoomScale = 1.0;
    scrollView.maximumZoomScale = 5.0;
    [scrollView setDelegate:self];
    
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _hypnosisView;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
