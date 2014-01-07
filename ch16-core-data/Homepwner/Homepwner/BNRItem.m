//
//  BNRItem.m
//  Homepwner
//
//  Created by Richard Shin on 1/7/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "BNRItem.h"

@implementation BNRItem

@dynamic dateCreated;
@dynamic imageKey;
@dynamic itemName;
@dynamic orderingValue;
@dynamic serialNumber;
@dynamic thumbnail;
@dynamic thumbnailData;
@dynamic valueInDollars;
@dynamic assetType;

- (void)setThumbnailDataFromImage:(UIImage *)image
{
    CGSize origImageSize = [image size];
    // The new thumbnail's rectangle
    CGRect newRect = CGRectMake(0, 0, 40, 40);
    
    // Create a transparent bitmap context with a scaling factor equal to that of the screen
    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, 0.0);
    
    // Create a rounded rect drawing clip
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:newRect
                                                    cornerRadius:5.0];
    [path addClip];
    
    // REMEMBER THIS: the way to find the scaling ratio such that the original image is scaled to best fit.
    CGFloat scaleRatio = MAX(newRect.size.width/origImageSize.width, newRect.size.height/origImageSize.height);
    
    CGRect projectRect;
    projectRect.size.width = origImageSize.width*scaleRatio;
    projectRect.size.height = origImageSize.height*scaleRatio;
    projectRect.origin.x = (newRect.size.width-projectRect.size.width)/2.0;
    projectRect.origin.y = (newRect.size.height-projectRect.size.height)/2.0;
    
    // Draw the image to the projected rect
    [image drawInRect:projectRect];
    
    // Set the thumbnail and thumbnail data
    UIImage *thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
    NSData *thumbnailData = UIImagePNGRepresentation(thumbnailImage);
    [self setThumbnail:thumbnailImage];
    [self setThumbnailData:thumbnailData];
    
    // Don't forget to end the context! It cleans up resources
    UIGraphicsEndImageContext();
}

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    
    UIImage *thumbnail = [UIImage imageWithData:self.thumbnailData];
    // Book has us do this. What's wrong with just setting the property outright?
    // Apple docs say, "You should typically use this method only to modify attributes (usually transient), not relationships."
    // After some research, I think it's to prevent KVO notifications from going out that the item has changed.
    [self setPrimitiveValue:thumbnail forKey:@"thumbnail"];
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    NSTimeInterval ti = [NSDate timeIntervalSinceReferenceDate];
    self.dateCreated = ti;
}

@end
