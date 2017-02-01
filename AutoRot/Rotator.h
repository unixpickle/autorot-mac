//
//  Rotator.h
//  AutoRot
//
//  Created by Alex Nichol on 2/1/17.
//  Copyright © 2017 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileRotation.h"

@protocol RotatorDelegate<NSObject>
@required
- (void)rotatorGotData:(id)sender;
- (void)rotatorDone:(id)sender;
@end

@interface Rotator : NSObject {
    NSTask * task;
    NSMutableData * outputBuffer;
    
    id stdoutObserver;
    id terminateObserver;
}

@property (nonatomic, weak) id<RotatorDelegate> delegate;
@property (readonly) NSArray<FileRotation *> * rotations;
@property (readonly) BOOL done;

- (id)initWithDirectory:(NSString *)directory;
- (void)stop;

@end
