//
//  BNRMapPoint
//  Whereami
//
//  Created by Richard Shin on 11/16/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "BNRMapPoint.h"

@interface BNRMapPoint ()
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, readwrite, copy) NSString *title;
@end

@implementation BNRMapPoint

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
               withTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        self.coordinate = coordinate;
        
        // Ch. 5 Gold Challenge
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateStyle = NSDateFormatterShortStyle;
        NSString *dateString = [df stringFromDate:[NSDate date]];
        self.title = [NSString stringWithFormat:@"%@ (%@)", title, dateString];
    }
    return self;
}

- (id)init
{
    self = [self initWithCoordinate:CLLocationCoordinate2DMake(0, 0)
                          withTitle:@""];
    return self;
}

@end
