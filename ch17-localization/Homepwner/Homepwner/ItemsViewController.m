//
//  ItemsViewController.m
//  Homepwner
//
//  Created by Richard Shin on 11/17/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "ItemsViewController.h"
#import "BNRItemStore.h"
#import "BNRImageStore.h"
#import "BNRItemDetailViewController.h"
#import "HomepwnerItemCell.h"
#import "ImageViewController.h"

@interface ItemsViewController ()

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
    // Setting the HomepwnerItemCell controller/tableView allows it to message the controller when
    // the user clicks a button on the table view cell. I don't like it because it's creating an
    // invisible contract between the view and the controller, but the book does it!
    cell.controller = self;
    cell.tableView = self.tableView;
    
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
    
    BNRItemDetailViewController *detailVC = [[BNRItemDetailViewController alloc] initForNewItem:YES];
    detailVC.item = item;
    [detailVC setDismissBlock:^{
        [self.tableView reloadData];
    }];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailVC];
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

- (void)showImage:(id)sender atIndexPath:(NSIndexPath *)indexPath
{
    NSArray *items = [[BNRItemStore sharedStore] allItems];
    BNRItem *item = items[indexPath.row];
    
    UIImage *image = [[BNRImageStore sharedStore] imageForKey:item.imageKey];
    if (!image) return;
    
    ImageViewController *vc = [[ImageViewController alloc] init];
    vc.image = image;

    CGRect buttonRect = [self.view convertRect:[sender bounds] fromView:sender];
    
    self.popover = [[UIPopoverController alloc] initWithContentViewController:vc];
    [self.popover setPopoverContentSize:CGSizeMake(600, 600)];
    [self.popover presentPopoverFromRect:buttonRect
                                  inView:self.view
                permittedArrowDirections:UIPopoverArrowDirectionAny
                                animated:YES];
}

@end
