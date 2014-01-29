//
//  Line.m
//  TouchTracker
//
//  Created by Richard Shin on 1/28/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "Line.h"

@implementation Line

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _begin = [aDecoder decodeCGPointForKey:@"Begin"];
        _end = [aDecoder decodeCGPointForKey:@"End"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeCGPoint:self.begin forKey:@"Begin"];
    [aCoder encodeCGPoint:self.end forKey:@"End"];
}

@end
