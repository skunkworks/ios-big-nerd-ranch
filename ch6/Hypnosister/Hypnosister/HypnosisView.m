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
    
//    Ch. 5 Bronze Challenge - set circle color to change
//    NSArray *circleColors = @[[UIColor lightGrayColor],
//                              [UIColor blackColor],
//                              [UIColor redColor],
//                              [UIColor yellowColor],
//                              [UIColor redColor],
//                              [UIColor orangeColor]];
//    self.circleColor = [circleColors objectAtIndex:arc4random()%([circleColors count]+1)];
    
    // Set color of circle
    [self.circleColor setStroke];
    
    for (float currRadius = maxRadius; currRadius > 0; currRadius -= 20) {
//    Ch. 5 Bronze Challenge - set circle color to change
//        self.circleColor = [circleColors objectAtIndex:arc4random()%[circleColors count]];
//        [self.circleColor setStroke];
        
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
    
    //
    // Ch. 5 Silver Challenge - add green crosshair to middle of view
    // Note: book says to use CGContextSaveGState and CGContextRestoreGState,
    // but that's only necessary if we had to switch back to a drawing context
    // that was previously defined.
    //
    // Set crosshair to be 2px wide and green
//    CGContextSetLineWidth(ctx, 2);
//    [[UIColor greenColor] setStroke];
//    // Draw horizontal line 20px wide
//    CGContextMoveToPoint(ctx, center.x-10, center.y);
//    CGContextAddLineToPoint(ctx, center.x+10, center.y);
//    // Draw vertical line 20px high
//    CGContextMoveToPoint(ctx, center.x, center.y-10);
//    CGContextAddLineToPoint(ctx, center.x, center.y+10);
//    CGContextStrokePath(ctx);
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
