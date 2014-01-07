//
//  BNRItemStore.m
//  Homepwner
//
//  Created by Richard Shin on 11/17/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "BNRItemStore.h"

@interface BNRItemStore ()
@property (nonatomic, strong) NSMutableArray *items;
@end

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
        _items = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (_items) {
            _items = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

- (NSArray *)allItems
{
    return [self.items copy];
}

- (BNRItem *)createItem
{
    BNRItem *item = [[BNRItem alloc] init];
    [self.items addObject:item];
    return item;
}

- (void)deleteItem:(BNRItem *)item
{
    [self.items removeObjectIdenticalTo:item];
}

- (void)moveItemAtIndex:(NSUInteger)sourceIndex
                toIndex:(NSUInteger)destinationIndex
{
    BNRItem *item = self.items[sourceIndex];
    [self.items removeObjectAtIndex:sourceIndex];
    [self.items insertObject:item atIndex:destinationIndex];
}

- (BOOL)saveItems
{
    NSString *path = [self itemArchivePath];
    return [NSKeyedArchiver archiveRootObject:self.items toFile:path];
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
