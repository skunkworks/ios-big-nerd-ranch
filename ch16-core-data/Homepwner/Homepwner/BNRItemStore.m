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
        NSString *path = [self itemArchivePath];
        items = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (!items) {
            items = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

- (NSArray *)allItems
{
    return [items copy];
}

- (BNRItem *)createItem
{
    BNRItem *item = [[BNRItem alloc] init];
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

- (BOOL)saveItems
{
    NSString *path = [self itemArchivePath];
    return [NSKeyedArchiver archiveRootObject:items toFile:path];
}

// Book has us declare this in header file, but why does anyone else other
// than this class need to know where we archive things?
- (NSString *)itemArchivePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *docDirectories = [fileManager URLsForDirectory:NSDocumentDirectory
                                                  inDomains:NSUserDomainMask];
    NSURL *url = [docDirectories objectAtIndex:0];

    return [[url URLByAppendingPathComponent:@"items.archive"] path];
}

@end
