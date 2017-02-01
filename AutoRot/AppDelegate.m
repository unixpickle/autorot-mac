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
@property (strong) IBOutlet ComparisonView * comparisonView;
@property (strong) IBOutlet NSTextField * noComparisonLabel;

- (IBAction)approve:(id)sender;
- (IBAction)disapprove:(id)sender;
- (IBAction)open:(id)sender;
- (void)showNextApproval;

@end

@implementation AppDelegate

- (void)awakeFromNib {
    [self.window center];
    [self.window setMinSize:NSMakeSize(400, 300)];
    [self.statusLabel setStringValue:@""];
    [self updateApprovalView];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self open:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    if (!rotator.done) {
        [rotator stop];
    }
}

- (void)showNextApproval {
    if (approveQueue.count == 0) {
        currentApprove = nil;
        [self updateApprovalView];
        return;
    }
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
    currentApprove = approveQueue[0];
    [self updateApprovalView];
}

- (void)updateApprovalView {
    if (currentApprove) {
        if (!self.comparisonView.superview) {
            [self.noComparisonLabel.superview addSubview:self.comparisonView];
        }
        [self.noComparisonLabel removeFromSuperview];
        [self.comparisonView takeImagesFromRotation:currentApprove];
    } else {
        if (!self.noComparisonLabel.superview) {
            [self.comparisonView.superview addSubview:self.noComparisonLabel];
        }
        [self.comparisonView removeFromSuperview];
    }
}

#pragma mark - Rotator -

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
    if (!currentApprove) {
        [self showNextApproval];
    }
}

#pragma mark - Table View -

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

#pragma mark - UI actions -

- (IBAction)approve:(id)sender {
    if (!currentApprove) {
        return;
    }
    // TODO: overwrite image file here.
    [approveQueue removeObject:currentApprove];
    [self showNextApproval];
}

- (IBAction)disapprove:(id)sender {
    if (!currentApprove) {
        return;
    }
    [approveQueue removeObject:currentApprove];
    [self showNextApproval];
}

- (IBAction)open:(id)sender {
    NSOpenPanel * openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setAllowsMultipleSelection:NO];
    [openDlg beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result != NSModalResponseOK) {
            return;
        }
        if (rotator != nil) {
            [rotator stop];
        }
        currentApprove = nil;
        approveQueue = [[NSMutableArray alloc] init];
        logEntries = [[NSMutableArray alloc] init];
        NSArray<NSURL *> * files = [openDlg URLs];
        NSString * path = files[0].path;
        rotator = [[Rotator alloc] initWithDirectory:path];
        rotator.delegate = self;
        [self.statusLabel setStringValue:@"Processing images..."];
        if (![rotator start]) {
            [self.statusLabel setStringValue:@"Internal error"];
        }
        [self.tableView reloadData];
        [self updateApprovalView];
    }];
}

@end
