/*
 * Copyright (c) 2009-2020 Apple Inc. All rights reserved.
 *
 * @APPLE_LICENSE_HEADER_START@
 *
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this
 * file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 *
 * @APPLE_LICENSE_HEADER_END@
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
