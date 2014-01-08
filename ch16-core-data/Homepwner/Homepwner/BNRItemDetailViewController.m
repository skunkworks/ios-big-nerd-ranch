//
//  BNRItemDetailViewController.m
//  :
//
//  Created by Richard Shin on 11/18/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "BNRItemDetailViewController.h"
#import "BNRImageStore.h"
#import "BNRItemStore.h"
#import "BNRAssetTypePickerController.h"

@interface BNRItemDetailViewController () <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate>

@property (nonatomic, weak) IBOutlet UITextField *nameField;
@property (nonatomic, weak) IBOutlet UITextField *serialNumberField;
@property (nonatomic, weak) IBOutlet UITextField *valueField;
@property (nonatomic, weak) IBOutlet UILabel *creationDateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *assetTypeButton;
@property (nonatomic, strong) UIPopoverController *popover;

@end

@implementation BNRItemDetailViewController

- (id)initForNewItem:(BOOL)isNew
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    self = [sb instantiateViewControllerWithIdentifier:@"BNRItemDetailViewController"];
    if (self) {
        if (isNew) {
            UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                  target:self
                                                                                  action:@selector(done:)];
            UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                    target:self
                                                                                    action:@selector(cancel:)];
            self.navigationItem.leftBarButtonItem = cancel;
            self.navigationItem.rightBarButtonItem = done;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    BNRItem *item = self.item;
    if (self.item) {
        self.nameField.text = item.itemName;
        self.serialNumberField.text = item.serialNumber;
        self.valueField.text = [NSString stringWithFormat:@"%d", item.valueInDollars];
        NSDate *dateCreated = [NSDate dateWithTimeIntervalSinceReferenceDate:item.dateCreated];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterMediumStyle;
        self.creationDateLabel.text = [formatter stringFromDate:dateCreated];
        
        if (self.item.imageKey) {
            UIImage *image = [[BNRImageStore sharedStore] imageForKey:self.item.imageKey];
            self.imageView.image = image;
        }
        
        self.navigationItem.title = item.itemName;
    }
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

// Modal VCs presented by form sheet will persist keyboard even when there's no first responder.
// This disables that. See http://stackoverflow.com/questions/3372333/ipad-keyboard-will-not-dismiss-if-modal-view-controller-presentation-style-is-ui
- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    [self saveItem];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self updateAssetTypeButtonLabel];
}

- (void)updateAssetTypeButtonLabel
{
    NSString *assetTypeLabel = [self.item.assetType valueForKey:@"label"];
    if (!assetTypeLabel) {
        assetTypeLabel = @"None";
    }
    
    NSString *title = [NSString stringWithFormat:@"Type: %@", assetTypeLabel];
    [self.assetTypeButton setTitle:title forState:UIControlStateNormal];
}

- (void)saveItem
{
    self.item.itemName = self.nameField.text;
    self.item.serialNumber = self.serialNumberField.text;
    self.item.valueInDollars = [self.valueField.text intValue];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (IBAction)takePicture:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    } else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    imagePicker.delegate = self;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self presentViewController:imagePicker animated:YES completion:nil];
    } else {
        if ([self.popover isPopoverVisible]) {
            [self.popover dismissPopoverAnimated:YES];
            self.popover = nil;
            return;
        }
        self.popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        [self.popover setDelegate:self];
        [self.popover presentPopoverFromBarButtonItem:sender
                               permittedArrowDirections:UIPopoverArrowDirectionAny
                                               animated:YES];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Did it have an old image? Delete it if so
    if (self.item.imageKey) {
        [[BNRImageStore sharedStore] deleteImageForKey:self.item.imageKey];
    }
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    CFUUIDRef newUniqueID = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef newUniqueIDString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueID);
    NSString *key = (__bridge NSString *)newUniqueIDString;

    self.item.imageKey = key;
    [self.item setThumbnailDataFromImage:image];
    [[BNRImageStore sharedStore] setImage:image forKey:self.item.imageKey];
    self.imageView.image = image;
    
    CFRelease(newUniqueID);
    CFRelease(newUniqueIDString);
    
    if (self.popover) {
        [self.popover dismissPopoverAnimated:YES];
        self.popover = nil;
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popover = nil;
}

- (void)done:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:self.dismissBlock];
}

- (void)cancel:(id)sender
{
    [[BNRItemStore sharedStore] deleteItem:self.item];
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:self.dismissBlock];
}

- (IBAction)showAssetTypePicker:(id)sender
{
    BNRAssetTypePickerController *picker = [[BNRAssetTypePickerController alloc] init];
    picker.item = self.item;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        picker.dismissBlock = ^{
            [self.popover dismissPopoverAnimated:YES];
            [self updateAssetTypeButtonLabel];
        };
        
        self.popover = [[UIPopoverController alloc] initWithContentViewController:picker];
    
        CGRect buttonRect = [self.view convertRect:[sender bounds] fromView:sender];
        [self.popover presentPopoverFromRect:buttonRect
                                      inView:self.view
                    permittedArrowDirections:UIPopoverArrowDirectionAny
                                    animated:YES];
    } else {
        picker.dismissBlock = ^{
            [self.navigationController popViewControllerAnimated:YES];
        };
        [self.navigationController pushViewController:picker animated:YES];
    }
}

@end
