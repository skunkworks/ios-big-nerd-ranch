//
//  BNRItemDetailViewController.m
//  Homepwner
//
//  Created by Richard Shin on 11/18/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "BNRItemDetailViewController.h"

@interface BNRItemDetailViewController ()
@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) IBOutlet UITextField *serialTextField;
@property (nonatomic, weak) IBOutlet UITextField *valueTextField;
@property (nonatomic, weak) IBOutlet UILabel *creationDateLabel;
@end

@implementation BNRItemDetailViewController

- (void)viewDidLoad
{
    BNRItem *item = self.item;
    if (self.item) {
        self.nameTextField.text = item.itemName;
        self.serialTextField.text = item.serialNumber;
        self.valueTextField.text = [NSString stringWithFormat:@"%d", item.valueInDollars];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterMediumStyle;
        self.creationDateLabel.text = [formatter stringFromDate:[NSDate date]];
    }
}
@end
