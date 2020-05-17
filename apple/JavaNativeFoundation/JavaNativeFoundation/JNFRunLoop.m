//
//  JNFRunLoop.m
//  Copyright 2009-2011 Apple Inc. All rights reserved.
//

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
