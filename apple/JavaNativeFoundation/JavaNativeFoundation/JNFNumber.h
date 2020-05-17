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
 * Functions that convert between number container classes.
 */

#import <Foundation/NSValue.h>

#import <JavaNativeFoundation/JNFJNI.h>

__BEGIN_DECLS

/*
 * Converts java.lang.Number to an NSNumber
 *  NOTE: Return value is auto-released, so if you need to hang on to it, you should retain it.
 */
JNF_EXPORT extern NSNumber *JNFJavaToNSNumber(JNIEnv *env, jobject n);

/*
 * Converts an NSNumber to a java.lang.Number
 * Only returns java.lang.Longs or java.lang.Doubles.
 *  NOTE: This returns a JNI Local Ref. Any code that calls must call DeleteLocalRef with the return value.
 */
JNF_EXPORT extern jobject JNFNSToJavaNumber(JNIEnv *env, NSNumber *n);

/*
 * Converts a java.lang.Boolean constants to the CFBooleanRef constants
 */
JNF_EXPORT extern CFBooleanRef JNFJavaToCFBoolean(JNIEnv* env, jobject b);

/*
 * Converts a CFBooleanRef constants to the java.lang.Boolean constants
 */
JNF_EXPORT extern jobject JNFCFToJavaBoolean(JNIEnv *env, CFBooleanRef b);

__END_DECLS
