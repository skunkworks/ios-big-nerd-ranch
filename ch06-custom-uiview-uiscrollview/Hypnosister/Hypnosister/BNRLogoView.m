//
//  BNRLogoView.m
//  Hypnosister
//
//  Created by Richard Shin on 11/17/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "BNRLogoView.h"

@implementation BNRLogoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        logoImage = [UIImage imageNamed:@"bnr-logo.png"];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    // Set up the circle path
    CGPoint center;
    center.x = (self.bounds.origin.x + self.bounds.size.width) / 2;
    center.y = (self.bounds.origin.y + self.bounds.size.height) / 2;
    CGFloat radius = hypotf(self.bounds.size.width, self.bounds.size.height)/3;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, NULL, center.x, center.y, radius, 0, M_PI*2, YES);
    
    // Set up stroke color and line width
    [[UIColor blackColor] setStroke];
    CGContextSetLineWidth(ctx, 1);
    
    // Creating gradient
    CGGradientRef gradient;
    CGColorSpaceRef colorspace;
    CGFloat colors [] = {
        0.0, 0.0, 1.0, 0.3,
        1.0, 1.0, 1.0, 0.3
    };
    colorspace = CGColorSpaceCreateDeviceRGB();
    gradient = CGGradientCreateWithColorComponents(colorspace, colors, NULL, 2);
    CGColorSpaceRelease(colorspace);
    
    // Set up the shadow
    CGSize shadowOffset = CGSizeMake(3, 3);
    CGColorRef shadowColor = [[UIColor darkGrayColor] CGColor];
    CGContextSetShadowWithColor(ctx, shadowOffset, 2.0, shadowColor);
    
    // Draw outline and shadow
    CGContextAddPath(ctx, path);
    CGContextDrawPath(ctx, kCGPathFillStroke);
    
    // Clip to circle path before drawing UIImage logo
    CGContextSaveGState(ctx);
    CGContextAddPath(ctx, path);
    CGContextClip(ctx);
    [logoImage drawInRect:rect];
    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0, 0), CGPointMake(rect.size.width, rect.size.height), kCGGradientDrawsBeforeStartLocation);
    CGContextRestoreGState(ctx);
}

@end
