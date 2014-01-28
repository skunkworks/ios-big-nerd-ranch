//
//  ImageViewController.m
//  Homepwner
//
//  Created by Richard Shin on 12/30/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()

@end

@implementation ImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.image) [self setImage:self.image];
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    CGSize sz = image.size;
    [scrollView setContentSize:sz];
    [imageView setFrame:CGRectMake(0, 0, sz.width, sz.height)];
    [imageView setImage:image];
}

@end
