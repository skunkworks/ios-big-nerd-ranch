//
//  BNRImageStore.h
//  Homepwner
//
//  Created by Richard Shin on 12/13/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BNRImageStore : NSObject

+ (BNRImageStore *)sharedStore;

- (UIImage *)imageForKey:(NSString *)key;
- (void)setImage:(UIImage *)image forKey:(NSString *)key;
- (void)deleteImageForKey:(NSString *)key;

@end
