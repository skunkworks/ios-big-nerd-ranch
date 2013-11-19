//
//  BNRItemDetailViewController.m
//  Homepwner
//
//  Created by Richard Shin on 11/18/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "BNRItemDetailViewController.h"
#import "BNRImageStore.h"

@interface BNRItemDetailViewController () <UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, weak) IBOutlet UITextField *nameField;
@property (nonatomic, weak) IBOutlet UITextField *serialNumberField;
@property (nonatomic, weak) IBOutlet UITextField *valueField;
@property (nonatomic, weak) IBOutlet UILabel *creationDateLabel;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIImagePickerController *imagePicker;

@end

@implementation BNRItemDetailViewController

#pragma mark - Properties

- (UIImagePickerController *)imagePicker {
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
        // Ch. 12 Bronze Challenge
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
    if (self.item) {
        // Set up text fields
        self.nameField.text = item.itemName;
        self.serialNumberField.text = item.serialNumber;
        self.valueField.text = [NSString stringWithFormat:@"%d", item.valueInDollars];
        
        // Creation date label setup
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterMediumStyle;
        self.creationDateLabel.text = [formatter stringFromDate:[NSDate date]];
        
        //
        // Something to consider deeply: the UIImageView image is set up when this
        // VC loads and right after a new picture is taken. The book uses the old
        // school trick of deallocating and reallocating on viewWillAppear and
        // viewWillDisappear, which was necessary back in iOS 5 when memory warnings
        // were liable to swoop in and jack your shit without warning (ironic). That
        // doesn't happen anymore, and the new best practice is to deallocate
        // expensive resources on didReceiveMemoryWarning.
        //
        // Image view setup
        if (item.imageKey) {
            UIImage *image = [[BNRImageStore sharedStore] imageForKey:item.imageKey];
            self.imageView.image = image;
        }
        
        // Navigation bar - title setup
        self.navigationItem.title = item.itemName;
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
    // Use camera if it exists; otherwise, fall back to photo library
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self presentViewController:self.imagePicker animated:true completion:nil];
}

// Ch. 12 Silver Challenge - Add a button to clear image
- (IBAction)clearImage:(id)sender
{
    self.imageView.image = nil;
    [[BNRImageStore sharedStore] removeImageForKey:self.item.imageKey];
    self.item.imageKey = nil;
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Ch. 12 Bronze Challenge
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
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
