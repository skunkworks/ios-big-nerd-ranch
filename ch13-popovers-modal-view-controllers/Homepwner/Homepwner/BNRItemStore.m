//
//  BNRItemStore.m
//  Homepwner
//
//  Created by Richard Shin on 11/17/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "BNRItemStore.h"

@implementation BNRItemStore

+ (BNRItemStore *)sharedStore
{
    static BNRItemStore *sharedStore;
    
    // Deviates from the book solution because using the GCD dispatch_once
    // looks so much cleaner and doesn't require overriding allocWithZone:
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] init];
    });
    return sharedStore;
}

- (id)init
{
    if (self = [super init]) {
        items = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSArray *)allItems
{
    return [items copy];
}

- (BNRItem *)createItem
{
    BNRItem *item = [BNRItem randomItem];
    [items addObject:item];
    return item;
}

- (void)deleteItem:(BNRItem *)item
{
    [items removeObjectIdenticalTo:item];
}

- (void)moveItemAtIndex:(NSUInteger)sourceIndex
                toIndex:(NSUInteger)destinationIndex
{
    BNRItem *item = items[sourceIndex];
    [items removeObjectAtIndex:sourceIndex];
    [items insertObject:item atIndex:destinationIndex];
}

@end
