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
        
        // Present the image picker in a popover. If the user taps the camera button while the
        // popover is still visible, dismiss the popover.
        if ([self.popover isPopoverVisible]) {
            [self.popover dismissPopoverAnimated:YES];
            self.popover = nil;
        } else {
            // Present the image picker VC in a popover
            self.popover = [[UIPopoverController alloc]
                            initWithContentViewController:self.imagePicker];
            self.popover.delegate = self;
            [self.popover presentPopoverFromBarButtonItem:cameraBarButton
                                 permittedArrowDirections:UIPopoverArrowDirectionAny
                                                 animated:YES];
        }
    } else {
        // Present the image picker VC modally
        [self presentViewController:self.imagePicker animated:true completion:nil];
    }
}

// Note on using popover: general approach should be to nil out the popover controller
// when you're not using it. Makes sense -- no need to keep it around and reuse it, it's
// just a waste of memory.
//
// Also, based on behavior I saw with the UIImagePickerController in ColorMyWorld, I had
// weird problems with displaying the camera UI full-screen modally if I didn't nil out
// the VC between each popover display. Because of that, I've made sure to nil out the
// VC when it's not in use.
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popover = nil;
    self.imagePicker = nil;
    NSLog(@"User dismissed popover");
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
    // Note: __bridge creates a "toll-free bridge" that allows us to convert from
    // a CFString to an NSString with a simple cast. This is because the two types
    // are represented the same in memory. We could just do a straight NSString *
    // cast, but ARC has some difficulty managing Core Foundation pointers. The
    // __bridge keyword tells ARC to not give ownership of the object to the new
    // pointer.
    
    self.item.imageKey = key;
    
    // Store image in cache
    [[BNRImageStore sharedStore] setImage:image forKey:key];
    
    // Rules for handling Core Foundation pointers:
    // 1. A pointer only owns the object it points to if the method that created
    //    the object contained the word Create or Copy.
    // 2. If a pointer owns a Core Foundation object, you must call CFRelease on
    //    the pointer before you lose that object. An object can be lost if the
    //    pointer points at a new object, or points at nil/NULL, or if the pointer
    //    itself is destroyed.
    // 3. Once you call CFRelease on a pointer, you can't use that pointer again.
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
