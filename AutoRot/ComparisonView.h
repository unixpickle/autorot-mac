//
//  ComparisonView.h
//  AutoRot
//
//  Created by Alex Nichol on 2/1/17.
//  Copyright © 2017 Alex Nichol. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FileRotation.h"

@interface ComparisonView : NSView

@property (readonly) NSImageView * left;
@property (readonly) NSImageView * right;
@property (readonly) NSTextField * leftLabel;
@property (readonly) NSTextField * rightLabel;

- (id)initWithFrame:(NSRect)frameRect;
- (id)initWithCoder:(NSCoder *)coder;

- (void)takeImagesFromRotation:(FileRotation *)rot;

@end
