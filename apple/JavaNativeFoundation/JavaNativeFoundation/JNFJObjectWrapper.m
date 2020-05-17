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
