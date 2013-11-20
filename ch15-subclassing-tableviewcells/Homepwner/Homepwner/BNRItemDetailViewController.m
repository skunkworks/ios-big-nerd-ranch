//
//  BNRItemDetailViewController.m
//  Homepwner
//
//  Created by Richard Shin on 11/18/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "BNRItemDetailViewController.h"
#import "BNRImageStore.h"
#import "BNRItemStore.h"

@interface BNRItemDetailViewController () <UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate>

@property (nonatomic, weak) IBOutlet UITextField *nameField;
@property (nonatomic, weak) IBOutlet UITextField *serialNumberField;
@property (nonatomic, weak) IBOutlet UITextField *valueField;
@property (nonatomic, weak) IBOutlet UILabel *creationDateLabel;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIPopoverController *popover;
@end

@implementation BNRItemDetailViewController

#pragma mark - Properties

- (UIImagePickerController *)imagePicker {
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
        _imagePicker.allowsEditing = YES;
    }
    return _imagePicker;
}

#pragma mark - Lifecycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    BNRItem *item = self.item;
    
    // UI setup

    // Set up text fields
    self.nameField.text = item.itemName;
    self.serialNumberField.text = item.serialNumber;
    self.valueField.text = [NSString stringWithFormat:@"%d", item.valueInDollars];
    
    // Creation date label setup
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    self.creationDateLabel.text = [formatter stringFromDate:[NSDate date]];
    
    // Image view setup
    if (item.imageKey) {
        UIImage *image = [[BNRImageStore sharedStore] imageForKey:item.imageKey];
        self.imageView.image = image;
    }
    
    // Navigation bar - title setup
    self.navigationItem.title = item.itemName;
    
    // Navigation bar - button setup (if new)
    if (self.isNew) {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                         initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                         target:self
                                         action:@selector(cancel:)];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                       target:self
                                       action:@selector(save:)];
        self.navigationItem.leftBarButtonItem = cancelButton;
        self.navigationItem.rightBarButtonItem = doneButton;
    }

    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
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

#pragma mark - UIResponder method

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - Controller methods

// Called by UIBarButtonItem "Done"
- (void)save:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:self.dismissBlock];
}

// Called by UIBarButtonItem "Cancel"
- (void)cancel:(id)sender
{
    [[BNRItemStore sharedStore] deleteItem:self.item];
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:self.dismissBlock];
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
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        UIBarButtonItem *cameraBarButton = (UIBarButtonItem *)sender;
        
        if ([self.popover isPopoverVisible]) {
            [self.popover dismissPopoverAnimated:YES];
            self.popover = nil;
        } else {
            self.popover = [[UIPopoverController alloc]
                            initWithContentViewController:self.imagePicker];
            self.popover.delegate = self;
            [self.popover presentPopoverFromBarButtonItem:cameraBarButton
                                 permittedArrowDirections:UIPopoverArrowDirectionAny
                                                 animated:YES];
        }
    } else {
        [self presentViewController:self.imagePicker animated:true completion:nil];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popover = nil;
    self.imagePicker = nil;
}

- (IBAction)clearImage:(id)sender
{
    self.imageView.image = nil;
    if (self.item.imageKey) {
        [[BNRImageStore sharedStore] removeImageForKey:self.item.imageKey];
        self.item.imageKey = nil;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];

    // Core Foundation UUID as a byte array
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    // Create a CFStringRef from this UUID byte array
    CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuid);
    // Use UUID string as the image key
    NSString *key = (__bridge NSString *)uuidString;
    self.item.imageKey = key;
    
    // Store image in cache
    [[BNRImageStore sharedStore] setImage:image forKey:key];
    // Generate image thumbnail for item
    [self.item setThumbnailDataFromImage:image];
    
    CFRelease(uuid);
    CFRelease(uuidString);
    
    self.imageView.image = image;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.popover dismissPopoverAnimated:YES];
        self.popover = nil;
        self.imagePicker = nil;
    } else {
        [picker dismissViewControllerAnimated:YES completion:^
         {
             self.imagePicker = nil;
         }];
    }
}

@end
