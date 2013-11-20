//
//  ImageScrollViewController.m
//  Homepwner
//
//  Created by Richard Shin on 11/19/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "ImageScrollViewController.h"

@interface ImageScrollViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@end

@implementation ImageScrollViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageView.image = self.image;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.scrollView.contentSize = self.imageView.image.size;
}

@end
