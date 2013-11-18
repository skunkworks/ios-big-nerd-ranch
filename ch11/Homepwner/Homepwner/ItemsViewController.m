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

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BNRItemCell"];
    
    NSArray *items = [[BNRItemStore sharedStore] allItems];
    BNRItem *item = items[indexPath.row];
    cell.textLabel.text = [item description];
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
