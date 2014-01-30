//
//  TouchDrawView.h
//  TouchTracker
//
//  Created by Richard Shin on 1/28/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TouchDrawView : UIView <UIGestureRecognizerDelegate>

/**
 Clear all lines from the view
 */
- (void)clear;

/**
 Add lines to the view
 */
- (void)addLines:(NSArray *)lines;

/**
 Get all completed drawn lines
 */
- (NSArray *)allCompletedLines;

@end
