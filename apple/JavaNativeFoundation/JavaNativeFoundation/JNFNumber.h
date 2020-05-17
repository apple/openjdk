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
