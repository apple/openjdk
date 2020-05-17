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
