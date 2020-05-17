/*
 * Copyright (c) 2009-2020 Apple Inc. All rights reserved.
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
