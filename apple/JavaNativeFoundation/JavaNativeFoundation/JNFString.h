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
