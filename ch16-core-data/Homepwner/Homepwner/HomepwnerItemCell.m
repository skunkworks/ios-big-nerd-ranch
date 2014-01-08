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
    IMP imp = [self.controller methodForSelector:newSelector];
    void (*func)(id, SEL) = (void *)imp;
    func(self.controller, newSelector);
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:self];
    if (!indexPath) return;
    if ([self.controller respondsToSelector:newSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.controller performSelector:newSelector
                              withObject:sender
                              withObject:indexPath];
#pragma clang diagnostic pop
    }
}

@end
