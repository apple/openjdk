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
 * Functions that create strings that are in the proper format for holding
 * paths in Java and native.
 */

#import <Foundation/NSString.h>

#import <JavaNativeFoundation/JNFJNI.h>

__BEGIN_DECLS

/*
 * Returns a jstring in precomposed UTF16 format that is compatable with Java's
 * expectation of the UTF16 format for strings to be displayed.
 */
JNF_EXPORT extern jstring JNFNormalizedJavaStringForPath(JNIEnv *env, NSString *path);

/*
 * Returns an NSString in decomposed UTF16 format that is compatable with HFS's
 * expectation of the UTF16 format for file system paths.
 *  NOTE: this NSString is autoreleased.
 */
JNF_EXPORT extern NSString *JNFNormalizedNSStringForPath(JNIEnv *env, jstring path);

__END_DECLS
