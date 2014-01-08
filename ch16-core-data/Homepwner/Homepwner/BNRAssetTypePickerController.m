//
//  BNRAssetTypePickerController.m
//  Homepwner
//
//  Created by Richard Shin on 1/7/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "BNRAssetTypePickerController.h"

@implementation BNRAssetTypePickerController

- (id)init
{
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [[[BNRItemStore sharedStore] allAssetTypes] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"UITableViewCell"];
    }
    
    NSArray *assetTypes = [[BNRItemStore sharedStore] allAssetTypes];
    NSManagedObject *assetType = assetTypes[indexPath.row];
    NSString *assetLabel = [assetType valueForKey:@"label"];
    cell.textLabel.text = assetLabel;
    
    if ([self.item assetType] == assetType) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        // Need to reset it, in case reused cell previously had a checkmark
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    NSArray *assetTypes = [[BNRItemStore sharedStore] allAssetTypes];
    NSManagedObject *assetType = assetTypes[indexPath.row];
    self.item.assetType = assetType;
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
