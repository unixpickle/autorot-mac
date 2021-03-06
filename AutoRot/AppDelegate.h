//
//  AppDelegate.h
//  AutoRot
//
//  Created by Alex Nichol on 2/1/17.
//  Copyright © 2017 Alex Nichol. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Rotator.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, RotatorDelegate,
    NSTableViewDelegate, NSTableViewDataSource> {
    Rotator * rotator;
    NSMutableArray<FileRotation *> * logEntries;
    NSMutableArray<FileRotation *> * approveQueue;
    FileRotation * currentApprove;
}

@end

