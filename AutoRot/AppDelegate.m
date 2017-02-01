//
//  AppDelegate.m
//  AutoRot
//
//  Created by Alex Nichol on 2/1/17.
//  Copyright © 2017 Alex Nichol. All rights reserved.
//

#import "AppDelegate.h"
#import "ComparisonView.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow * window;
@property (weak) IBOutlet NSTextField * statusLabel;
@property (weak) IBOutlet NSTableView * tableView;
@property (weak) IBOutlet ComparisonView * comparisonView;

- (void)showNextApproval;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    approveQueue = [[NSMutableArray alloc] init];
    logEntries = [[NSMutableArray alloc] init];
    [self.window center];
    [self.window setMinSize:NSMakeSize(400, 300)];
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
            [self.statusLabel setStringValue:@"Processing images..."];
            if (![rotator start]) {
                [self.statusLabel setStringValue:@"Internal error"];
            }
        }
    }];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    if (!rotator.done) {
        [rotator stop];
    }
}

- (void)rotatorDone:(id)sender {
    [self.statusLabel setStringValue:[NSString stringWithFormat:@"Done processing %lu images",
                                      logEntries.count]];
}

- (void)rotator:(id)sender gotRotation:(FileRotation *)rotation {
    [logEntries addObject:rotation];
    [self.statusLabel setStringValue:[NSString stringWithFormat:@"Processed %lu images...",
                                      logEntries.count]];
    [self.tableView reloadData];
    
    [approveQueue addObject:rotation];
    [approveQueue sortUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
        FileRotation * rot1 = (FileRotation *)obj1;
        FileRotation * rot2 = (FileRotation *)obj2;
        if ([rot1 rotationSeverity] < [rot2 rotationSeverity]) {
            return NSOrderedDescending;
        } else if ([rot1 rotationSeverity] > [rot2 rotationSeverity]) {
            return NSOrderedAscending;
        } else {
            return NSOrderedSame;
        }
    }];
    if (!currentApprove) {
        [self showNextApproval];
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return logEntries.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(NSInteger)row {
    FileRotation * entry = logEntries[row];
    if ([tableColumn.identifier isEqualToString:@"path"]) {
        return entry.path;
    } else if ([tableColumn.identifier isEqualToString:@"angle"]) {
        return [NSNumber numberWithDouble:entry.angle * 180 / M_PI];
    }
    return nil;
}

- (void)showNextApproval {
    currentApprove = approveQueue[0];
    NSString * path = currentApprove.path;
    NSImage * img = [[NSImage alloc] initWithContentsOfFile:path];
    [self.comparisonView.left setImage:img];
    
    // TODO: make a rotated version of the image.
}

@end
