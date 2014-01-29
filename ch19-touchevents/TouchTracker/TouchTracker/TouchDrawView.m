//
//  TouchDrawView.m
//  TouchTracker
//
//  Created by Richard Shin on 1/28/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "TouchDrawView.h"
#import "Line.h"

@interface TouchDrawView ()
// Dictionary of CGPoint?
@property (strong, nonatomic) NSMutableDictionary *linesInProgress;
// Array of Line
@property (strong, nonatomic) NSMutableArray *completeLines;
@end

@implementation TouchDrawView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _linesInProgress = [[NSMutableDictionary alloc] init];
        _completeLines = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor whiteColor];
        self.multipleTouchEnabled = YES;
    }
    return self;
}

#pragma mark - Public

- (void)clear
{
    [self.linesInProgress removeAllObjects];
    [self.completeLines removeAllObjects];
    
    [self setNeedsDisplay];
}

- (void)addLines:(NSArray *)lines
{
    [self.completeLines addObjectsFromArray:lines];
    [self setNeedsDisplay];
}

- (NSArray *)allCompletedLines
{
    return [self.completeLines copy];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        if (touch.tapCount > 1) {
            [self clear];
            return;
        }

        CGPoint point = [touch locationInView:self];
        Line *line = [[Line alloc] init];
        line.begin = point;
        line.end = point;
        
        NSValue *key = [NSValue valueWithNonretainedObject:touch];
        self.linesInProgress[key] = line;
    }
    
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:touch];
        Line *line = self.linesInProgress[key];
        line.end = [touch locationInView:self];
    }
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endTouches:touches];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endTouches:touches];
}

- (void)endTouches:(NSSet *)touches
{
    for (UITouch *touch in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:touch];
        Line *line = self.linesInProgress[key];
        
        if (line) {
            [self.completeLines addObject:line];
            [self.linesInProgress removeObjectForKey:key];
        }
    }
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 10.0);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    // Did not know that you can use -set to set the fill and stroke color!
    [[UIColor blackColor] set];
    for (Line *line in self.completeLines) {
        CGContextMoveToPoint(context, line.begin.x, line.begin.y);
        CGContextAddLineToPoint(context, line.end.x, line.end.y);
        CGContextStrokePath(context);
    }
    
    [[UIColor redColor] set];
    // NSValue is the object type of a key/value pair!
    for (NSValue *v in self.linesInProgress) {
        Line *line = [self.linesInProgress objectForKey:v];
        CGContextMoveToPoint(context, line.begin.x, line.begin.y);
        CGContextAddLineToPoint(context, line.end.x, line.end.y);
        CGContextStrokePath(context);
    }
}

@end
