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

#import "JNFJNI.h"
#import "JNFAssert.h"

#import "debug.h"

static void JNFDebugMessageV(const char *fmt, va_list args) {
    // Prints a message and breaks into debugger.
    fprintf(stderr, "JavaNativeFoundation: ");
    vfprintf(stderr, fmt, args);
    fprintf(stderr, "\n");
}

static void JNFDebugMessage(const char *fmt, ...) {
    // Takes printf args and then calls DebugBreak
    va_list args;
    va_start(args, fmt);
    JNFDebugMessageV(fmt, args);
    va_end(args);
}

void JNFDebugWarning(const char *fmt, ...) {
    // Takes printf args and then calls DebugBreak
    va_list args;
    va_start(args, fmt);
    JNFDebugMessageV(fmt, args);
    va_end(args);
}

void JNFAssertionFailure(const char *file, int line, const char *condition, const char *msg) {
    JNFDebugMessage("Assertion failure: %s", condition);
    if (msg) JNFDebugMessage(msg);
    JNFDebugMessage("File %s; Line %d", file, line);
}

void JNFDumpJavaStack(JNIEnv *env) {
    static JNF_CLASS_CACHE(jc_Thread, "java/lang/Thread");
    static JNF_STATIC_MEMBER_CACHE(jsm_Thread_dumpStack, jc_Thread, "dumpStack", "()V");
    JNFCallVoidMethod(env, jc_Thread.cls, jsm_Thread_dumpStack);
}
