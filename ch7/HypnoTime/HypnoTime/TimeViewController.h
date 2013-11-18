//
//  TimeViewController.h
//  HypnoTime
//
//  Created by Richard Shin on 11/17/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeViewController : UIViewController
{
    // Outlets can be weak pointers because the top-level view keeps a
    // strong pointer to the instances of these view outlets themselves.
    // If the top-level view ever releases those instances, we have no
    // interest in them either.
    __weak IBOutlet UILabel *timeLabel;
}

@end
