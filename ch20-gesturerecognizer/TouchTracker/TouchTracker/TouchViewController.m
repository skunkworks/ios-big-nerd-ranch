//
//  TouchViewController.m
//  TouchTracker
//
//  Created by Richard Shin on 1/28/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "TouchViewController.h"
#import "TouchDrawView.h"

@implementation TouchViewController

#pragma mark - Lifecycle

- (void)loadView
{
    TouchDrawView *view = [[TouchDrawView alloc] initWithFrame:CGRectZero];
    
    NSArray *savedLines = [NSKeyedUnarchiver unarchiveObjectWithFile:[self fileArchivePath]];
    if ([savedLines count]) {
        [view addLines:savedLines];
    }
    
    self.view = view;
}

- (void)saveLines
{
    TouchDrawView *view = (TouchDrawView *)self.view;
    [NSKeyedArchiver archiveRootObject:[view allCompletedLines] toFile:[self fileArchivePath]];
}

#pragma mark - Private

- (NSString *)fileArchivePath
{
    NSArray *directories = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentDirectory = directories[0];
    NSURL *fileArchiveURL = [documentDirectory URLByAppendingPathComponent:@"SavedPoints.file"];
    return [fileArchiveURL path];
}

@end
