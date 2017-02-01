//
//  FileRotation.m
//  AutoRot
//
//  Created by Alex Nichol on 2/1/17.
//  Copyright © 2017 Alex Nichol. All rights reserved.
//

#import "FileRotation.h"

@implementation FileRotation

@synthesize path;
@synthesize angle;

- (id)initWithData:(NSData *)data {
    if ((self = [super init])) {
        NSString * str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if ([str hasSuffix:@"\r"]) {
            str = [str substringToIndex:str.length-1];
        }
        NSRange lastComma = [str rangeOfString:@"," options:NSBackwardsSearch];
        if (lastComma.location == NSNotFound) {
            return nil;
        }
        NSString * unescapedPath = [str substringToIndex:lastComma.location];
        NSString * angleStr = [str substringFromIndex:lastComma.location+1];
        if ([unescapedPath hasPrefix:@"\""]) {
            NSRange range = NSMakeRange(1, unescapedPath.length-1);
            unescapedPath = [unescapedPath substringWithRange:range];
        }
        path = [unescapedPath stringByReplacingOccurrencesOfString:@"\"\""
                                                        withString:@"\""];
        angle = [angleStr doubleValue];
    }
    return self;
}

@end
