//
//  Rotator.m
//  AutoRot
//
//  Created by Alex Nichol on 2/1/17.
//  Copyright © 2017 Alex Nichol. All rights reserved.
//

#import "Rotator.h"

@interface Rotator (Private)
- (void)setupDataLoop;
- (void)gotData:(NSData *)data;
- (void)gotDone;
- (NSData *)nextLineFromBuffer;
- (void)removeObservers;
@end

@implementation Rotator

@synthesize delegate;
@synthesize rotations;
@synthesize done;

- (id)initWithDirectory:(NSString *)directory {
    if ((self = [super init])) {
        NSString * netPath = [[NSBundle mainBundle] pathForResource:@"autorot_net"
                                                             ofType:nil];
        NSString * cmdPath = [[NSBundle mainBundle] pathForResource:@"autorot_classify"
                                                             ofType:nil];
        task = [[NSTask alloc] init];
        task.arguments = @[@"-net", netPath, @"-dir", directory];
        task.launchPath = cmdPath;
        [self setupDataLoop];
        
        __weak Rotator * weakSelf = self;
        terminateObserver = [[NSNotificationCenter defaultCenter]
         addObserverForName:NSTaskDidTerminateNotification
         object:task
         queue:nil
         usingBlock:^(NSNotification * note) {
             dispatch_sync(dispatch_get_main_queue(), ^{
                 [weakSelf gotDone];
             });
         }];
        [task launch];
    }
    return self;
}

- (void)stop {
    done = YES;
    [self removeObservers];
    [task terminate];
}

@end

@implementation Rotator (Private)

- (void)setupDataLoop {
    task.standardOutput = [NSPipe pipe];
    [[task.standardOutput fileHandleForReading] waitForDataInBackgroundAndNotify];
    __weak Rotator * weakSelf = self;
    stdoutObserver = [[NSNotificationCenter defaultCenter]
     addObserverForName:NSFileHandleDataAvailableNotification
     object:[task.standardOutput fileHandleForReading]
     queue:nil
     usingBlock:^(NSNotification * note) {
         NSData * output = [[task.standardOutput fileHandleForReading] availableData];
         dispatch_sync(dispatch_get_main_queue(), ^{
             [weakSelf gotData:output];
         });
         [[task.standardOutput fileHandleForReading] waitForDataInBackgroundAndNotify];
     }];
}

- (void)gotData:(NSData *)data {
    if (!outputBuffer) {
        outputBuffer = [NSMutableData dataWithData:data];
    } else {
        [outputBuffer appendData:data];
    }
    NSData * nextLine;
    BOOL gotLine = NO;
    while ((nextLine = [self nextLineFromBuffer])) {
        FileRotation * rot = [[FileRotation alloc] initWithData:nextLine];
        if (rotations == nil) {
            rotations = [NSArray arrayWithObject:rot];
        } else {
            NSMutableArray * rots = [NSMutableArray arrayWithArray:rotations];
            [rots addObject:rot];
            rotations = rots;
        }
        gotLine = YES;
    }
    if (gotLine) {
        [self.delegate rotatorGotData:self];
    }
}

- (void)gotDone {
    if (!done) {
        done = YES;
        [self.delegate rotatorDone:self];
        [self removeObservers];
    }
}

- (NSData *)nextLineFromBuffer {
    const char * bytes = (const char *)[outputBuffer bytes];
    for (NSUInteger i = 0; i < outputBuffer.length; ++i) {
        if (bytes[i] == '\n') {
            NSData * res = [outputBuffer subdataWithRange:NSMakeRange(0, i)];
            [outputBuffer replaceBytesInRange:NSMakeRange(0, i+1) withBytes:NULL length:0];
            return res;
        }
    }
    return nil;
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:stdoutObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:terminateObserver];
}

@end
