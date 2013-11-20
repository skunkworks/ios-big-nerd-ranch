//
//  ItemsViewController.m
//  Homepwner
//
//  Created by Richard Shin on 11/17/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "ItemsViewController.h"
#import "BNRItemStore.h"
#import "BNRItemDetailViewController.h"
#import "HomepwnerItemCell.h"
#import "ImageScrollViewController.h"
#import "BNRImageStore.h"

@interface ItemsViewController () <UIPopoverControllerDelegate>
@property (nonatomic, strong) UIPopoverController *popover;
@end

@implementation ItemsViewController

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomepwnerItemCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"HomepwnerItemCell"];
    
    NSArray *items = [[BNRItemStore sharedStore] allItems];
    BNRItem *item = items[indexPath.row];
    
    cell.nameLabel.text = item.itemName;
    cell.serialLabel.text = item.serialNumber;
    cell.valueLabel.text = [NSString stringWithFormat:@"$%d", item.valueInDollars];
    cell.thumbnailView.image = item.thumbnail;

    // Used to receive messages from the cell
    cell.controller = self;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [[[BNRItemStore sharedStore] allItems] count];
}

// Just having the UITableView's delegate respond to this method will
// enable the swipe-to-delete gesture for rows.
- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *items = [[BNRItemStore sharedStore] allItems];
        BNRItem *item = [items objectAtIndex:indexPath.row];
        [[BNRItemStore sharedStore] deleteItem:item];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

// Just having the UITableView's delegate respond to this method will
// automatically create and enable the edit/move bars in the table view.
- (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
      toIndexPath:(NSIndexPath *)destinationIndexPath
{
    // Tell BNRItemStore to swap items from source to destination
    [[BNRItemStore sharedStore] moveItemAtIndex:sourceIndexPath.row
                                        toIndex:destinationIndexPath.row];
}

- (IBAction)addNewItem:(id)sender
{
    // Goal: present the BNRItemDetailViewControlller modally.
    BNRItem *item = [[BNRItemStore sharedStore] createItem];

    // Problem 1: how do we present it? Via segue? Using a modal presenter? Hard
    // to tell until we proceed to other problems...
    
    // Problem 2: instantiating the BNRItemDetailViewController programmatically
    // from the storyboard. Have to do it this clumsy way... typically we'd use
    // a segue, but for now I've chosen to arbitrarily follow the book example.
    // If I used a segue, I'd have to set it up to push to a navigation controller
    // because of Problem 4...
    NSString *storyboardName;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        storyboardName = @"Storyboard-iPad";
    } else {
        storyboardName = @"Storyboard";
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName
                                                         bundle:[NSBundle mainBundle]];
    BNRItemDetailViewController *vc = (BNRItemDetailViewController *)[storyboard
                                       instantiateViewControllerWithIdentifier:@"BNRItemDetailViewController"];
    
    vc.item = item;
    // Problem 3: how to tell the BNRItemDetailViewController to present the
    // interface for a new item and not an existing one?
    vc.isNew = YES;
    vc.dismissBlock = ^{
        [self.tableView reloadData];
    };
    
    // Problem 4: if we display the VC it with a segue, we lose the navigation
    // bar, which we will be using to show the "Done" and "Cancel" bar button
    // items. For this reason, we wrap it in a nav controller before presenting
    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:vc];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;

    [self presentViewController:navController animated:YES completion:nil];
}

// The book uses an older technique to push the detail VC onto the navigation
// VC stack: when the user taps a row (tableView:didSelectRowAtIndexPath:), it
// instantiates a new detail VC, sets its item property, and pushes it onto
// self.navigationController by using pushViewController:animated:.
//
// Because we're using storyboards, the detail VC instantiation is handled by
// automatically. In it, we hook up the UITableViewCell to perform a push segue
// with a particular name. Then, when the user selects the cell, it performs
// the segue and instantiates the VC for us. Before it pushes the VC onto the
// stack, it lets us pass data to the new VC by calling prepareForSegue:sender:.
- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show detail view of BNRItem"]) {
        UITableViewCell *cell = (UITableViewCell *)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        NSArray *items = [[BNRItemStore sharedStore] allItems];
        BNRItem *item = items[indexPath.row];
        
        BNRItemDetailViewController *vc = (BNRItemDetailViewController *)segue.destinationViewController;
        vc.item = item;
        vc.isNew = NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Note: we don't have to create a navigation item ourselves. In fact, it's
    // a readonly property. Just read it and modify it.
    self.navigationItem.title = @"Homepwner";

    // We set up the navigation bar button item for Edit in code UIViewController
    // offers a free one that does everything we need. The Add New (+) item is
    // in the storyboard...
    // I can't believe they provide this for free...
    self.navigationItem.leftBarButtonItem = [self editButtonItem];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)showImageForCell:(HomepwnerItemCell *)cell
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if ([self.popover isPopoverVisible]) {
            [self.popover dismissPopoverAnimated:YES];
            self.popover = nil;
            return;
        }
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        NSArray *items = [[BNRItemStore sharedStore] allItems];
        BNRItem *item = items[indexPath.row];
        UIImage *image = [[BNRImageStore sharedStore] imageForKey:item.imageKey];
        if (!image) return;
        
        ImageScrollViewController *imageScrollVC = [[ImageScrollViewController alloc] init];
        imageScrollVC.image = image;
        
        CGRect rect = [[self view] convertRect:cell.thumbnailView.frame
                                      fromView:cell];
        
        self.popover = [[UIPopoverController alloc] initWithContentViewController:imageScrollVC];
        self.popover.delegate = self;
        [self.popover setPopoverContentSize:CGSizeMake(600, 600)];
        [self.popover presentPopoverFromRect:rect
                                      inView:self.view
                    permittedArrowDirections:UIPopoverArrowDirectionAny
                                    animated:YES];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popover = nil;
}

@end
