//
//  ItemsViewController.m
//  Homepwner
//
//  Created by Richard Shin on 11/17/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "ItemsViewController.h"
#import "BNRItemStore.h"

@implementation ItemsViewController

// In Ch. 9, we set up the UITableViewController by hand:
// 1. Instantiated it in the app delegate
// 2. Set it as the root view controller manually
//
// Because ItemsViewController is a subclass of UITableViewController,
// it automatically gains access to the table view and does not need
// to specify that it is a UITableViewDelegate and UITableViewDataSource,
// nor does it need to set itself as the data source and delegate of the
// table view.
//
// In addition, because we created ItemsViewController by calling alloc init
// in the app delegate, all our setup code was in the init method(s). Now,
// to better adhere to common practices, I'm moving everything to using
// storyboards. Since the storyboard takes care of instantiating the view
// controller, any setup code must be done in viewDidLoad.
- (void)viewDidLoad
{
    [super viewDidLoad];
//    for (int i = 0; i < 5; i++) {
//        [[BNRItemStore sharedStore] createItem];
//    }
}

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BNRItemCell"];
    // Now that we use storyboards, setting up a prototype table view cell
    // makes it unnecessary to explicitly alloc/init a new one for ourselves.
    // Dequeue reusable cell will always provide us with one when we need it.
    
    NSArray *items = [[BNRItemStore sharedStore] allItems];
    if ([items count] != indexPath.row) {
        BNRItem *item = items[indexPath.row];
        cell.textLabel.text = [item description];
    } else {
        cell.textLabel.text = @"No more items!";
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [[[BNRItemStore sharedStore] allItems] count] + 1;
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

// Ch. 10 Silver Challenge - preventing reordering
//
// Prevent last row ("No more items!") from showing the reordering control
- (BOOL)tableView:(UITableView *)tableView
canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger itemCount = [[[BNRItemStore sharedStore] allItems] count];
    if (itemCount == indexPath.row) return NO;
    return YES;
}

// Prevent last row ("No more items!") from showing the delete button
- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self tableView:tableView canMoveRowAtIndexPath:indexPath];
}

// Ch. 10 Gold Challenge - really preventing reordering
//
// Prevent last row from being displaced by another row during reordering
- (NSIndexPath *)tableView:(UITableView *)tableView
targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath
       toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    NSUInteger itemCount = [[[BNRItemStore sharedStore] allItems] count];
    if (proposedDestinationIndexPath.row == itemCount) {
        return [NSIndexPath indexPathForRow:itemCount-1
                                  inSection:0];
    }
    return proposedDestinationIndexPath;
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

// Ch. 10 Bronze Challenge - rename the delete button to "Remove"
- (NSString *)tableView:(UITableView *)tableView
titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Remove";
}

- (IBAction)toggleEditingMode:(UIButton *)sender
{
    if ([[self tableView] isEditing]) {
        [self.tableView setEditing:NO animated:YES];
        [sender setTitle:@"Edit" forState:UIControlStateNormal];
    } else {
        [self.tableView setEditing:YES animated:YES];
        [sender setTitle:@"Done" forState:UIControlStateNormal];
    }
}

- (IBAction)addNewItem:(UIButton *)sender
{
    // Two ways to add item and row to table view:
    // 1. Leverage our knowledge that BNRItemStore adds new items to
    //    the end of its array of items
    // 2. Assume nothing and find this item manually
    //
    // The book does #2, so I'll follow suit. Upon reflection, it's
    // better not to assume, since it'd be an implicit interface
    // contract between this VC and the BNRItemStore class
    BNRItem *item = [[BNRItemStore sharedStore] createItem];
    NSArray *items = [[BNRItemStore sharedStore] allItems];
    NSUInteger idx = [items indexOfObjectIdenticalTo:item];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx
                                                inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:YES];
}
@end
