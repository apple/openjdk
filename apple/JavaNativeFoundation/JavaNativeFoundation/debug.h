//
//	debug.h
//	Java Native Foundation
//	Copyright (c) 2008-2009, Apple Inc.
//	All rights reserved.
//
// Internal functions to Java Native Foundation.
//

#import <Foundation/Foundation.h>
#import <JavaNativeFoundation/JNFJNI.h>

__BEGIN_DECLS

//
// Debugging support
//

// prints a stack trace from the Java VM (can be called from gdb)   
void JNFJavaStackTrace(JNIEnv *env);

// dump some info about a generic Java object.
void JNFDumpJavaObject(JNIEnv *env, jobject obj);

// prints a Java stack trace into a string
NSString *JNFGetStackTraceAsNSString(JNIEnv *env, jthrowable throwable);

__END_DECLS
