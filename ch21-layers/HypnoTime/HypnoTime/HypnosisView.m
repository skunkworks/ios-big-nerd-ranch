//
//  HypnosisView.m
//  Hypnosister
//
//  Created by Richard Shin on 11/17/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "HypnosisView.h"
#import <QuartzCore/QuartzCore.h>

@interface HypnosisView ()
@property (nonatomic) CALayer *boxLayer;
@property (nonatomic) CALayer *subBoxLayer;
@end

@implementation HypnosisView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.circleColor = [UIColor lightGrayColor];
        self.boxLayer = [[CALayer alloc] init];
        self.boxLayer.bounds = CGRectMake(0, 0, 85.0, 85.0);
        self.boxLayer.position = CGPointMake(160.0, 100.0);
        self.boxLayer.cornerRadius = 5.0;
        self.boxLayer.backgroundColor = [[UIColor colorWithRed:1.0 green:0 blue:0 alpha:0.5] CGColor];
        UIImage *hypnoImage = [UIImage imageNamed:@"hypno.png"];
        self.boxLayer.contents = (__bridge id)([hypnoImage CGImage]);
        self.boxLayer.contentsRect = CGRectMake(-0.1, -0.1, 1.2, 1.2);
        [self.layer addSublayer:self.boxLayer];
        self.subBoxLayer = [[CALayer alloc] init];
        self.subBoxLayer.bounds = CGRectMake(0, 0, CGRectGetWidth(self.boxLayer.bounds) / 2.0, CGRectGetHeight(self.boxLayer.bounds) / 2.0);
        self.subBoxLayer.position = CGPointMake(CGRectGetWidth(self.boxLayer.bounds) / 2.0, CGRectGetHeight(self.boxLayer.bounds) / 2.0);
        UIImage *timeImage = [UIImage imageNamed:@"time.png"];
        self.subBoxLayer.contents = (__bridge id)[timeImage CGImage];
        [self.boxLayer addSublayer:self.subBoxLayer];
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint tapPoint = [touch locationInView:self];
    self.boxLayer.position = tapPoint;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint tapPoint = [touch locationInView:self];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.boxLayer.position = tapPoint;
    [CATransaction commit];
}

@end
