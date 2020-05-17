/*
 * Copyright (c) 2008-2020 Apple Inc. All rights reserved.
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
