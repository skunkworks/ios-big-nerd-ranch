//
//  Line.h
//  TouchTracker
//
//  Created by Richard Shin on 1/28/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Line : NSObject <NSCoding>

@property (nonatomic) CGPoint begin;
@property (nonatomic) CGPoint end;

@end
