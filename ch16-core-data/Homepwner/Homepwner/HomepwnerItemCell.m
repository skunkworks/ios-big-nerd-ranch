//
//  HomepwnerItemCell.m
//  Homepwner
//
//  Created by Richard Shin on 12/30/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "HomepwnerItemCell.h"

@implementation HomepwnerItemCell

- (IBAction)showImage:(id)sender
{
    NSString *selector = NSStringFromSelector(_cmd);
    selector = [selector stringByAppendingString:@"atIndexPath:"];
    
    SEL newSelector = NSSelectorFromString(selector);
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:self];
    if (!indexPath) return;
    if ([self.controller respondsToSelector:newSelector]) {
        [self.controller performSelector:newSelector
                              withObject:sender
                              withObject:indexPath];
    }
}

@end
