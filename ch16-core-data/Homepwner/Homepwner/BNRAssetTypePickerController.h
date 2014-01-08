//
//  BNRAssetTypePickerController.h
//  Homepwner
//
//  Created by Richard Shin on 1/7/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "BNRItem.h"
#import "BNRItemStore.h"

@interface BNRAssetTypePickerController : UITableViewController

@property (nonatomic, strong) BNRItem *item;
@property (nonatomic, copy) void (^dismissBlock)(void);

@end