/*
 JNFAssert.m
 Java Native Foundation
 Copyright (c) 2008, Apple Inc.
 All rights reserved.
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
