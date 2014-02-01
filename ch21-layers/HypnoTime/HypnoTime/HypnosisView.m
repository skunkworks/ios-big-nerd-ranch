//
//  HypnosisView.m
//  Hypnosister
//
//  Created by Richard Shin on 11/17/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "HypnosisView.h"

@implementation HypnosisView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.circleColor = [UIColor lightGrayColor];
    }
    return self;
}

- (void)setCircleColor:(UIColor *)circleColor
{
    _circleColor = circleColor;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)dirtyRect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGRect bounds = self.bounds;
    
    // Get center of rect. Don't ever assume that a view's origin is (0, 0)!
    CGPoint center;
    center.x = (bounds.origin.x + bounds.size.width) / 2;
    center.y = (bounds.origin.y + bounds.size.height) / 2;
    
    // Calculate a radius of a circle that almost fills our view
    CGFloat maxRadius = hypot(bounds.size.width, bounds.size.height) / 2.0;
    
    // Set line thickness to 10px
    CGContextSetLineWidth(ctx, 10);
    
    // Set color of circle
    [self.circleColor setStroke];
    
    for (float currRadius = maxRadius; currRadius > 0; currRadius -= 20) {
        // Add shape to context
        CGContextAddArc(ctx, center.x, center.y, currRadius , 0, M_PI * 2, YES);
        
        // Perform a drawing instruction - draw current shape with current state
        CGContextStrokePath(ctx);
    }
    
    // Book uses deprecated methods to draw string, so I've updated it to
    // use an attributed string instead.
    NSAttributedString *text = [[NSAttributedString alloc] initWithString:@"You are getting sleepy" attributes: @{ NSFontAttributeName : [UIFont boldSystemFontOfSize:28] } ];
    
    CGRect textRect;
    textRect.size = [text size];
    textRect.origin.x = center.x - textRect.size.width / 2;
    textRect.origin.y = center.y - textRect.size.height / 2;
    
    CGSize shadowOffset = CGSizeMake(4, 3);
    CGColorRef shadowColor = [[UIColor darkGrayColor] CGColor];
    CGContextSetShadowWithColor(ctx, shadowOffset, 2.0, shadowColor);
    
    [[UIColor blackColor] setFill];
    [text drawInRect:textRect];
}

#pragma mark - UIResponder methods

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake) {
        NSLog(@"I'm getting shook up!");
        self.circleColor = [UIColor redColor];
    }
}

@end
