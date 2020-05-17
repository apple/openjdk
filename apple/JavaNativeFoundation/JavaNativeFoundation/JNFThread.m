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

#import "JNFThread.h"

#import <dlfcn.h>
#import <pthread.h>

static JavaVM *GetGlobalVM() { // obtains a connection to the current VM
    static JavaVM *globalVM;

    if (globalVM != NULL) {
        return globalVM;
    }

    void *jvmHandle = dlopen("@rpath/libjvm.dylib", RTLD_NOW);
    if (!jvmHandle) {
        NSLog(@"JavaNativeFoundation: %s: Failed to locate @rpath/libjvm.dylib for JNI_GetCreatedJavaVMs(). A JVM must be loaded before calling this function.", __FUNCTION__);
        return NULL;
    }

    jint (*_JNI_GetCreatedJavaVMs)(JavaVM **, jsize, jsize *) = dlsym(jvmHandle, "JNI_GetCreatedJavaVMs");
    if (!_JNI_GetCreatedJavaVMs) {
        NSLog(@"JavaNativeFoundation: %s: Failed to locate JNI_GetCreatedJavaVMs symbol in @rpath/libjvm.dylib", __FUNCTION__);
        return NULL;
    }

    JavaVM *vmArray;
    jsize numVMs = 0;
    if (_JNI_GetCreatedJavaVMs(&vmArray, 1, &numVMs) == 0 && numVMs >= 1) {
        globalVM = &vmArray[0];
    }

    if (globalVM == NULL) {
        NSLog(@"JavaNativeFoundation: %s: JNI_GetCreatedJavaVMs() failed to get any VM.", __FUNCTION__);
        return NULL;
    }

    return globalVM;
}

// private marker to indicate if we need to detach on release
enum {
    JNFThreadWillDetachOnRelease = (1 << 12)
};

static void setSystemClassLoader(JNIEnv *env) {
    // setup the context class loader for this new thread coming into the JVM
    JNF_CLASS_CACHE(jc_Thread, "java/lang/Thread");
    JNF_STATIC_MEMBER_CACHE(jm_currentThread, jc_Thread, "currentThread", "()Ljava/lang/Thread;");
    jobject currentThread = JNFCallStaticObjectMethod(env, jm_currentThread);

    JNF_CLASS_CACHE(jc_ClassLoader, "java/lang/ClassLoader");
    JNF_STATIC_MEMBER_CACHE(jm_getSystemClassLoader, jc_ClassLoader, "getSystemClassLoader", "()Ljava/lang/ClassLoader;");
    jobject systemClassLoader = JNFCallStaticObjectMethod(env, jm_getSystemClassLoader);

    JNF_MEMBER_CACHE(jm_setContextClassLoader, jc_Thread, "setContextClassLoader", "(Ljava/lang/ClassLoader;)V");
    JNFCallVoidMethod(env, currentThread, jm_setContextClassLoader, systemClassLoader);
}

static JNFThreadContext GetEnvUsingJVM(JavaVM *jvm, void **envPtr, BOOL shouldDetachOnRelease, BOOL setClassLoader, BOOL attachAsDaemon) {
    jint status = (*jvm)->GetEnv(jvm, envPtr, JNI_VERSION_1_4);
    if (status == JNI_OK) {
        // common path
        return 0;
    }

    if (status != JNI_EDETACHED) {
        // can't use JNF_ASSERT macros, since we don't really know if we have an env :(
        NSLog(@"JavaNativeFoundation: JNFObtainEnv unable to obtain JNIEnv (%d)", (int)status);
        return 0;
    }

    // we need to attach
    if (attachAsDaemon) {
        status = (*jvm)->AttachCurrentThreadAsDaemon(jvm, envPtr, NULL);
    } else {
        status = (*jvm)->AttachCurrentThread(jvm, envPtr, NULL);
    }

    if (status != JNI_OK) {
        // failed - need to clear our mark to detach, if present
        return 0;
    }

    if (setClassLoader) {
        setSystemClassLoader((JNIEnv *)(*envPtr));
    }

    // by default, we detach at pthread death, but if requested, we will detach on env-release
    if (shouldDetachOnRelease) {
        return JNFThreadWillDetachOnRelease;
    }

    // we don't do anything in this case, because HotSpot on Mac OS X will detach for us.
    // <rdar://problem/4466820> Can we install a pthread_atexit handler to detach if we haven't already?
    return 0;
}

// public call to obtain an env, and attach the current thread to the VM in needed
JNIEnv *JNFObtainEnv(JNFThreadContext *context) {
    JavaVM *jvm = GetGlobalVM();
    if (!jvm) {
        *context = 0;
        return NULL;
    }

    JNFThreadContext ctx = *context;
    BOOL shouldDetachOnRelease = (0 != (ctx & JNFThreadDetachImmediately));
    BOOL setClassLoader = (0 != (ctx & JNFThreadSetSystemClassLoaderOnAttach));
    BOOL attachAsDaemon = (0 != (ctx & JNFThreadAttachAsDaemon));

    void *env = NULL;
    *context = GetEnvUsingJVM(jvm, &env, shouldDetachOnRelease, setClassLoader, attachAsDaemon);
    return (JNIEnv *)env;
}

void JNFReleaseEnv(__unused JNIEnv *env, JNFThreadContext *context) {
    if ((*context & JNFThreadWillDetachOnRelease) == 0) {
        return;
    }

    JavaVM *jvm = GetGlobalVM();
    if (!jvm) return;

    jint status = (*jvm)->DetachCurrentThread(jvm);
    if (status != JNI_OK) {
        // can't use JNF_ASSERT macros, since we don't really know if we have an env :(
        NSLog(@"JavaNativeFoundation: %s: unable to release JNIEnv (%d)", __FUNCTION__, (int)status);
    }
}


#if __BLOCKS__

JNF_EXPORT extern void JNFPerformEnvBlock(JNFThreadContext context, JNIEnvBlock block) {
    JNIEnv *env = JNFObtainEnv(&context);
    if (env == NULL) [NSException raise:@"Unable to obtain JNIEnv" format:@"Unable to obtain JNIEnv for context: %p", (void *)context];

    @try {
        block(env);
    } @finally {
        JNFReleaseEnv(env, &context);
    }
}

#endif
