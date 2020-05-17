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
 *
 * Simple wrapper classes to hold Java Objects in JNI global references.
 *
 * This is used to pass Java objects across thread boundries, often through
 * -performSelectorOnMainThread invocations. This wrapper properly creates a
 * new global ref, and clears it on -dealloc or -finalize, attaching to the
 * current VM, attaching the current thread if necessary, releasing the global
 * ref, and detaching the thread from the VM if it attached it.
 *
 * Destruction of this wrapper is expensive if the jobject has not been
 * pre-cleared, because it must re-attach to the JVM.
 *
 * The JNFWeakJObjectWrapper manages a weak global reference which may become
 * invalid if the JVM garbage collects the original object.
 */

#import <Foundation/Foundation.h>
#import <JavaNativeFoundation/JNFJNI.h>

__BEGIN_DECLS

JNF_EXPORT
@interface JNFJObjectWrapper : NSObject

+ (JNFJObjectWrapper *) wrapperWithJObject:(jobject)jObjectIn withEnv:(JNIEnv *)env;
- (id) initWithJObject:(jobject)jObjectIn withEnv:(JNIEnv *)env;
- (void) setJObject:(jobject)jObjectIn withEnv:(JNIEnv *)env; // clears any pre-existing global-ref
- (jobject) jObjectWithEnv:(JNIEnv *)env; // returns a new local-ref, must be released with DeleteLocalRef

@property (readonly, nonatomic, assign) jobject jObject;

@end


JNF_EXPORT
@interface JNFWeakJObjectWrapper : JNFJObjectWrapper { }

+ (JNFWeakJObjectWrapper *) wrapperWithJObject:(jobject)jObjectIn withEnv:(JNIEnv *)env;

@end

__END_DECLS
