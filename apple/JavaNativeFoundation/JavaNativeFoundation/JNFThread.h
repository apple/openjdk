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
 * Functions to help obtain a JNIEnv pointer in places where one cannot be passed
 * though (callbacks, catagory functions, etc). Use sparingly.
 */

#import <os/availability.h>
#import <JavaNativeFoundation/JNFJNI.h>

__BEGIN_DECLS

// Options only apply if thread was not already attached to the JVM.
enum {
    JNFThreadDetachImmediately = (1 << 1),
    JNFThreadDetachOnThreadDeath = (1 << 2),
    JNFThreadSetSystemClassLoaderOnAttach = (1 << 3),
    JNFThreadAttachAsDaemon = (1 << 4)
};

typedef jlong JNFThreadContext;


/*
 * Attaches the current thread to the Java VM if needed, and obtains a JNI environment
 * to interact with the VM. Use a provided JNIEnv pointer for your current thread
 * whenever possible, since this method is particularly expensive to the Java VM if
 * used repeatedly.
 *
 * Provide a pointer to a JNFThreadContext to pass to JNFReleaseEnv().
 */
JNF_EXPORT extern JNIEnv *JNFObtainEnv(JNFThreadContext *context) API_DEPRECATED("This functionality is no longer supported and may stop working in a future version of macOS.", macos(10.10, 10.16));

/*
 * Release the JNIEnv for this thread, and detaches the current thread from the VM if
 * it was not already attached.
 */
JNF_EXPORT extern void JNFReleaseEnv(JNIEnv *env, JNFThreadContext *context) API_DEPRECATED("This functionality is no longer supported and may stop working in a future version of macOS.", macos(10.10, 10.16));


#if __BLOCKS__

/*
 * Performs the same attach/detach as JNFObtainEnv() and JNFReleaseEnv(), but executes a
 * block that accepts the obtained JNIEnv.
 */
typedef void (^JNIEnvBlock)(JNIEnv *);
JNF_EXPORT extern void JNFPerformEnvBlock(JNFThreadContext context, JNIEnvBlock block) API_DEPRECATED("This functionality is no longer supported and may stop working in a future version of macOS.", macos(10.10, 10.16));

#endif

__END_DECLS
