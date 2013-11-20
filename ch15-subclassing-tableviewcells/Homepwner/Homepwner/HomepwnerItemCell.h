//
//  HomepwnerItemCell.h
//  Homepwner
//
//  Created by Richard Shin on 11/19/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomepwnerItemCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *thumbnailView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *serialLabel;
@property (nonatomic, weak) IBOutlet UILabel *valueLabel;

@property (nonatomic, weak) id controller;

@end
