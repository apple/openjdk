/*
 * Copyright (c) 2009-2020 Apple Inc. All rights reserved.
 *
 * @GPLv2-CPE_LICENSE_HEADER_START@
 *
 * The contents of this file are licensed under the terms of the
 * GNU Public License (version 2 only) with the "Classpath" exception.
 *
 * This code is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 only with
 * classpath exception, as published by the Free Software Foundation.
 *
 * This code is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * version 2 for more details (a copy is included in the LICENSE file that
 * accompanied this code).
 *
 * @GPLv2-CPE_LICENSE_HEADER_END@
 */

#import "JNFRunLoop.h"

#import <Cocoa/Cocoa.h>


NSString *JNFRunLoopDidStartNotification = @"JNFRunLoopDidStartNotification";

static NSString *AWTRunLoopMode = @"AWTRunLoopMode";
static NSArray *sPerformModes = nil;

@implementation JNFRunLoop

+ (void)initialize {
    if (sPerformModes) return;
    sPerformModes = [[NSArray alloc] initWithObjects:NSDefaultRunLoopMode, NSModalPanelRunLoopMode, NSEventTrackingRunLoopMode, AWTRunLoopMode, nil];
}

+ (NSString *)javaRunLoopMode {
    return AWTRunLoopMode;
}

+ (void)performOnMainThread:(SEL)aSelector on:(id)target withObject:(id)arg waitUntilDone:(BOOL)waitUntilDone {
    [target performSelectorOnMainThread:aSelector withObject:arg waitUntilDone:waitUntilDone modes:sPerformModes];
}

#if __BLOCKS__

+ (void)_performDirectBlock:(void (^)(void))block {
    block();
}

+ (void)_performCopiedBlock:(void (^)(void))newBlock {
    newBlock();
    Block_release(newBlock);
}

+ (void)performOnMainThreadWaiting:(BOOL)waitUntilDone withBlock:(void (^)(void))block {
    if (waitUntilDone) {
        [self performOnMainThread:@selector(_performDirectBlock:) on:self withObject:block waitUntilDone:YES];
    } else {
        void (^newBlock)(void) = Block_copy(block);
        [self performOnMainThread:@selector(_performCopiedBlock:) on:self withObject:newBlock waitUntilDone:NO];
    }
}

#endif

@end
