//
//  BNRImageStore.m
//  Homepwner
//
//  Created by Richard Shin on 11/18/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "BNRImageStore.h"

@interface BNRImageStore ()

@property (nonatomic, strong) NSMutableDictionary *dict;

@end

@implementation BNRImageStore

- (NSMutableDictionary *)dict
{
    if (!_dict) _dict = [[NSMutableDictionary alloc] init];
    return _dict;
}

+ (BNRImageStore *)sharedStore
{
    static BNRImageStore *sharedStore;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[BNRImageStore alloc] init];
        
        // Set up image store to listen for low memory notifications
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(clearCache)
                   name:UIApplicationDidReceiveMemoryWarningNotification
                 object:nil];
    });
    
    return sharedStore;
}

- (UIImage *)imageForKey:(NSString *)key
{
    UIImage *image = self.dict[key];
    if (!image) {
        NSString *imagePath = [self imagePathForKey:key];

        NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
        image = [UIImage imageWithData:imageData];
        if (!image) {
            NSLog(@"Error: unable to find file for image key %@", key);
        }
    }
    return image;
}

- (void)setImage:(UIImage *)image
          forKey:(NSString *)key
{
    self.dict[key] = image;

    // Add image file to cache
    // Ch. 14 Bronze Challenge - save image as PNG
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *imagePath = [self imagePathForKey:key];
    [imageData writeToFile:imagePath atomically:YES];
}

- (void)removeImageForKey:(NSString *)key
{
    if (!key) return;
    
    [self.dict removeObjectForKey:key];
    
    // Remove image file from cache
    NSString *imagePath = [self imagePathForKey:key];
    [[NSFileManager defaultManager] removeItemAtPath:imagePath error:NULL];
}

- (NSString *)imagePathForKey:(NSString *)imageKey
{
    NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                           inDomains:NSUserDomainMask];
    NSURL *documentsURL = [urls firstObject];
    NSURL *fileURL = [documentsURL URLByAppendingPathComponent:imageKey];
    return [fileURL path];
}

- (void)clearCache
{
    NSLog(@"Flushing %d images from cache", [self.dict count]);
    [self.dict removeAllObjects];
}

@end
