//
//  HomepwnerItemCell.m
//  Homepwner
//
//  Created by Richard Shin on 11/19/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "HomepwnerItemCell.h"

@implementation HomepwnerItemCell

- (IBAction)showImage:(id)sender
{
    SEL selector = NSSelectorFromString(@"showImageForCell:");
    if ([self.controller respondsToSelector:selector]) {
        [self.controller performSelector:selector
                              withObject:self];
    }
}

@end
