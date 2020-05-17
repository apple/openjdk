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

#import "JNFJObjectWrapper.h"

#import "JNFJNI.h"
#import "JNFThread.h"

@interface JNFJObjectWrapper ()
@property (readwrite, nonatomic, assign) jobject jObject;
@end

@implementation JNFJObjectWrapper

- (jobject) _getWithEnv:(__unused JNIEnv *)env {
    return self.jObject;
}

- (jobject) _createObj:(jobject)jObjectIn withEnv:(JNIEnv *)env {
    return JNFNewGlobalRef(env, jObjectIn);
}

- (void) _destroyObj:(jobject)jObjectIn withEnv:(JNIEnv *)env {
    JNFDeleteGlobalRef(env, jObjectIn);
}

+ (JNFJObjectWrapper *) wrapperWithJObject:(jobject)jObjectIn withEnv:(JNIEnv *)env {
    return [[[JNFJObjectWrapper alloc] initWithJObject:jObjectIn withEnv:env] autorelease];
}

- (id) initWithJObject:(jobject)jObjectIn withEnv:(JNIEnv *)env {
    self = [super init];
    if (!self) return self;

    if (jObjectIn) {
        self.jObject = [self _createObj:jObjectIn withEnv:env];
    }

    return self;
}

- (jobject) jObjectWithEnv:(JNIEnv *)env {
    jobject validObj = [self _getWithEnv:env];
    if (!validObj) return NULL;

    return (*env)->NewLocalRef(env, validObj);
}

- (void) setJObject:(jobject)jObjectIn withEnv:(JNIEnv *)env {
    jobject const jobj = self.jObject;
    if (jobj == jObjectIn) return;

    if (jobj) {
        [self _destroyObj:jobj withEnv:env];
    }

    if (jObjectIn) {
        self.jObject = [self _createObj:jObjectIn withEnv:env];
    } else {
        self.jObject = NULL;
    }
}

- (void) clearJObjectReference {
    jobject const jobj = self.jObject;
    if (!jobj) return;

    JNFThreadContext threadContext = JNFThreadDetachImmediately;
    JNIEnv *env = JNFObtainEnv(&threadContext);
    if (env == NULL) return; // leak?

    [self _destroyObj:jobj withEnv:env];
    self.jObject = NULL;

    JNFReleaseEnv(env, &threadContext);
}

- (void) dealloc {
    [self clearJObjectReference];
    [super dealloc];
}

@end


@implementation JNFWeakJObjectWrapper

+ (JNFWeakJObjectWrapper *) wrapperWithJObject:(jobject)jObjectIn withEnv:(JNIEnv *)env {
    return [[[JNFWeakJObjectWrapper alloc] initWithJObject:jObjectIn withEnv:env] autorelease];
}

- (jobject) _getWithEnv:(JNIEnv *)env {
    jobject const jobj = self.jObject;

    if ((*env)->IsSameObject(env, jobj, NULL) == JNI_TRUE) {
        self.jObject = NULL; // object went invalid
        return NULL;
    }
    return jobj;
}

- (jobject) _createObj:(jobject)jObjectIn withEnv:(JNIEnv *)env {
    return JNFNewWeakGlobalRef(env, jObjectIn);
}

- (void) _destroyObj:(jobject)jObjectIn withEnv:(JNIEnv *)env {
    JNFDeleteWeakGlobalRef(env, jObjectIn);
}

@end
