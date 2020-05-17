//
//  JNFRunnable.m
//  Copyright 2009-2010 Apple Inc. All rights reserved.
//

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
