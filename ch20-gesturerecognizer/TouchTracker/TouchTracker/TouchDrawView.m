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
@property (weak, nonatomic) Line *selectedLine;
@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic) CGPoint velocity;
@end

@implementation TouchDrawView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _linesInProgress = [[NSMutableDictionary alloc] init];
        _completeLines = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor whiteColor];
        self.multipleTouchEnabled = YES;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [self addGestureRecognizer:tapGesture];
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
        doubleTapGesture.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTapGesture];
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [self addGestureRecognizer:lpgr];
        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveLine:)];
        self.panGestureRecognizer.delegate = self;
        // If we don't set cancelsTouchesInView for the pan gesture recognizer, it intercepts the
        // touch event when finger starts to move on the screen, which halts line drawing.
        self.panGestureRecognizer.cancelsTouchesInView = NO;
        [self addGestureRecognizer:self.panGestureRecognizer];
    }
    return self;
}

#pragma mark - IBAction

- (void)tapped:(UITapGestureRecognizer *)gestureRecognizer
{
    [self selectNearestLineToPoint:[gestureRecognizer locationInView:self]];

    UIMenuController *menu = [UIMenuController sharedMenuController];
    if (self.selectedLine) {
        // To show a menu controller, you must become first responder
        [self becomeFirstResponder];
        
        UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteLine:)];
        menu.menuItems = @[deleteItem];
        
        CGPoint tapPoint = [gestureRecognizer locationInView:self];
        CGRect lineRect = CGRectMake(tapPoint.x, tapPoint.y, 0, 0);
        [menu setTargetRect:lineRect inView:self];
        [menu setMenuVisible:YES animated:NO];
    } else {
        [menu setMenuVisible:NO animated:NO];
    }
    
    [self setNeedsDisplay];
}

- (void)doubleTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    [self clear];
}

- (void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self selectNearestLineToPoint:[gestureRecognizer locationInView:self]];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        self.selectedLine = nil;
    }
    
    [self setNeedsDisplay];
}

- (void)moveLine:(UIPanGestureRecognizer *)gestureRecognizer
{
    // Record current velocity for use in drawing lines
    self.velocity = [gestureRecognizer velocityInView:self];
    
    if (!self.selectedLine) return;
    
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:self];
        CGPoint begin = self.selectedLine.begin;
        CGPoint end = self.selectedLine.end;
        
        begin.x += translation.x;
        begin.y += translation.y;
        end.x += translation.x;
        end.y += translation.y;
        
        self.selectedLine.begin = begin;
        self.selectedLine.end = end;
        
        // Need to reset the translation unless you reason want to keep track of the cumulative distance covered
        [gestureRecognizer setTranslation:CGPointZero inView:self];
        
        [self setNeedsDisplay];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // If a line is selected while a line is being drawn, the pan gesture recognizer will start moving
    // the line. Unselecting the line prevents this behavior.
    self.selectedLine = nil;
    [[UIMenuController sharedMenuController] setMenuVisible:NO];
    
    for (UITouch *touch in touches) {
        CGPoint point = [touch locationInView:self];
        Line *line = [[Line alloc] init];
        line.begin = point;
        line.end = point;
        line.width = 10.0;
        
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

- (void)deleteLine:(id)sender
{
    [self.completeLines removeObject:self.selectedLine];
    
    [self setNeedsDisplay];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == self.panGestureRecognizer) {
        return YES;
    }
    return NO;
}

#pragma mark - Private

- (Line *)lineNearPoint:(CGPoint)point
{
    // Find a line close to p
    for (Line *line in self.completeLines) {
        CGPoint start = line.begin;
        CGPoint end = line.end;
        
        // Check a few points on the line
        for (float t = 0.0; t <= 1.0; t += 0.05) {
            float x = start.x + t * (end.x - start.x);
            float y = start.y + t * (end.y - start.y);
            
            // If the tapped point is within 20 points, let's return this line
            if (hypot(x - point.x, y - point.y) < 20.0) {
                return line;
            }
        }
    }
    return nil;
}

- (void)selectNearestLineToPoint:(CGPoint)point
{
    [self.linesInProgress removeAllObjects];
    Line *line = [self lineNearPoint:point];
    self.selectedLine = line;
}

- (CGFloat)lineWidthForVelocity:(CGPoint)velocity
{
    // Fast = thin line, slow = thick line. Range is anywhere from 1.0-10.0.

    // A quick swipe in one direction should be the same velocity as a quick swipe in a diagonal direction, so determine
    // speed as the max velocity of both axes.
    CGFloat maxVelocity = MAX(abs(velocity.x), abs(velocity.y));
    CGFloat lineWidth = 10.0 - ((maxVelocity / 2000.0) * 9.0);
    lineWidth = MAX(lineWidth, 1.0);
    return lineWidth;
}

- (void)updateLineWidth:(Line *)line
{
    // We want to update the line width to reflect the velocity of the user touch input, but having it instantly update
    // based on the last velocity measurement makes it feel unnatural because the line width modulates too drastically.
    // I've chosen a simplistic workaround, which is to have the maximum velocity recorded during the line drawing
    // determine the width of the line. It sucks, and the proper algo would be to smooth out this reading over multiple
    // samples and take the avg delta, but for now it's ok.
    CGFloat lineWidth = [self lineWidthForVelocity:self.velocity];
    if (lineWidth < line.width) line.width = lineWidth;
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

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapRound);
    
    for (Line *line in self.completeLines) {
        CGContextSetLineWidth(context, line.width);
        CGContextMoveToPoint(context, line.begin.x, line.begin.y);
        CGContextAddLineToPoint(context, line.end.x, line.end.y);
        if (line == self.selectedLine) {
            // Did not know that you can use -set to set the fill and stroke color!
            [[UIColor greenColor] set];
        } else {
            [[UIColor blackColor] set];
        }
        CGContextStrokePath(context);
    }
    
    [[UIColor redColor] set];
    
    // NSValue is the object type of a key/value pair!
    for (NSValue *v in self.linesInProgress) {
        Line *line = [self.linesInProgress objectForKey:v];
        [self updateLineWidth:line];
        CGContextSetLineWidth(context, line.width);
        CGContextMoveToPoint(context, line.begin.x, line.begin.y);
        CGContextAddLineToPoint(context, line.end.x, line.end.y);
        CGContextStrokePath(context);
    }
}

@end
