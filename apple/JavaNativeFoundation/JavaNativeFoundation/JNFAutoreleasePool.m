/*
 * Copyright (c) 2008-2020 Apple Inc. All rights reserved.
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
 *
 * The JNFAutoreleasePool manages setting up and tearing down autorelease
 * pools for Java calls into the Cocoa frameworks.
 *
 * The external entry point into this machinery is JNFMethodEnter() and JNFMethodExit().
 */

#import "JNFAutoreleasePool.h"

#import <mach/mach_time.h>

// These are vended by the Objective-C runtime, but they are unfortunately
// not available as API in the macOS SDK.  We are following suit with swift
// and clang in declaring them inline here.  They canot be removed or changed
// in the OS without major bincompat ramifications.
//
// These were added in macOS 10.7.
void * _Nonnull objc_autoreleasePoolPush(void);
void objc_autoreleasePoolPop(void * _Nonnull context);

#if TIMED
static int64_t elapsedTime = 0;
#endif

#pragma mark -
#pragma mark External API

// JNFNativeMethodEnter - called on entry to each native method
//
// It sets up an autorelease pool, and will return a token if
// JNFNativeMethodExit should be called. It attempts to consider
// how much time has elapsed since the last autorelease pop.

JNFAutoreleasePoolToken *JNFNativeMethodEnter() {
#if TIMED
    int64_t start = mach_absolute_time();
#endif

    JNFAutoreleasePoolToken * const tokenToReturn = objc_autoreleasePoolPush();

#if TIMED
    elapsedTime += (mach_absolute_time() - start);
#endif

    return tokenToReturn;
}


// JNFNativeMethodExit - called on exit from native methods
//
// This method is only called on exit from the first
// native method to appear in the execution stack.
// This function does not need to be called on exit
// from the inner native methods (as an optimization).
// JNFNativeMethodEnter sets the token to non-nil if
// JNFNativeMethodExit needs to be called on exit.

void JNFNativeMethodExit(JNFAutoreleasePoolToken *token) {

#if TIMED
    int64_t start = mach_absolute_time();
#endif

    objc_autoreleasePoolPop(token);

#if TIMED
    elapsedTime += (mach_absolute_time() - start);

    NSLog(@"elapsedTime: %llu", elapsedTime);
    //	elapsedTime = 0;
#endif
}
