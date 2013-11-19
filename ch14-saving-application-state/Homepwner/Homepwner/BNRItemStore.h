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
{
    NSMutableArray *items;
}

// Singleton interface
+ (BNRItemStore *)sharedStore;

- (NSArray *)allItems;
- (BNRItem *)createItem;
- (void)deleteItem:(BNRItem *)item;
- (void)moveItemAtIndex:(NSUInteger)sourceIndex
                toIndex:(NSUInteger)destinationIndex;

// Returns path to the item archive file in the Documents directory
- (NSString *)itemArchivePath;

// Saves items to the item archive file
- (BOOL)saveChanges;

@end
