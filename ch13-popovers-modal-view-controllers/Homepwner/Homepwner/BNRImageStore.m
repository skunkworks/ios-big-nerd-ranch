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
    });
    
    return sharedStore;
}

- (UIImage *)imageForKey:(NSString *)key
{
    return self.dict[key];
}

- (void)setImage:(UIImage*)image
          forKey:(NSString *)key
{
    self.dict[key] = image;
}

- (void)removeImageForKey:(NSString *)key
{
    [self.dict removeObjectForKey:key];
}
@end
