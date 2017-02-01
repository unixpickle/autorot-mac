//
//  AppDelegate.m
//  AutoRot
//
//  Created by Alex Nichol on 2/1/17.
//  Copyright © 2017 Alex Nichol. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSOpenPanel * openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setAllowsMultipleSelection:NO];
    [openDlg beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            NSArray<NSURL *> * files = [openDlg URLs];
            NSString * path = files[0].path;
            rotator = [[Rotator alloc] initWithDirectory:path];
            rotator.delegate = self;
            if (![rotator start]) {
                NSLog(@"Start failed");
            }
        }
    }];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)rotatorDone:(id)sender {
    NSLog(@"Rotator done");
}

- (void)rotator:(id)sender gotRotation:(FileRotation *)rotation {
    NSLog(@"Got rotation: %@ %lf", rotation.path, rotation.angle);
}

@end
