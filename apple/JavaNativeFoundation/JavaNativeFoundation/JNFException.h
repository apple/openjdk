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
 * JNFExceptions handle bridging exceptions between Foundation and Java. NSExceptions are
 * caught by the JNF_COCOA_ENTER()/JNF_COCOA_EXIT() macros, and transformed and thrown as
 * Java exceptions at the JNI boundry. The macros in JNFJNI.h also check for Java exceptions
 * and rethrow them as NSExceptions until they hit an @try/@catch block, or the
 * JNF_COCOA_ENTER()/JNF_COCOA_EXIT() macros.
 */

#import <Foundation/Foundation.h>

#import <JavaNativeFoundation/JNFJNI.h>

__BEGIN_DECLS

// Some exception class names.
// These strings contain the full class name of each Java exception, so
// they are handy to use when you need to throw an exception.
JNF_EXPORT extern const char *kOutOfMemoryError;
JNF_EXPORT extern const char *kClassNotFoundException;
JNF_EXPORT extern const char *kNullPointerException;
JNF_EXPORT extern const char *kIllegalAccessException;
JNF_EXPORT extern const char *kIllegalArgumentException;
JNF_EXPORT extern const char *kNoSuchFieldException;
JNF_EXPORT extern const char *kNoSuchMethodException;
JNF_EXPORT extern const char *kRuntimeException;

// JNFException - a subclass of NSException that wraps a Java exception
//
// When a java exception is thrown out to a native method, use +raiseUnnamedException:
// to turn it into an NSException.  When returning out of a native method in
// which an NSException has been raised, use the -raiseToJava: method to turn
// it back into a Java exception and "throw" it, in the Java sense.

JNF_EXPORT
@interface JNFException : NSException

+ (void)raiseUnnamedException:(JNIEnv *)env;
+ (void)raise:(JNIEnv *)env throwable:(jthrowable)throwable;
+ (void)raise:(JNIEnv *)env as:(const char *)javaExceptionType reason:(const char *)reasonMsg;

- init:(JNIEnv *)env throwable:(jthrowable)throwable;
- init:(JNIEnv *)env as:(const char *)javaExceptionType reason:(const char *)reasonMsg;

+ (void)throwToJava:(JNIEnv *)env exception:(NSException *)exception;
+ (void)throwToJava:(JNIEnv *)env exception:(NSException *)exception as:(const char *)javaExceptionType;

- (void)raiseToJava:(JNIEnv *)env;

@end

__END_DECLS
