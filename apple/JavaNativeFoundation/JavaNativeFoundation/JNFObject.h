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
 * Functions that access some of the base functionality of java.lang.Object.
 */

#import <Foundation/NSString.h>

#import <JavaNativeFoundation/JNFJNI.h>

__BEGIN_DECLS

/*
 * Returns Object.equals() for the two items
 */
JNF_EXPORT extern BOOL JNFObjectEquals(JNIEnv* env, jobject a, jobject b);

/*
 * Returns Object.toString() as an NSString
 */
JNF_EXPORT extern NSString *JNFObjectToString(JNIEnv *env, jobject obj);

/*
 * Returns Object.getClass().toString() as an NSString. Useful in gdb.
 */
JNF_EXPORT extern NSString *JNFObjectClassName(JNIEnv* env, jobject obj);

__END_DECLS
