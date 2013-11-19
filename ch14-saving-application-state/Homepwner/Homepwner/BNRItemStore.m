//
//  BNRItemStore.m
//  Homepwner
//
//  Created by Richard Shin on 11/17/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "BNRItemStore.h"
#import "BNRImageStore.h"

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
        NSString *archivePath = [self itemArchivePath];
        
        items = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
        
        if (!items) items = [[NSMutableArray alloc] init];
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
    [[BNRImageStore sharedStore] removeImageForKey:item.imageKey];
    [items removeObjectIdenticalTo:item];
}

- (void)moveItemAtIndex:(NSUInteger)sourceIndex
                toIndex:(NSUInteger)destinationIndex
{
    BNRItem *item = items[sourceIndex];
    [items removeObjectAtIndex:sourceIndex];
    [items insertObject:item atIndex:destinationIndex];
}

// Overview of how object archiving works:
// 1. Set up model class to implement NSCoding protocol
// 2. NSCoding protocol consists of two methods: initWithCoder: and encodeWithCoder:. These
//    two methods will freeze-dry and rehydrate your object. Use the NSCoder object passed
//    in to encode and decode objects and other variables for given keys.
// 3. Decide upon a good location for your archive file. Documents directory is a good choice.
// 4. Implement a method that saves all model objects. This will use the NSKeyedArchiver class
//    method archiveRootObject:toFile:. Pass in the root object to save (e.g. array of all
//    models) and pass in a URI to the file.
// 5. Call the saveChanges method when the application is sent to the background.
- (NSString *)itemArchivePath
{
    NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                           inDomains:NSUserDomainMask];
    NSURL *documentsURL = [urls firstObject];
    NSURL *fileURL = [documentsURL URLByAppendingPathComponent:@"items.archive"];
    return [fileURL path];
}

- (BOOL)saveChanges
{
    NSString *archivePath = [self itemArchivePath];
    return [NSKeyedArchiver archiveRootObject:items
                                       toFile:archivePath];
}

@end
