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
 * Assertions used by the JNF_COCOA_ENTER()/JNF_COCOA_EXIT() and class
 * caching macros. When building debug builds, improper use of the caching
 * macros will trigger warnings output to the console.
 */

#import <JavaNativeFoundation/JNFJNI.h>

#ifdef DEBUG
#define JAVA_ASSERTIONS_ON
#endif /* DEBUG */

// Use the WARN macro to send a message to stderr in the
// debug build.  It gets removed from the optimized build
// during preprocessing.
#ifdef DEBUG
#define JNF_WARN JNFDebugWarning
#else
#define JNF_WARN if (0) JNFDebugWarning
#endif /* DEBUG */

__BEGIN_DECLS

JNF_EXPORT extern void JNFDebugWarning(const char *fmt, ...);

JNF_EXPORT extern void JNFAssertionFailure(const char *file, int line, const char *condition, const char *msg);

#ifdef JAVA_ASSERTIONS_ON

#define JNF_ASSERT_FAILURE(condition, msg)					\
    JNFAssertionFailure(__FILE__, __LINE__, condition, msg)	\


#define JNF_ASSERT_MSG(condition, msg)						\
do {														\
    if (!(condition)) {										\
        JNF_ASSERT_FAILURE(#condition, msg);				\
    }														\
} while(0)													\


#define JNF_ASSERT_COND(condition)							\
    JNF_ASSERT_MSG(condition, NULL)							\


#define JNF_EXCEPTION_WARN(env, msg)						\
do {														\
    (*(env))->ExceptionDescribe(env);						\
    JNF_ASSERT_FAILURE("Java exception thrown", msg);		\
} while (0)													\


#define JNF_ASSERT_NO_EXCEPTION_MSG(env, msg)				\
if ((*(env))->ExceptionOccurred(env)) {						\
    JNF_EXCEPTION_WARN(env, msg);							\
}															\


#define JNF_ASSERT_NO_EXCEPTION(env)						\
    JNF_ASSERT_NO_EXCEPTION_MSG(env, NULL)					\

#else

#define JNF_ASSERT_COND(condition)
#define JNF_ASSERT_MSG(condition, msg)
#define JNF_EXCEPTION_WARN(env, msg)
#define JNF_ASSERT_NO_EXCEPTION(env)
#define JNF_ASSERT_NO_EXCEPTION_MSG(env, msg)

#endif /* JAVA_ASSERTIONS_ON */

JNF_EXPORT extern void JNFDumpJavaStack(JNIEnv *env);

__END_DECLS
