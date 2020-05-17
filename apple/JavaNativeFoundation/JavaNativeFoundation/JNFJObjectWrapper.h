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
