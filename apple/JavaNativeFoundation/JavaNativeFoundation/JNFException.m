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
 */

#import "JNFException.h"

#import <stdlib.h>
#import <Foundation/NSString.h>

#import "JNFObject.h"
#import "JNFString.h"
#import "JNFAssert.h"
#import "JNFThread.h"
#import "debug.h"


#define JAVA_LANG "java/lang/"
const char* kOutOfMemoryError           = JAVA_LANG "OutOfMemoryError";
const char* kClassNotFoundException     = JAVA_LANG "ClassNotFoundException";
const char* kNullPointerException       = JAVA_LANG "NullPointerException";
const char* kIllegalAccessException     = JAVA_LANG "IllegalAccessException";
const char* kIllegalArgumentException   = JAVA_LANG "IllegalArgumentException";
const char* kNoSuchFieldException       = JAVA_LANG "NoSuchFieldException";
const char* kNoSuchMethodException      = JAVA_LANG "NoSuchMethodException";
const char* kRuntimeException           = JAVA_LANG "RuntimeException";

@interface JNFException ()
@property (readwrite, nonatomic, assign) jthrowable javaException;
@end

@interface JNFException(_JNFPrivateExceptionLifecycle)

- (void) _setThrowable:(jthrowable)throwable withEnv:(JNIEnv *)env;
- (void) _clearThrowableWithEnv:(JNIEnv *)env;
- (void) _setThrowable:(jthrowable)throwable withNonNullEnv:(JNIEnv *)env;
- (void) _clearThrowableWithNonNullEnv:(JNIEnv *)env;

@end


@implementation JNFException

- initUnnamed:(JNIEnv *)env {
    JNF_ASSERT_COND(env);
    jthrowable throwable = (*env)->ExceptionOccurred(env);
    if (throwable) return [self init:env throwable:throwable];

    return [self initWithName:@"JavaNativeException" reason:@"See Java exception" userInfo:nil];
}

+ (void)raiseUnnamedException:(JNIEnv *)env {
    JNF_ASSERT_COND(env);
    [[[[JNFException alloc] initUnnamed:env] autorelease] raise];
}

+ (void)raise:(JNIEnv *)env throwable:(jthrowable)throwable {
    JNF_ASSERT_COND(env);
    [[[[JNFException alloc] init:env throwable:throwable] autorelease] raise];
}

+ (void)raise:(JNIEnv *)env as:(const char *)javaExceptionType reason:(const char *)reasonMsg {
    JNF_ASSERT_COND(env);
    [[[[JNFException alloc] init:env as:javaExceptionType reason:reasonMsg] autorelease] raise];
}

- init:(JNIEnv *)env throwable:(jthrowable)throwable {
    [self _setThrowable:throwable withEnv:env];
    (*env)->ExceptionClear(env);	// The exception will be rethrown in -raiseToJava

    static jclass jc_Throwable = NULL;
    if (jc_Throwable == NULL) {
        jc_Throwable = (*env)->FindClass(env, "java/lang/Throwable");
        jthrowable unexpected = (*env)->ExceptionOccurred(env);
        if (unexpected) {
            (*env)->ExceptionClear(env);
            return [self initWithName:@"JavaNativeException" reason:@"Internal JNF Error: could not find Throwable class" userInfo:nil];
        }
    }

    static jmethodID jm_Throwable_getMessage = NULL;
    if (jm_Throwable_getMessage == NULL && jc_Throwable != NULL) {
        jm_Throwable_getMessage = (*env)->GetMethodID(env, jc_Throwable, "toString", "()Ljava/lang/String;");
        jthrowable unexpected = (*env)->ExceptionOccurred(env);
        if (unexpected) {
            (*env)->ExceptionClear(env);
            return [self initWithName:@"JavaNativeException" reason:@"Internal JNF Error: could not find Throwable.toString() method" userInfo:nil];
        }
    }

    if (jm_Throwable_getMessage == NULL) {
        return [self initWithName:@"JavaNativeException" reason:@"Internal JNF Error: exception occurred, unable to determine cause" userInfo:nil];
    }

    jobject msg = (*env)->CallObjectMethod(env, throwable, jm_Throwable_getMessage);
    jthrowable unexpected = (*env)->ExceptionOccurred(env);
    if (unexpected) {
        (*env)->ExceptionClear(env);
        return [self initWithName:@"JavaNativeException" reason:@"Internal JNF Error: failed calling Throwable.toString()" userInfo:nil];
    }

    NSString *reason = JNFJavaToNSString(env, msg);
    (*env)->DeleteLocalRef(env, msg);
    return [self initWithName:@"JavaNativeException" reason:reason userInfo:nil];
}

