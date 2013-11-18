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

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        for (int i = 0; i < 5; i++) {
            [[BNRItemStore sharedStore] createItem];
        }
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // We could create new cells each time using
    // initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"]
    // but that's a waste of memory. Instead, use the dequeue method.
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BNRItemCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BNRItemCell"];
    }

    BNRItem *item = [[BNRItemStore sharedStore] allItems][indexPath.row];
    cell.textLabel.text = [item description];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [[[BNRItemStore sharedStore] allItems] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

@end
