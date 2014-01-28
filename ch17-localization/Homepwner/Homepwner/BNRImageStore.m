//
//  BNRImageStore.m
//  Homepwner
//
//  Created by Richard Shin on 12/13/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "BNRImageStore.h"

@interface BNRImageStore ()
@property (nonatomic, strong) NSMutableDictionary *dict;
@end

@implementation BNRImageStore

- (NSMutableDictionary *)dict {
    if (!_dict) _dict = [NSMutableDictionary dictionary];
    return _dict;
}

// Alternate method of singleton creation
+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedStore];
}

+ (BNRImageStore *)sharedStore
{
    static BNRImageStore *sharedStore;
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:NULL] init];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(clearCache:)
                   name:UIApplicationDidReceiveMemoryWarningNotification
                 object:nil];
    }
    return sharedStore;
}

- (UIImage *)imageForKey:(NSString *)key
{
    UIImage *image = [self.dict objectForKey:key];

    if (!image) {
        // Cache miss: try to load from file cache
        NSString *path = [self imagePathForKey:key];
        image = [UIImage imageWithContentsOfFile:path];
        
        if (image) {
            // File cache hit: load into memory cache
            [self.dict setObject:image forKey:key];
        } else {
            // File cache miss: asked for an image that we just don't have!
            NSLog(@"Error: unable to find %@", path);
        }
    }
    return image;
}

- (void)setImage:(UIImage *)image forKey:(NSString *)key
{
    [self.dict setObject:image forKey:key];
    
    // Save image to file system
    NSString *path = [self imagePathForKey:key];
    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    // Writing atomically prevents data corruption if app crashes during write
    [data writeToFile:path atomically:YES];
}

- (void)deleteImageForKey:(NSString *)key
{
    // Guard against nil keys, which throws exception
    if (!key) return;
    [self.dict removeObjectForKey:key];
    
    NSString *path = [self imagePathForKey:key];
    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

- (NSString *)imagePathForKey:(NSString *)key
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *docDirectories = [fileManager URLsForDirectory:NSDocumentDirectory
                                                  inDomains:NSUserDomainMask];
    NSURL *url = [docDirectories objectAtIndex:0];
    
    return [[url URLByAppendingPathComponent:key] path];
}

- (void)clearCache:(NSNotification *)notification
{
    NSLog(@"Low memory warning received - clearing %d images from cache", [self.dict count]);
    [self.dict removeAllObjects];
}

@end
