//
//  BNRItemStore.m
//  Homepwner
//
//  Created by Richard Shin on 11/17/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "BNRItemStore.h"
#import "BNRImageStore.h"

@interface BNRItemStore ()
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *assetTypes;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSManagedObjectModel *model;
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
        [self setUpCoreData];
        [self loadAllItems];
    }
    return self;
}

- (void)setUpCoreData
{
    // Search main bundle for a CD model file, and create MOM from it
    self.model = [NSManagedObjectModel mergedModelFromBundles:nil];

    // Create PSC with MOM
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.model];
    
    // Get path to SQLite database file
    NSString *path = [self itemArchivePath];
    NSURL *storeURL = [NSURL fileURLWithPath:path];
    
    // Load PSC from SQLite database file, or create if it doens't exist
    NSError *error;
    if (![psc addPersistentStoreWithType:NSSQLiteStoreType
                      configuration:nil
                                URL:storeURL
                            options:nil
                              error:&error])
    {
        [NSException raise:@"Open failed"
                    format:@"Reason: %@", [error localizedDescription]];
    }
    
    // Create MOC, and set its PSC to the one we created
    self.context = [[NSManagedObjectContext alloc] init];
    self.context.persistentStoreCoordinator = psc;
    
    // We don't need an undo manager
    self.context.undoManager = nil;
    
}

// Fetch/load all items from SQLite database
- (void)loadAllItems
{
    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"BNRItem"];
    
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"orderingValue" ascending:YES];
    req.sortDescriptors = @[sd];
    
    NSError *error;
    NSArray *fetchResults = [self.context executeFetchRequest:req error:&error];
    if (!fetchResults) {
        [NSException raise:@"Fetch failed"
                    format:@"Reason: %@", [error localizedDescription]];
    }
    
    self.items = [[NSMutableArray alloc] initWithArray:fetchResults];
}

- (NSArray *)allItems
{
    return [self.items copy];
}

- (BNRItem *)createItem
{
    BNRItem *item = [NSEntityDescription insertNewObjectForEntityForName:@"BNRItem"
                                                  inManagedObjectContext:self.context];
    
    double order = [self.items count] ? [[self.items lastObject] orderingValue] + 1.0 : 1.0;
    item.orderingValue = order;

    [self.items addObject:item];
    return item;
}

- (void)deleteItem:(BNRItem *)item
{
    [self.context deleteObject:item];
    // Oops! Forgot to add this line in previous versions to delete cached image file
    [[BNRImageStore sharedStore] deleteImageForKey:item.imageKey];
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
    NSError *error;
    BOOL successful = [self.context save:&error];
    if (!successful) {
        NSLog(@"Error saving: %@", [error localizedDescription]);
    }
    return successful;
}

// Book has us declare this in header file, but why does anyone else other
// than this class need to know where we archive things?
- (NSString *)itemArchivePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *docDirectories = [fileManager URLsForDirectory:NSDocumentDirectory
                                                  inDomains:NSUserDomainMask];
    NSURL *url = [docDirectories objectAtIndex:0];

    return [[url URLByAppendingPathComponent:@"store.data"] path];
}

@end
