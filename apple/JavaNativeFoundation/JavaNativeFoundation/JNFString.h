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
 * Functions that create NSStrings, UTF16 unichars, or UTF8 chars from java.lang.Strings
 */

#import <Foundation/NSString.h>

#import <JavaNativeFoundation/JNFJNI.h>

__BEGIN_DECLS

// Returns an NSString given a java.lang.String object
//	NOTE: Return value is auto-released, so if you need to hang on to it, you should retain it.
JNF_EXPORT extern NSString *JNFJavaToNSString(JNIEnv *env, jstring javaString);

// Returns a java.lang.String object as a JNI local ref.
//	NOTE: This returns a JNI Local Ref. Any code that calls this should call DeleteLocalRef with the return value.
JNF_EXPORT extern jstring JNFNSToJavaString(JNIEnv *env, NSString *nsString);

/*
 * Gets UTF16 unichars from a Java string, and checks for errors and raises a JNFException if
 * the unichars cannot be obtained from Java.
 */
JNF_EXPORT extern const unichar *JNFGetStringUTF16UniChars(JNIEnv *env, jstring javaString);

/*
 * Releases the unichars obtained from JNFGetStringUTF16UniChars()
 */
JNF_EXPORT extern void JNFReleaseStringUTF16UniChars(JNIEnv *env, jstring javaString, const unichar *unichars);

/*
 * Gets UTF8 chars from a Java string, and checks for errors and raises a JNFException if
 * the chars cannot be obtained from Java.
 */
JNF_EXPORT extern const char *JNFGetStringUTF8Chars(JNIEnv *env, jstring javaString);

/*
 * Releases the chars obtained from JNFGetStringUTF8Chars()
 */
JNF_EXPORT extern void JNFReleaseStringUTF8Chars(JNIEnv *env, jstring javaString, const char *chars);

__END_DECLS
