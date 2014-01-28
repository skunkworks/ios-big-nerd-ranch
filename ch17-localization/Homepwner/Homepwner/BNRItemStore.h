//
//  BNRItemStore.h
//  Homepwner
//
//  Created by Richard Shin on 11/17/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BNRItem.h"

@interface BNRItemStore : NSObject

// Singleton interface
+ (BNRItemStore *)sharedStore;

- (NSArray *)allItems;
- (NSArray *)allAssetTypes;

- (BNRItem *)createItem;
- (void)deleteItem:(BNRItem *)item;
- (void)moveItemAtIndex:(NSUInteger)sourceIndex
                toIndex:(NSUInteger)destinationIndex;

// Archives all items to file
- (BOOL)saveItems;

@end
