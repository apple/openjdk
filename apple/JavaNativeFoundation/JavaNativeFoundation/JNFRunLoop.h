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
 *
 * Used to perform selectors and blocks in the Java runloop mode.
 */

#import <Foundation/Foundation.h>
#import <JavaNativeFoundation/JNFJNI.h>

__BEGIN_DECLS

JNF_EXPORT extern NSString *JNFRunLoopDidStartNotification;

JNF_EXPORT
@interface JNFRunLoop : NSObject { }

+ (NSString *)javaRunLoopMode;
+ (void)performOnMainThread:(SEL)aSelector on:(id)target withObject:(id)arg waitUntilDone:(BOOL)wait;
#if __BLOCKS__
+ (void)performOnMainThreadWaiting:(BOOL)waitUntilDone withBlock:(void (^)(void))block;
#endif

@end

__END_DECLS
