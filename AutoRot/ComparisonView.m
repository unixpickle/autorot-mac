//
//  ComparisonView.m
//  AutoRot
//
//  Created by Alex Nichol on 2/1/17.
//  Copyright © 2017 Alex Nichol. All rights reserved.
//

#import "ComparisonView.h"
#import "ANImageBitmapRep.h"

#define MARGINS 10
#define LABEL_HEIGHT 25

@interface ComparisonView (Private)
- (void)initializeSubviews;
@end

@implementation ComparisonView

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        [self initializeSubviews];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frameRect {
    if ((self = [super initWithFrame:frameRect])) {
        [self initializeSubviews];
    }
    return self;
}

- (void)takeImagesFromRotation:(FileRotation *)rot {
    NSString * path = rot.path;
    NSImage * img = [[NSImage alloc] initWithContentsOfFile:path];
    [self.left setImage:img];
    ANImageBitmapRep * bitmapRep = [img imageBitmapRep];
    [bitmapRep rotate:rot.angle*180/M_PI];
    NSImage * rotated = [bitmapRep image];
    [self.right setImage:rotated];
}

- (BOOL)isFlipped {
    return YES;
}

- (BOOL)autoresizesSubviews {
    return YES;
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize {
    NSSize newSize = self.frame.size;
    CGFloat sizeForWidth = (newSize.width - MARGINS*3) / 2;
    CGFloat sizeForHeight = newSize.height - MARGINS*2 - LABEL_HEIGHT;
    
    CGFloat size = round(MIN(sizeForWidth, sizeForHeight));
    CGFloat sideMargin = MARGINS + (sizeForWidth - size)/2;
    self.left.frame = NSMakeRect(sideMargin, MARGINS, size, size);
    self.right.frame = NSMakeRect(newSize.width-(sideMargin+size), MARGINS, size, size);
    self.leftLabel.frame = NSMakeRect(self.left.frame.origin.x, MARGINS*2+size, size,
                                      LABEL_HEIGHT);
    self.rightLabel.frame = NSMakeRect(self.right.frame.origin.x, MARGINS*2+size, size,
                                      LABEL_HEIGHT);
}

@end

@implementation ComparisonView (Private)
- (void)initializeSubviews {
    NSRect initRect = NSMakeRect(0, 0, 1, 1);
    _left = [[NSImageView alloc] initWithFrame:initRect];
    _right = [[NSImageView alloc] initWithFrame:initRect];
    _leftLabel = [[NSTextField alloc] initWithFrame:initRect];
    _rightLabel = [[NSTextField alloc] initWithFrame:initRect];
    _leftLabel.stringValue = @"Old";
    _rightLabel.stringValue = @"New";
    for (NSTextField * label in @[_leftLabel, _rightLabel]) {
        label.editable = NO;
        label.backgroundColor = [NSColor clearColor];
        label.bordered = NO;
        label.alignment = NSTextAlignmentCenter;
    }
    for (NSView * v in @[_left, _right, _leftLabel, _rightLabel]) {
        [self addSubview:v];
    }
    [self resizeSubviewsWithOldSize:NSMakeSize(0, 0)];
}
@end
