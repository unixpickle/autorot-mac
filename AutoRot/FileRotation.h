//
//  FileRotation.h
//  AutoRot
//
//  Created by Alex Nichol on 2/1/17.
//  Copyright © 2017 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileRotation : NSObject

@property (strong, nonatomic) NSString * path;
@property (readwrite) double angle;

- (id)initWithData:(NSData *)data;
- (double)rotationSeverity;

@end
