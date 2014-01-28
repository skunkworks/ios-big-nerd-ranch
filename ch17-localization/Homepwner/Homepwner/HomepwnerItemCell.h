//
//  HomepwnerItemCell.h
//  Homepwner
//
//  Created by Richard Shin on 12/30/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomepwnerItemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *serialLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;

// Setting the HomepwnerItemCell controller/tableView allows it to message the controller when
// the user clicks a button on the table view cell. I don't like it because it's creating an
// invisible contract between the view and the controller, but the book does it!
@property (weak, nonatomic) id controller;
@property (weak, nonatomic) UITableView *tableView;

- (IBAction)showImage:(id)sender;
@end
