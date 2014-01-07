//
//  BNRItem.m
//  RandomPossessions
//
//  Created by joeconway on 7/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BNRItem.h"

@implementation BNRItem
@synthesize container;
@synthesize containedItem;
@synthesize itemName, serialNumber, dateCreated, valueInDollars;

+ (id)randomItem
{
    // Create an array of three adjectives
    NSArray *randomAdjectiveList = [NSArray arrayWithObjects:@"Fluffy",
                                    @"Rusty",
                                    @"Shiny", nil];
    // Create an array of three nouns
    NSArray *randomNounList = [NSArray arrayWithObjects:@"Bear",
                               @"Spork",
                               @"Mac", nil];
    // Get the index of a random adjective/noun from the lists
    // Note: The % operator, called the modulo operator, gives
    // you the remainder. So adjectiveIndex is a random number
    // from 0 to 2 inclusive.
    NSInteger adjectiveIndex = rand() % [randomAdjectiveList count];
    NSInteger nounIndex = rand() % [randomNounList count];
    
    // Note that NSInteger is not an object, but a type definition
    // for "unsigned long"
    
    NSString *randomName = [NSString stringWithFormat:@"%@ %@",
                            [randomAdjectiveList objectAtIndex:adjectiveIndex],
                            [randomNounList objectAtIndex:nounIndex]];
    int randomValue = rand() % 100;
    NSString *randomSerialNumber = [NSString stringWithFormat:@"%c%c%c%c%c",
                                    '0' + rand() % 10,
                                    'A' + rand() % 26,
                                    '0' + rand() % 10,
                                    'A' + rand() % 26,
                                    '0' + rand() % 10];
    // Once again, ignore the memory problems with this method
    BNRItem *newItem =
    [[self alloc] initWithItemName:randomName
                    valueInDollars:randomValue
                      serialNumber:randomSerialNumber];
    return newItem;
}

- (id)initWithItemName:(NSString *)name
        valueInDollars:(int)value
          serialNumber:(NSString *)sNumber
{
    // Call the superclass's designated initializer
    self = [super init];
    
    // Did the superclass's designated initializer succeed?
    if(self) {
        // Give the instance variables initial values
        [self setItemName:name];
        [self setSerialNumber:sNumber];
        [self setValueInDollars:value];
        dateCreated = [[NSDate alloc] init];
    }
    
    // Return the address of the newly initialized object
    return self;
}

- (id)init 
{
    return [self initWithItemName:@"Possession"
                   valueInDollars:0
                     serialNumber:@""];
}


- (void)setContainedItem:(BNRItem *)i
{
    containedItem = i;
    [i setContainer:self];
}

- (NSString *)description
{
    NSString *descriptionString =
    [[NSString alloc] initWithFormat:@"%@ (%@): Worth $%d, recorded on %@",
     itemName,
     serialNumber,
     valueInDollars,
     dateCreated];
    return descriptionString;
}

- (void)dealloc
{
    NSLog(@"Destroyed: %@ ", self);
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:itemName forKey:@"itemName"];
    [aCoder encodeObject:serialNumber forKey:@"serialNumber"];
    [aCoder encodeInteger:valueInDollars forKey:@"valueInDollars"];
    [aCoder encodeObject:dateCreated forKey:@"dateCreated"];
    [aCoder encodeObject:self.imageKey forKey:@"imageKey"];
    [aCoder encodeObject:self.thumbnailData forKey:@"thumbnailData"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        itemName = [aDecoder decodeObjectForKey:@"itemName"];
        serialNumber = [aDecoder decodeObjectForKey:@"serialNumber"];
        valueInDollars = [aDecoder decodeIntegerForKey:@"valueInDollars"];
        dateCreated = [aDecoder decodeObjectForKey:@"dateCreated"];
        self.imageKey = [aDecoder decodeObjectForKey:@"imageKey"];
        self.thumbnailData = [aDecoder decodeObjectForKey:@"thumbnailData"];
    }
    return self;
}

- (UIImage *)thumbnail
{
    if (!_thumbnail && self.thumbnailData) {
        _thumbnail = [UIImage imageWithData:self.thumbnailData];
    }
    return _thumbnail;
}

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

@end