- init:(JNIEnv *)env as:(const char *)javaExceptionType reason:(const char *)reasonMsg {
    jclass exceptionClass = NULL;
    char *buf = NULL;

    JNF_ASSERT_COND(env);
    if (javaExceptionType != NULL) {
        exceptionClass = (*env)->FindClass(env, javaExceptionType);
    }

    if (exceptionClass == NULL) {
        // Try to throw an AWTError exception
        static jthrowable  panicExceptionClass = NULL;
        const char*        panicExceptionName = kRuntimeException;
        if (panicExceptionClass == NULL) {
            jclass cls = (*env)->FindClass(env, panicExceptionName);
            if (cls != NULL) {
                panicExceptionClass = (*env)->NewGlobalRef(env, cls);
            }
        }

        exceptionClass = panicExceptionClass;
        if (javaExceptionType == NULL) {
            reasonMsg = "Missing Java exception class name while trying to throw a new Java exception";
        } else {
            // Quick and dirty thread-safe message buffer.
            buf = calloc(1, 512);
            if (buf != NULL) {
                sprintf(buf, "Unknown throwable class: %s.80", javaExceptionType);
                reasonMsg = buf;
            } else {
                reasonMsg = "Unknown throwable class, out of memory!";
            }
        }
        javaExceptionType = panicExceptionName;
    }

    // Can't throw squat if there's no class to throw
    if (exceptionClass != NULL) {
        (*env)->ThrowNew(env, exceptionClass, reasonMsg);
        jthrowable ex = (*env)->ExceptionOccurred(env);
        if (ex) {
            (*env)->ExceptionClear(env);    // Exception will be rethrown in -raiseToJava
        }
        [self _setThrowable:ex withEnv:env];
    }

    if (reasonMsg == NULL) reasonMsg = "unknown";

    @try {
        return [self initWithName:[NSString stringWithUTF8String:javaExceptionType]
                           reason:[NSString stringWithUTF8String:reasonMsg]
                         userInfo:nil];
    } @finally {
        if (buf != NULL) free(buf);
    }

    return self;
}

+ (void)throwToJava:(JNIEnv *)env exception:(NSException *)exception {
    [self throwToJava:env exception:exception as:kRuntimeException];
}

+ (void)throwToJava:(JNIEnv *)env exception:(NSException *)exception as:(const char *)javaExceptionType{
    if (![exception isKindOfClass:[JNFException class]]) {
        exception = [[JNFException alloc] init:env as:javaExceptionType reason:[[NSString stringWithFormat:@"Non-Java exception raised, not handled! (Original problem: %@)", [exception reason]] UTF8String]];
        [exception autorelease];
        JNF_WARN("NSException not handled by native method.  Passing to Java.");
    }

    [(JNFException *)exception raiseToJava:env];
}

- (void)raiseToJava:(JNIEnv *)env {
    jthrowable const javaException = self.javaException;

    JNF_ASSERT_COND(env);
    JNF_ASSERT_COND(javaException != NULL);
    (*env)->Throw(env, javaException);
}

- (NSString *)description {
    jthrowable const javaException = self.javaException;
    NSString *desc = [super description];
    if (!javaException) return desc;

    @try {
        JNFThreadContext ctx = JNFThreadDetachImmediately;
        JNIEnv *env = JNFObtainEnv(&ctx);
        if (!env) {
            NSLog(@"JavaNativeFoundation: NULL JNIEnv error occurred obtaining Java exception description");
            return desc;
        }
        (*env)->ExceptionClear(env);
        NSString *stackTrace = JNFGetStackTraceAsNSString(env, javaException);
        JNFReleaseEnv(env, &ctx);

        return stackTrace;
    } @catch (NSException *e) {
        // we clearly blew up trying to print our own exception, so we should
        // not try to do that again, even if it looks helpful - its a trap!
        NSLog(@"JavaNativeFoundation error occurred obtaining Java exception description");
    }
    return desc;
}

- (void) _setThrowable:(jthrowable)throwable withEnv:(JNIEnv *)env {
    if (env) {
        [self _clearThrowableWithNonNullEnv:env];
        [self _setThrowable:throwable withNonNullEnv:env];
        return;
    }

    JNFThreadContext threadContext = JNFThreadDetachImmediately;
    env = JNFObtainEnv(&threadContext);
    if (env == NULL) return;

    [self _clearThrowableWithNonNullEnv:env];
    [self _setThrowable:throwable withEnv:env];

    JNFReleaseEnv(env, &threadContext);
}

- (void) _clearThrowableWithEnv:(JNIEnv *)env {
    if (env) {
        [self _clearThrowableWithNonNullEnv:env];
        return;
    }

    JNFThreadContext threadContext = JNFThreadDetachImmediately;
    env = JNFObtainEnv(&threadContext);
    if (env == NULL) return; // leak?

    [self _clearThrowableWithNonNullEnv:env];

    JNFReleaseEnv(env, &threadContext);
}

- (void) _setThrowable:(jthrowable)throwable withNonNullEnv:(JNIEnv *)env {
    if (!throwable) return;
    self.javaException = (*env)->NewGlobalRef(env, throwable);
}

// delete and clear
- (void) _clearThrowableWithNonNullEnv:(JNIEnv *)env {
    jthrowable const javaException = self.javaException;
    if (!javaException) return;
    self.javaException = NULL;
    (*env)->DeleteGlobalRef(env, javaException);
}

- (void) dealloc {
    [self _clearThrowableWithEnv:NULL];
    [super dealloc];
}

@end
