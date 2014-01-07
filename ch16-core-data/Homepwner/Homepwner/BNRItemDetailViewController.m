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

@interface BNRItemDetailViewController () <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate>

@property (nonatomic, weak) IBOutlet UITextField *nameField;
@property (nonatomic, weak) IBOutlet UITextField *serialNumberField;
@property (nonatomic, weak) IBOutlet UITextField *valueField;
@property (nonatomic, weak) IBOutlet UILabel *creationDateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIPopoverController *popoverVC;

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
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterMediumStyle;
        self.creationDateLabel.text = [formatter stringFromDate:[NSDate date]];
        
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
        if ([self.popoverVC isPopoverVisible]) {
            [self.popoverVC dismissPopoverAnimated:YES];
            self.popoverVC = nil;
            return;
        }
        self.popoverVC = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        [self.popoverVC setDelegate:self];
        [self.popoverVC presentPopoverFromBarButtonItem:sender
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
    
    if (self.popoverVC) {
        [self.popoverVC dismissPopoverAnimated:YES];
        self.popoverVC = nil;
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popoverVC = nil;
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

@end
