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
