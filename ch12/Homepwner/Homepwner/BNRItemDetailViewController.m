//
//  BNRItemDetailViewController.m
//  Homepwner
//
//  Created by Richard Shin on 11/18/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "BNRItemDetailViewController.h"

@interface BNRItemDetailViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *nameField;
@property (nonatomic, weak) IBOutlet UITextField *serialNumberField;
@property (nonatomic, weak) IBOutlet UITextField *valueField;
@property (nonatomic, weak) IBOutlet UILabel *creationDateLabel;

@end

@implementation BNRItemDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    BNRItem *item = self.item;
    if (self.item) {
        self.nameField.text = item.itemName;
        self.serialNumberField.text = item.serialNumber;
        self.valueField.text = [NSString stringWithFormat:@"%d", item.valueInDollars];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterMediumStyle;
        self.creationDateLabel.text = [formatter stringFromDate:[NSDate date]];
        
        self.navigationItem.title = item.itemName;
    }
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    [self saveItem];
}

- (void)saveItem
{
    self.item.itemName = self.nameField.text;
    self.item.serialNumber = self.serialNumberField.text;
    self.item.valueInDollars = [self.valueField.text intValue];
}

// Ch. 11 Silver Challenge - find a way to dismiss the numeric keyboard.
// This is a method in UIResponder. Not 100% sure how all the UIResponder
// stuff works, but this will do for now.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

@end
