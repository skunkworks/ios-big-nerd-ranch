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
- (IBAction)addNewItem:(id)sender
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
    UITableViewCell *cell = (UITableViewCell *)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if ([segue.identifier isEqualToString:@"Show detail view of BNRItem"]) {
        BNRItemDetailViewController *vc = (BNRItemDetailViewController *)segue.destinationViewController;
        if ([vc respondsToSelector:@selector(setItem:)]) {
            NSArray *items = [[BNRItemStore sharedStore] allItems];
            BNRItem *item = items[indexPath.row];
            [vc performSelector:@selector(setItem:) withObject:item];
        }
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

@end
