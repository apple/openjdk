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
