/*
 * Copyright (c) 2009-2020 Apple Inc. All rights reserved.
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

#import "JNFRunnable.h"
#import "JNFThread.h"
#import "JNFJObjectWrapper.h"


static JNF_CLASS_CACHE(jc_Runnable, "java/lang/Runnable");
static JNF_MEMBER_CACHE(jm_run, jc_Runnable, "run", "()V");

@interface JNFRunnableWrapper : JNFJObjectWrapper { }
- (void) invokeRunnable;
@end

@implementation JNFRunnableWrapper

- (void) invokeRunnable {
    JNFThreadContext ctx = JNFThreadDetachOnThreadDeath | JNFThreadSetSystemClassLoaderOnAttach | JNFThreadAttachAsDaemon;
    JNIEnv *env = JNFObtainEnv(&ctx);
    JNFCallVoidMethod(env, [self jObjectWithEnv:env], jm_run);
    JNFReleaseEnv(env, &ctx);
}

@end


@implementation JNFRunnable

+ (NSInvocation *) invocationWithRunnable:(jobject)runnable withEnv:(JNIEnv *)env {
    SEL sel = @selector(invokeRunnable);
    NSMethodSignature *sig = [JNFRunnableWrapper instanceMethodSignatureForSelector:sel];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation retainArguments];
    [invocation setSelector:sel];

    JNFRunnableWrapper *runnableWrapper = [[JNFRunnableWrapper alloc] initWithJObject:runnable withEnv:env];
    [invocation setTarget:runnableWrapper];
    [runnableWrapper release];

    return invocation;
}

#if __BLOCKS__
+ (void(^)(void)) blockWithRunnable:(jobject)runnable withEnv:(JNIEnv *)env {
    JNFJObjectWrapper *runnableWrapper = [JNFJObjectWrapper wrapperWithJObject:runnable withEnv:env];

    return [[^() {
        JNFThreadContext ctx = JNFThreadDetachOnThreadDeath | JNFThreadSetSystemClassLoaderOnAttach | JNFThreadAttachAsDaemon;
        JNIEnv *_block_local_env = JNFObtainEnv(&ctx);
        JNFCallVoidMethod(env, [runnableWrapper jObjectWithEnv:_block_local_env], jm_run);
        JNFReleaseEnv(_block_local_env, &ctx);
    } copy] autorelease];
}
#endif

@end
